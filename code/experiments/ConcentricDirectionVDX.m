function e = ConcentricDirection(varargin)

    params = namedargs ...
        ( localExperimentParams() ...
        , 'skipFrames', 1  ...
        , 'priority', 0 ...
        , 'hideCursor', 0 ...
        , 'doTrackerSetup', 1 ...
        , 'input', struct ...
            ( 'keyboard', KeyboardInput() ...
            , 'knob', PowermateInput() ...
            ) ...
        , 'eyelinkSettings.sample_rate', 250 ...
        , varargin{:});
    
    e = Experiment('params', params);

    e.trials.base = ConcentricTrial...
        ( 'fixationStartWindow', 3 ...
        , 'fixationSettle', 0.3 ...
        , 'fixationWindow', 2 ...
        , 'motion', CauchySpritePlayer ...
            ( 'process', CircularCauchyMotion ...
                ( 'radius', 8 ...
                , 'dt', 0.15 ...
                , 'dphase', 0.25/8 ...
                , 'x', 0 ...
                , 'y', 0 ...
                , 't', 0.5 ...
                , 'n', 4 ...
                , 'color', [0.5 0.5 0.5]' ...
                , 'velocity', 5 ... %velocity of peak spatial frequency
                , 'wavelength', 0.375 ...
                , 'width', 0.25 ...
                , 'duration', 0.1 ...
                , 'order', 4 ...
                ) ...
            ) ...
        );
    
    e.trials.interTrialInterval = 0.5;
        %what worked well in the wheels demo is 0.75 dx, 0.75 wavelength, 0.15
    %dt, 5 velocity at 14 radius! The crowding was 3.1 degrees!
    %This scales down to ... less than that at 8 degrees. Chop everything
    %to two thirds.
    
    %randomize global dx and local wavelength, and velocity takes care of
    %itself later...
    e.trials.add({'extra.dx', 'motion.process.wavelength'}, ...
        { {-.75   0.5625} ...
        , {-0.5   0.375 } ...
        , {-1/3   0.25  } ...
        , { 1/3   0.25  } ...
        , { 0.5   0.375 } ...
        , { .75   0.5625} ...
        } );
    
    e.trials.add('motion.process.dphase', @(b)b.extra.dx ./ b.motion.process.radius);

    e.trials.add('extra.nTargets', [8 9 11 13 16 23]);
    e.trials.add('motion.process.phase', @(b) mod(rand()*2*pi + (0:b.extra.nTargets-1)/b.extra.nTargets*2*pi, 2*pi));
    e.trials.add('awaitInput', @(b) max(b.motion.process.t + b.motion.process.dt .* (b.motion.process.n + 1)));
    
    %supporting, opposing, and ambiguous.
    %The ambiguous motion is made up of two opposing motions superimposed,
    %so we have to double the elements (and halve the contrast) for that
    %one.
    e.trials.add...
        ( {'extra.relativeVelocity', 'motion.process.color', 'motion.process.phase'} ...
        , { {-1, [0.5;0.5;0.5]/sqrt(2), @(b)b.motion.process.phase}...
          , {@(b)reshape(repmat([-1 1], numel(b.motion.process.phase), 1), 1, []), [.25;.25;.25], @(b)repmat(b.motion.process.phase, 1, 2)}...
          , {1, [0.5;0.5;0.5]/sqrt(2), @(b)b.motion.process.phase} } );
      
    e.trials.add('motion.process.angle', @(b) mod(b.motion.process.phase * 180/pi + 90, 360));

    e.trials.add('motion.process.velocity', @(b)b.extra.dx ./ b.motion.process.dt .* b.extra.relativeVelocity);
    
    %pick a number of targets, and spread them around the circle
    %say, a spacing of 2 to 10 degrees...

    %say, 16 samples for each N, after folding directions?
    e.trials.reps = 8;
    e.trials.blockSize = 144;
    
    e.trials.fullFactorial = 1;

    e.trials.startTrial = MessageTrial('message', @()sprintf('Use knob to indicate direction of rotation.\nPress knob to begin.\n%d blocks in experiment', e.trials.blocksLeft()));
    e.trials.endBlockTrial = MessageTrial('message', @()sprintf('Press knob to continue.\n%d blocks remain', e.trials.blocksLeft()));
    e.trials.blockTrial = EyeCalibrationMessageTrial...
        ( 'minCalibrationInterval', 0 ...
        , 'base.absoluteWindow', 100 ...
        , 'base.maxLatency', 0.5 ...
        , 'base.fixDuration', 0.5 ...
        , 'base.fixWindow', 4 ...
        , 'base.rewardDuration', 10 ...
        , 'base.settleTime', 0.3 ...
        , 'base.targetRadius', 0.2 ...
        , 'base.onset', 0 ...
        , 'maxStderr', 0.5 ...
        , 'minN', 10 ...
        , 'maxN', 50 ...
        , 'interTrialInterval', 0.4 ...
        );
    e.trials.endTrial = MessageTrial('message', sprintf('All done!\nPress knob to save and exit.\nThanks!'));
end