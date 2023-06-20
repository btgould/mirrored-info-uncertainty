function PiecewiseSlopeMonotonicity(worldParams)
    % Assuming constant beta, y, and r, this script calculates the crash
    % probabilities induced by increasing the slope of p(x) (which is
    % assumed to be linear). I expect P(G) to be non-decreasing with this
    % slope. 
    arguments (Input)
        worldParams (1,1) WorldParams
    end

    beta = 0;

    [behavior, eq] = GetEqBehavior(worldParams, beta);
    crashProb = GetCrashProb(worldParams, behavior, beta);

    largerSlopes = linspace(worldParams.slope, 1 - worldParams.yInt, 100);
    worldParams = worldParams.Copy().UpdateSlope(largerSlopes);
    [largerBehaviors, largerEqs] = GetEqBehavior(worldParams, beta);
    largerCrashProbs = GetCrashProb(worldParams, largerBehaviors, beta);

    plot(largerCrashProbs);
end