function SignalerSlopeUncertainty(yInt, trueSignalProbFn, falseSignalProbFn, V2VMass, crashCost, granularity)
	% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
	% Signaling designer thinks they know the value of a, call it a_*. We then
	% calculate the optimal (accident minimizing) value of beta assuming p(x) =
	% a_*x + b.
	% Then, we calculate the accident probabilities induced by this beta for
	% values of a != a_*, and plot the increase in accident probability caused
	% by the "bad guess" by the signaling designer.
	arguments (Input)
		yInt double{mustBeInRange(yInt, 0, 1, "exclude-upper")}
		trueSignalProbFn(1, 1) function_handle
		falseSignalProbFn(1, 1) function_handle
		V2VMass double{mustBeInRange(V2VMass, 0, 1)}
		crashCost double{mustBeGreaterThan(crashCost, 1)}
		granularity(1, 1) uint32 {mustBePositive} = 100
	end

	% Calculate optimal beta for each assumed slope
	slopes = linspace(0, 1-yInt, granularity);
	assumedParams = WorldParams(slopes, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[optimalBeta, optimalCrashProb] = GetOptimalBeta(assumedParams);

	% Calculate loss of assumed optimal beta on different slopes
	[betaMat, slopeMat] = meshgrid(optimalBeta, slopes);
	trueParams = WorldParams(slopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	inducedBehavior = GetEqBehavior(trueParams, betaMat);
	inducedCrashProb = GetCrashProb(trueParams, inducedBehavior, betaMat);
	loss = inducedCrashProb - repmat(squeeze(optimalCrashProb), granularity, 1).';

	% Plot
    figure;
	heatmap(loss);
	xlabel("Assumed slope");
	ylabel("Actual slope");
end


% yInt = 0.1;
% trueSignalProbFn = @(y) 0.8 .* y;
% falseSignalProbFn = @(y) 0.1 .* y;
% V2VMass = 0.9;
% crashCost = 3;