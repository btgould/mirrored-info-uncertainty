function [crashProbWCertainty, crashProbWUncertainty] = SignalerSlopeUncertainty(worldParams, granularity)
	% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
	% Signaling designer thinks they know the value of a, call it a_*. We then
	% calculate the optimal (accident minimizing) value of beta assuming p(x) =
	% a_*x + b.
	% Then, we calculate the accident probabilities induced by this beta for
	% values of a != a_*, and plot the increase in accident probability caused
	% by the "bad guess" by the signaling designer.
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint32{mustBePositive} = 100
	end
	arguments (Output)
		crashProbWCertainty double
		crashProbWUncertainty double
	end

	% Aliases
	yInt = worldParams.yInt;
	V2VMass = worldParams.V2VMass;
	crashCost = worldParams.crashCost;
	trueSignalProbFn = worldParams.trueSignalProbFn;
	falseSignalProbFn = worldParams.falseSignalProbFn;

	% Calculate optimal beta for each assumed slope
	slopes = linspace(0, 1-yInt, granularity);
	assumedParams = WorldParams(slopes, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[optimalBeta, optimalCrashProb] = GetOptimalBeta(assumedParams);
	crashProbWCertainty = repmat(squeeze(optimalCrashProb), granularity, 1).';

	% Calculate loss of assumed optimal beta on different slopes
	[betaMat, slopeMat] = meshgrid(optimalBeta, slopes);
	trueParams = WorldParams(slopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	inducedBehavior = GetEqBehavior(trueParams, betaMat);
	crashProbWUncertainty = GetCrashProb(trueParams, inducedBehavior, betaMat);
end
