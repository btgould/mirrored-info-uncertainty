function loss = GetLossFromUncertainty(worldParams, granularity)
	arguments (Input)
		worldParams(1, 1) WorldParams
		granularity(1, 1) uint16{mustBePositive} = 100
	end
	arguments (Output)
		loss double{mustBeNonnegative}
	end

	% Calculate worst case slope for each slope and uncertainty radius
	slopes = linspace(0, 1-worldParams.yInt, granularity);
	uncertaintyRadii = linspace(0, 1-worldParams.yInt, granularity);
	[slopeMat, uncertaintyMat] = meshgrid(slopes, uncertaintyRadii);
	worstCaseSlopes = slopeMat + uncertaintyMat;

	% Cap slope assumptions within feasible range
	worstCaseSlopes(worstCaseSlopes > 1-worldParams.yInt) = 1 - worldParams.yInt;

	% Calculate accident probabilty induced by uncertainty
	realWP = worldParams.Copy().UpdateSlope(slopeMat);
	worstCaseWP = worldParams.Copy().UpdateSlope(worstCaseSlopes);
	chosenBeta = GetOptimalBeta(worstCaseWP);
	realizedBehavior = GetEqBehavior(realWP, chosenBeta);
	realizedCP = GetCrashProb(realWP, realizedBehavior, chosenBeta);

	% Calculate loss
	[~, optimalCP] = GetOptimalBeta(realWP);
	loss = realizedCP - optimalCP;
end