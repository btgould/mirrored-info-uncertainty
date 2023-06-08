function [anticipatedCrashProb, realizedCrashProb, anticipatedEqs, realizedEqs, anticipatedSocialCost, realizedSocialCost] = SignalerSlopeUncertainty(worldParams, granularity)
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
		anticipatedCrashProb double
		realizedCrashProb double
		anticipatedEqs double
		realizedEqs double
		anticipatedSocialCost SocialCost
		realizedSocialCost SocialCost
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
	[chosenBeta, anticipatedCrashProb, anticipatedEqs] = GetOptimalBeta(assumedParams);
	anticipatedSocialCost = GetSocialCost(assumedParams, chosenBeta, GetEqBehavior(assumedParams, chosenBeta), anticipatedCrashProb);

	anticipatedCrashProb = repmat(squeeze(anticipatedCrashProb), granularity, 1).';

	% Calculate loss of assumed optimal beta on different slopes
	[betaMat, slopeMat] = meshgrid(chosenBeta, slopes);
	trueParams = WorldParams(slopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[inducedBehavior, realizedEqs] = GetEqBehavior(trueParams, betaMat);
	realizedCrashProb = GetCrashProb(trueParams, inducedBehavior, betaMat);
	realizedSocialCost = GetSocialCost(trueParams, betaMat, inducedBehavior, realizedCrashProb);
end
