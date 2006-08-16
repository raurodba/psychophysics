function this = EyeEvents(calibration_, el_)
%function this = EyeEvents(calibration, el)
%
% Makes an object for tracking eye movements, and
% triggering calls when the eye moves in and out of screen-based regions.
%
% Constructor arguments:
%   'calibration' the display calibration
%   'el' the eyelink constants
%
% complaint:
% (why pass around a bunch of constants as an argument?)

%----- constructor - checks a condition and returns the appropriate event
%----- producer. Note that you don't need a Factory class for this, just
%----- the regular constructor.
connection = Eyelink('IsConnected');
switch connection
    case el_.connected
        [this, spaceEvents_] = inherit(SpaceEvents(calibration_), public(@sample, @start, @stop));
    case el_.dummyconnected
        warning('EyeEvents:usingMouse', 'using mouse movements, not eyes');
        this = MouseEvents(calibration_);
    otherwise
        error('eyeEvents:not_connected', 'eyelink not connected');
end

%----- method definition -----
    function [x, y, t] = sample
        %obtain a new sample from the eye.
        %poll on the presence of a sample (FIXME do I really want this?)
        while Eyelink('NewFloatSampleAvailable') == 0;
        end

        % FIXME: don't need to do this eyeAvailable check every
        % frame. Profile this.
        eye = Eyelink('EyeAvailable');
        switch eye
            case el_.BINOCULAR
                error('eyeEvents:binocular',...
                    'don''t know which eye to use for events');
            case el_.LEFT_EYE
                eyeidx = 1;
            case el_.RIGHT_EYE
                eyeidx = 2;
        end

        sample = Eyelink('NewestFloatSample')
        [x, y, t] = deal(...
            sample.gx(eyeidx), sample.gy(eyeidx), sample.time / 1000);
    end

    function start()
        spaceEvents_.start();
        Eyelink('StartRecording')
    end

    function stop()
        Eyelink('StopRecording');
        spaceEvents_.stop();
    end

end