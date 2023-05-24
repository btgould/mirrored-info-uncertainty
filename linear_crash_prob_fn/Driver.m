yInt = 0.1;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
V2VMass = 0.9;
crashCost = 3;

%% Signaler Uncertainty
[crashProbWCertainty, crashProbWUncertainty] = SignalerSlopeUncertainty(yInt, trueSignalProbFn, falseSignalProbFn, V2VMass, crashCost);
loss = crashProbWUncertainty - crashProbWCertainty;

% Plot
figure;
heatmap(loss);
title("Loss Caused by Signaler Slope Uncertainty")
xlabel("Assumed slope");
ylabel("Actual slope");

%% Agent Uncertainty
[crashProbWCertainty, crashProbWUncertainty] = AgentSlopeUncertainty(yInt, trueSignalProbFn, falseSignalProbFn, V2VMass, crashCost);
loss = crashProbWUncertainty - crashProbWCertainty;

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