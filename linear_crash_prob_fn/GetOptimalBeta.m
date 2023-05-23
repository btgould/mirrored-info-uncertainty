function [beta, crashProb] = GetOptimalBeta(a, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn)
    crashProbs = squeeze(zeros(cat(2, 2, size(a))));
    for beta = [0, 1]
        [xn, xvu, xvs] = GetEqBehavior(a, b, beta, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
        crashProbs(beta+1, :) = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta);
    end

    [crashProb, beta] = min(crashProbs);
    beta = beta - 1; % Adjusts for offset caused by matlab's one indexing
end