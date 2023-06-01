function socialCost = GetSocialCost(worldParams, beta, behavior, crashProbs)
	arguments (Input)
		worldParams(1, 1) WorldParams
		beta double{mustBeInRange(beta, 0, 1)}
		behavior(1, 1) Behavior
		crashProbs double{mustBeInRange(crashProbs, 0, 1)}
	end
	arguments (Output)
		socialCost double
	end

	ty = worldParams.trueSignalProbFn(worldParams.V2VMass);
	fy = worldParams.falseSignalProbFn(worldParams.V2VMass);
	PAS = (ty .* crashProbs) ./ ((ty - fy) .* crashProbs + fy);
	PAnS = ((1 - beta .* ty) .* crashProbs) ./ (1 - beta .* ((ty - fy) .* crashProbs + fy));

	signalProbs = beta .* ((ty - fy) .* crashProbs + fy);

	socialCost = (behavior.xvs .* worldParams.crashCost .* PAS ...
		+(worldParams.V2VMass - behavior.xvs) .* (1 - PAS)) .* signalProbs ...
		+behavior.xn .* worldParams.crashCost .* crashProbs ...
		+(1 - worldParams.V2VMass - behavior.xn) .* (1 - crashProbs) ...
		+(behavior.xvu .* worldParams.crashCost .* PAnS ...
		+(worldParams.V2VMass - behavior.xvu) .* (1 - PAnS)) .* (1 - signalProbs);
end