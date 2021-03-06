function skipDiagnostic(varargin)
    %remembers what the last logging argument was, and spits out hte
    %logging argument that preceded a frame skip immediately.
    persistent last;
    
    global split;
    global N;
    global total;
    
    new = sprintf(varargin{:});
    if ~isempty(strmatch('FRAME_SKIP', new)) && isempty(strmatch('FRAME_SKIP', last))
        disp([new ' ' last]); % sprintf('split %f avg %f ', split, total/N) 
    end
    last = new;
end