function loss = GetLossFromAgentUncertainty(worldParams, granularity)
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint16{mustBePositive} = 100
	end
	arguments (Output)
		loss double
	end

	% Calculate worst case slope for each slope and uncertainty radius
	slopes = linspace(0, 1-worldParams.yInt, granularity);
	uncertaintyRadii = linspace(0, 1-worldParams.yInt, granularity);
	[slopeMat, uncertaintyMat] = meshgrid(slopes, uncertaintyRadii);
	worstCaseSlopes = slopeMat - uncertaintyMat;

	% Cap slope assumptions within feasible range
	worstCaseSlopes(worstCaseSlopes < 0) = 0;

	% Calculate accident probabilty induced by uncertainty
	agentBelievedWP = worldParams.Copy().UpdateSlope(slopeMat);
	worstCaseWP = worldParams.Copy().UpdateSlope(worstCaseSlopes);
	chosenBeta = GetOptimalBeta(worstCaseWP);
	realizedBehavior = GetEqBehavior(agentBelievedWP, chosenBeta);
	realizedCP = GetCrashProb(worldParams, realizedBehavior, chosenBeta);

	% Calculate loss
	[~, crashProbUnderCertainty] = GetOptimalBeta(worldParams);
	loss = realizedCP - crashProbUnderCertainty;
end