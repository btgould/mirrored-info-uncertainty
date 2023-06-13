function [signalerAnticipatedOutcome, realizedOutcome] = SignalerSlopeUncertainty(worldParams, granularity)
	% Assumes crash prob is linear: p(x) = ax + b.
	% Signaling designer thinks they know the value of a, call it a_*. We then
	% calculate the optimal (accident minimizing) value of beta assuming p(x) =
	% a_*x + b.
	%
	% Then, we consider the possibility that the true slope is a != a_*.
	% This true slope is known to the agents. Using the beta chosen by the
	% signaler, and the true slope, agents make a behavior decision. The
	% accident probability induced by this behavior is calculated so that
	% it can be compared to the accident probability that could have been
	% achieved if the signaler had accurately known a.
	%
	% We return both the outcome anticipated by the signaler (which is not
	% accurate because they do not know the true probability of accidents),
	% and the realized outcome given the behavior chosen by agents.
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint32{mustBePositive} = 100
	end
	arguments (Output)
		signalerAnticipatedOutcome(1, 1) Outcome
		realizedOutcome(1, 1) Outcome
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
	anticipatedBehavior = GetEqBehavior(assumedParams, chosenBeta);
	anticipatedSocialCost = GetSocialCost(assumedParams, chosenBeta, anticipatedBehavior, anticipatedCrashProb);
	anticipatedCrashProb = repmat(squeeze(anticipatedCrashProb), granularity, 1).';

	signalerAnticipatedOutcome = Outcome(chosenBeta, anticipatedEqs, ...
		anticipatedBehavior, anticipatedCrashProb, anticipatedSocialCost);

	% Calculate loss of assumed optimal beta on different slopes
	[betaMat, slopeMat] = meshgrid(chosenBeta, slopes);
	trueParams = WorldParams(slopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[inducedBehavior, realizedEqs] = GetEqBehavior(trueParams, betaMat);
	realizedCrashProb = GetCrashProb(trueParams, inducedBehavior, betaMat);
	realizedSocialCost = GetSocialCost(trueParams, betaMat, inducedBehavior, realizedCrashProb);

	realizedOutcome = Outcome(chosenBeta, realizedEqs, inducedBehavior, ...
		realizedCrashProb, realizedSocialCost);
end
