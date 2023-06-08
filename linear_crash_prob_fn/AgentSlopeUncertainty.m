function [signalerAnticipatedCrashProb, realizedCrashProb, signalerAnticipatedEqs, agentAnticipatedEqs, signalerAnticipatedSocialCost, realizedSocialCost] = AgentSlopeUncertainty(worldParams, granularity)
	% Goal of this script: Assume crash prob is linear: p(x) = ax + b.
	% Agents think they know the value of a, call it a_* (Signaling designer
	% knows the true value). Signaling designer calculates optimal (accident
	% minimizing) value of beta for the true value of a.
	% Agents then make behavior decisions using their guessed value a_* and the
	% chosen value of beta. We calculate the new accident probability caused
	% by the "bad guess" by the agents.
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint32{mustBePositive} = 100
	end
	arguments (Output)
		signalerAnticipatedCrashProb double
		realizedCrashProb double
		signalerAnticipatedEqs double
		agentAnticipatedEqs double
		signalerAnticipatedSocialCost SocialCost
		realizedSocialCost SocialCost
	end

	% Aliases
	yInt = worldParams.yInt;
	V2VMass = worldParams.V2VMass;
	crashCost = worldParams.crashCost;
	trueSignalProbFn = worldParams.trueSignalProbFn;
	falseSignalProbFn = worldParams.falseSignalProbFn;

	% Calculate optimal beta for each true value of a
	slopes = linspace(0, 1-yInt, granularity);
	trueParams = WorldParams(slopes, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[chosenBeta, signalerAnticipatedCrashProb, signalerAnticipatedEqs] = GetOptimalBeta(trueParams);
	signalerAnticipatedSocialCost = GetSocialCost(trueParams, chosenBeta, GetEqBehavior(trueParams, chosenBeta), signalerAnticipatedCrashProb);

	signalerAnticipatedCrashProb = repmat(squeeze(signalerAnticipatedCrashProb), granularity, 1).';

	% Get agent behavior decisions for incorrect guesses of a
	[assumedSlopeMat, betaMat] = meshgrid(slopes, chosenBeta); % Note: we swapped the order of the meshgrid from signaler uncertainty to keep assumption on horiz axis
	assumedParams = WorldParams(assumedSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[inducedBehavior, agentAnticipatedEqs] = GetEqBehavior(assumedParams, betaMat);

	% Calculate loss from agents assumming wrong slope
	actualSlopeMat = assumedSlopeMat.'; % Transpose to get Cartesian product
	trueParamsMat = WorldParams(actualSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	realizedCrashProb = GetCrashProb(trueParamsMat, inducedBehavior, betaMat);
	realizedSocialCost = GetSocialCost(trueParamsMat, chosenBeta, inducedBehavior, realizedCrashProb);
end