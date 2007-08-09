function e = DoubleSaccade(varargin)
    params = struct...
        ( 'edfname',    '' ...
        , 'dummy',      0  ...
        , 'skipFrames', 1  ...
        , 'requireCalibration', 0 ...
        , 'filename', '' ...
        , 'subject', 'zzz' ...
        , 'logfile', '' ...
        , 'priority', 9 ...
        , 'hideCursor', 0 ...
        , 'diagnostics', 0 ...
        );
    params = namedargs(params, varargin{:});
    
    e = Experiment('trials', DoubleSaccadeTrialGenerator(), params);
    
    e.run();
end