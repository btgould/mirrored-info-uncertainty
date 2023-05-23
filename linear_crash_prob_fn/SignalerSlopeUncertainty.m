% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
% Signaling designer thinks they know the value of a, call it a_*. We then
% calculate the optimal (accident minimizing) value of beta assuming p(x) =
% a_*x + b. 
% Then, we calculate the accident probabilities induced by this beta for
% values of a != a_*, and plot the increase in accident probability caused
% by the "bad guess" by the signaling designer. 
clear;

b = 0.1;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
V2VMass = 0.9;
crashCost = 3;

granularity= 100;

% Calculate optimal beta for each assumed slope 
slopes = linspace(0, 1-b, granularity);
[optimalBeta, optimalCrashProb] = GetOptimalBeta(slopes, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);

% Calculate loss of assumed optimal beta on different slopes
[betaMat, slopeMat] = meshgrid(optimalBeta, slopes);
[inducedxn, inducedxvu, inducedxvs] = GetEqBehavior(slopeMat, b, betaMat, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
inducedCrashProb = GetCrashProb(slopeMat, b, inducedxn, inducedxvu, inducedxvs, trueSignalProbFn, falseSignalProbFn, V2VMass, betaMat);
loss = inducedCrashProb - repmat(squeeze(optimalCrashProb), 100, 1).';

% Plot
fig = heatmap(loss);
xlabel("Assumed slope");
ylabel("Actual slope");
