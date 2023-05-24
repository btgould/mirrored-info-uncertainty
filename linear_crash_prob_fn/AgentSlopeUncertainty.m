function AgentSlopeUncertainty(yInt, trueSignalProbFn, falseSignalProbFn, V2VMass, crashCost, granularity)
	% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
	% Agents think they know the value of a, call it a_* (Signaling designer
	% knows the true value). Signaling designer calculates optimal (accident
	% minimizing) value of beta for the true value of a.
	% Agents then make behavior decisions using their guessed value a_* and the
	% chosen value of beta. We plot the increase in accident probability caused
	% by the "bad guess" by the agents.
	arguments (Input)
		yInt double{mustBeInRange(yInt, 0, 1, "exclude-upper")}
		trueSignalProbFn(1, 1) function_handle
		falseSignalProbFn(1, 1) function_handle
		V2VMass double{mustBeInRange(V2VMass, 0, 1)}
		crashCost double{mustBeGreaterThan(crashCost, 1)}
		granularity(1, 1) uint32 {mustBePositive} = 100
	end

	% Calculate optimal beta for each true value of a
	slopes = linspace(0, 1-yInt, granularity);
	trueParams = WorldParams(slopes, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[optimalBeta, optimalCrashProb] = GetOptimalBeta(trueParams);

	% Get agent behavior decisions for incorrect guesses of a
	[assumedSlopeMat, betaMat] = meshgrid(slopes, optimalBeta); % Note: we swapped the order of the meshgrid from signaler uncertainty to keep assumption on horiz axis
	assumedParams = WorldParams(assumedSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	inducedBehavior = GetEqBehavior(assumedParams, betaMat);

	% Calculate loss from agents assumming wrong slope
	actualSlopeMat = assumedSlopeMat.';
	trueParamsMat = WorldParams(actualSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	inducedCrashProb = GetCrashProb(trueParamsMat, inducedBehavior, betaMat);
	loss = inducedCrashProb - repmat(squeeze(optimalCrashProb), granularity, 1).';

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
end

% Initial param set 
% yInt = 0.1;
% trueSignalProbFn = @(y) 0.8 .* y;
% falseSignalProbFn = @(y) 0.1 .* y;
% V2VMass = 0.9;
% crashCost = 3;
