function varargout = require(varargin)
%function varargout = require(params, resource, ..., protected)
%
%REQUIRE acquires access to a limited resource before running a protected
%function; guaranteed to release the resource after running the protected
%function.
%
%The optional first argument is a parameter structure. This is passed to
%the first initializer. The output from the first initializer is passed to
%the second initializer, and so on.
%
%REQUIRE takes multiple resource arguments.
%Each resource argument shoud be a function handle. When called, the
%resource function should acquire a resource (e.g. open a file , connect to
%a device, open a window on screen, etc.) The first argument returned by
%the resource function should be a releaser, another function handle, taking no
%arguments, that releases the resource in question.
%
%Initializers take one argument, that is a struct containing parameters
%used for their task; they modify this struct with additional fields and
%return it as their second output. So the form of an initializer is:
%
%function [releaser, params] = init(params)...
%
%
%Here is an example of usage. The function 'opener'
%bundles corresponding 'open' and 'close' operations together. Note how
%the 'fid' value is passed from 'opener' to 'write.'
%
%   require(@opener, @write);
%   function write(params)
%       fprintf(params.fid, 'Hello world!\n');
%   end
%
%   function [releaser, params] = opener(params)
%      params.fid = fopen(filename)
%      if params.fid < -1
%           error('could not open file');
%      end
%      releaser = @()close(fid);
%   end
%
% WHY THIS EXISTS: MATLAB's silly lack of a 'finally' clause or anything
% equivalent (e.g. the RAII idiom in C++) combined with a lot of
% boilerplate device-and-file-and-window-opening code in psychtoolbox
% scripts -- which is generally not written robustly, and should be
% collapsible down to a single command. Resource
% management is tricky even if you have good exception handling at your
% disposal; I want to encapsulate most of the tricky exception handling.

i = 1; %tracks how far we got into requires
releaser_list = varargin;
theError = [];
[varargout{1:nargout}] = inner_require();

    function varargout = inner_require()
        %why is there an inner? because there needs to be some data passed
        %into the onCleanup handler in case it needs to fire.
        if isstruct(releaser_list{1})
            params = releaser_list{1};
            releaser_list(1) = [];
        else
            params = struct();
        end

        if (numel(releaser_list) < 1)
            error('require:illegalArgument', 'require needs at least 1 function handle');
        end
        cu = onCleanup(@cleaner);

        try
            while i < numel(releaser_list)
                if ~isa(releaser_list{i}, 'function_handle')
                    error('require:badInitializer', 'initializer must be a function handle');
                end
                
                if nargin(releaser_list{i}) == 0
                    releaser_list{i}(); %probably it's a rogue releaser, call it anyway.
                    error('require:notEnoughInputs', 'Initializers must take a struct input. Did you call the initializer by leaving off an @-sign?');
                else
                    if nargout(releaser_list{i}) > 2
                        %a initializer can also give a 'next initializer' as output.
                        %This switches on nargout, whcih is fail, but better than
                        %nothing.
                        [releaser_list{i}, params, next] = releaser_list{i}(params);
                        releaser_list = cat(1, releaser_list(1:i), {next}, releaser_list(i+1:end));
                    else
                        [releaser_list{i}, params] = releaser_list{i}(params);
                    end
                    
                    if ~isa(releaser_list{i}, 'function_handle')
                        error('require:missingReleaser', 'initializer did not produce a releaser');
                    end
                    
                end
                i = i + 1;
            end
            
            %then run the body, catching exceptions.
            body = releaser_list{i};
            if nargin(body) ~= 0
                [varargout{1:nargout}] = body(params);
            else
                [varargout{1:nargout}] = body();
            end
            
        catch gotError
            theError = gotError;
        end
        
        cleaner();
    end

    function cleaner
        %now, whether or not there was en error, go back and release everything in
        %reverse order.
        while (i > 1)
            i = i - 1;
            try
                releaser_list{i}(); %release
            catch releasingError
                if ~isempty(theError)
                    releasingError = releasingError.addCause(theError);
                end
                theError = releasingError;
            end
        end
        
        if ~isempty(theError)
            toThrow = theError;
            theError = []; %so that it doesn't get also thrown in cleanup unless it needs to.
            rethrow(toThrow);
        end
    end
end