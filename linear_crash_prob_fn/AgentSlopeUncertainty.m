% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
% Agents think they know the value of a, call it a_* (Signaling designer
% knows the true value). Signaling designer calculates optimal (accident
% minimizing) value of beta for the true value of a. 
% Agents then make behavior decisions using their guessed value a_* and the
% chosen value of beta. We plot the increase in accident probability caused
% by the "bad guess" by the agents. 

clear;

b = 0.1;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
V2VMass = 0.9;
crashCost = 3;

granularity= 100;

% Calculate optimal beta for each true value of a 
slopes = linspace(0, 1-b, granularity);
[optimalBeta, optimalCrashProb] = GetOptimalBeta(slopes, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);

% Get agent behavior decisions for incorrect guesses of a 
[assumedSlopeMat, betaMat] = meshgrid(slopes, optimalBeta); % Note: we swapped the order of the meshgrid from signaler uncertainty to keep assumption on horix axis 
actualSlopeMat = assumedSlopeMat.';
[inducedxn, inducedxvu, inducedxvs] = GetEqBehavior(assumedSlopeMat, b, betaMat, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);

% Calculate loss from agents assumming wrong slope
inducedCrashProb = GetCrashProb(actualSlopeMat, b, inducedxn, inducedxvu, inducedxvs, trueSignalProbFn, falseSignalProbFn, V2VMass, betaMat); 
loss = inducedCrashProb - repmat(squeeze(optimalCrashProb), 100, 1).';

% Plot
figure
heatmap(loss);
title("Loss Caused by Agent Slope Uncertainty");
xlabel("Assumed slope");
ylabel("Actual slope");

figure
heatmap(double(loss < 0));
title("Where Agent Slope Uncertainty is Beneficial");
xlabel("Assumed slope");
ylabel("Actual slope");