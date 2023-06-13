function [signalerAnticipatedOutcome, agentAnticipatedOutcome, realizedOutcome] = AgentSlopeUncertainty(worldParams, granularity)
	% Assumes crash prob is linear and p(x) = ax + b.
	% Agents think they know the value of a, call it a_* (Signaling designer
	% knows the true value). Signaling designer calculates optimal (accident
	% minimizing) value of beta for the true value of a. (Implicitly, the
	% signaler assumes agents also know the true value of a and will react
	% accordingly to determine the "optimal" value of beta.)
	%
	% Agents then make behavior decisions using their guessed value a_* and the
	% chosen value of beta.
	%
	% We return the outcomes anticipated by both signaler and agents, as
	% well as the realized outcome. The signaler anticipated outcome is not
	% exact because agents do NOT know the true value of a, and so make
	% behavior decision that were not anticipated when the signaler chose
	% beta. The agent anticipated outcome is not exact because they do not
	% know the actual probability of accidents occuring. The realized
	% outcome takes into account the chosen beta, actual actions of the
	% agents, and the actual probability of accidents.
	%
	% Since the agents are not actually capable of minimizing their own
	% cost functions (due to a mistaken belief about accident frequency),
	% the realized behavior is not accurately described by any of our
	% equilibria. In a sense, it is still an equilibrium, but only if we
	% consider modified agent cost functions to incorporate uncertainty.
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint32{mustBePositive} = 100
	end
	arguments (Output)
		signalerAnticipatedOutcome(1, 1) Outcome
		agentAnticipatedOutcome(1, 1) Outcome
		realizedOutcome(1, 1) Outcome
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
	signalerAnticipatedBehavior = GetEqBehavior(trueParams, chosenBeta);
	signalerAnticipatedSocialCost = GetSocialCost(trueParams, chosenBeta, signalerAnticipatedBehavior, signalerAnticipatedCrashProb);

	signalerAnticipatedCrashProb = repmat(squeeze(signalerAnticipatedCrashProb), granularity, 1).';

	signalerAnticipatedOutcome = Outcome(chosenBeta, signalerAnticipatedEqs, ...
		signalerAnticipatedBehavior, signalerAnticipatedCrashProb, signalerAnticipatedSocialCost);

	% Get agent behavior decisions for incorrect guesses of a
	[assumedSlopeMat, betaMat] = meshgrid(slopes, chosenBeta); % Note: we swapped the order of the meshgrid from signaler uncertainty to keep assumption on horiz axis
	assumedParams = WorldParams(assumedSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	[inducedBehavior, agentAnticipatedEqs] = GetEqBehavior(assumedParams, betaMat);
	agentAnticipatedCrashProb = GetCrashProb(assumedParams, inducedBehavior, chosenBeta);
	agentAnticipatedSocialCost = GetSocialCost(assumedParams, chosenBeta, inducedBehavior, agentAnticipatedCrashProb);

	agentAnticipatedOutcome = Outcome(chosenBeta, agentAnticipatedEqs, ...
		inducedBehavior, agentAnticipatedCrashProb, agentAnticipatedSocialCost);

	% Calculate loss from agents assumming wrong slope
	actualSlopeMat = assumedSlopeMat.'; % Transpose to get Cartesian product
	trueParamsMat = WorldParams(actualSlopeMat, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
	realizedCrashProb = GetCrashProb(trueParamsMat, inducedBehavior, betaMat);
	realizedSocialCost = GetSocialCost(trueParamsMat, chosenBeta, inducedBehavior, realizedCrashProb);

	realizedOutcome = Outcome(chosenBeta, 8, inducedBehavior, ...
		realizedCrashProb, realizedSocialCost);
end