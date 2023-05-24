function [beta, crashProb] = GetOptimalBeta(worldParams)
    arguments (Input)
        worldParams WorldParams
    end
    arguments (Output)
        beta double
        crashProb double
    end

    crashProbs = squeeze(zeros(cat(2, 2, size(worldParams.slope))));
    for beta = [0, 1]
        behavior = GetEqBehavior(worldParams, beta);
        crashProbs(beta+1, :) = GetCrashProb(worldParams, behavior, beta);
    end

    [crashProb, beta] = min(crashProbs);
    beta = beta - 1; % Adjusts for offset caused by matlab's one indexing
end