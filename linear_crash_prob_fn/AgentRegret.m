function AgentRegret(worldParams)
	% Calculates how much agents regret the decisions they made under
	% uncertainty about the slope of p(x). This regret is marginalized (over
	% agent type (xvu, xn, xvs) and regret type (careful or reckless)), and
	% plotted in a new figure.
	arguments (Input)
		worldParams(1, 1) WorldParams
	end

	[~, agentAnticipatedOutcome, realizedOutcome] = ...
		AgentSlopeUncertainty(worldParams);

	% Useful vars
	beta = realizedOutcome.beta;
	y = worldParams.V2VMass;
	ty = worldParams.trueSignalProbFn(y);
	fy = worldParams.falseSignalProbFn(y);
	PAS = (ty .* realizedOutcome.crashProb) ./ ((ty - fy) .* realizedOutcome.crashProb + fy);
	PAnS = ((1 - beta .* ty) .* realizedOutcome.crashProb) ./ ...
		(1 - beta .* ((ty - fy) .* realizedOutcome.crashProb + fy));

	% Unignaled V2V Regret
	realizedRecklessCost = worldParams.crashCost .* PAnS;
	realizedCarefulCost = 1 - PAnS;
	minCost = min(cat(3, realizedCarefulCost, realizedRecklessCost), [], 3);
	recklessRegret = realizedRecklessCost - minCost;
	carefulRegret = realizedCarefulCost - minCost;

	uV2VRIncurredCost = agentAnticipatedOutcome.behavior.xvu .* realizedRecklessCost;
	uV2VCIncurredCost = (y - agentAnticipatedOutcome.behavior.xvu) .* realizedCarefulCost;
	uV2VAgentIncurredCost = uV2VRIncurredCost + uV2VCIncurredCost;
	uV2VAgentRegret = uV2VAgentIncurredCost - (minCost .* y);
	uV2VRAgentRegret = recklessRegret .* agentAnticipatedOutcome.behavior.xvu;
	uV2VCAgentRegret = carefulRegret .* (y - agentAnticipatedOutcome.behavior.xvu);

	% Non-V2V Regret
	realizedRecklessCost = worldParams.crashCost .* realizedOutcome.crashProb;
	realizedCarefulCost = 1 - realizedOutcome.crashProb;
	minCost = min(cat(3, realizedCarefulCost, realizedRecklessCost), [], 3);
	recklessRegret = realizedRecklessCost - minCost;
	carefulRegret = realizedCarefulCost - minCost;

	nV2VRIncurredCost = agentAnticipatedOutcome.behavior.xn .* realizedRecklessCost;
	nV2VCIncurredCost = ((1 - y) - agentAnticipatedOutcome.behavior.xn) .* realizedCarefulCost;
	nV2VAgentIncurredCost = nV2VRIncurredCost + nV2VCIncurredCost;
	nV2VAgentRegret = nV2VAgentIncurredCost - (minCost .* (1 - y));
	nV2VRAgentRegret = recklessRegret .* agentAnticipatedOutcome.behavior.xn;
	nV2VCAgentRegret = carefulRegret .* ((1 - y) - agentAnticipatedOutcome.behavior.xn);

	% Signaled V2V Regret
	realizedRecklessCost = worldParams.crashCost .* PAS;
	realizedCarefulCost = 1 - PAS;
	minCost = min(cat(3, realizedCarefulCost, realizedRecklessCost), [], 3);
	recklessRegret = realizedRecklessCost - minCost;
	carefulRegret = realizedCarefulCost - minCost;

	sV2VRIncurredCost = agentAnticipatedOutcome.behavior.xvs .* realizedRecklessCost;
	sV2VCIncurredCost = (y - agentAnticipatedOutcome.behavior.xvs) .* realizedCarefulCost;
	sV2VAgentIncurredCost = sV2VRIncurredCost + sV2VCIncurredCost;
	sV2VAgentRegret = sV2VAgentIncurredCost - (minCost .* y);
	sV2VRAgentRegret = recklessRegret .* agentAnticipatedOutcome.behavior.xvs;
	sV2VCAgentRegret = carefulRegret .* (y - agentAnticipatedOutcome.behavior.xvs);

	% Display
	figure;
	subplot(2, 3, 1);
	surf(uV2VAgentRegret);
	title("Unsignaled V2V Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");

	subplot(2, 3, 2);
	surf(nV2VAgentRegret);
	title("Non-V2V Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");

	subplot(2, 3, 3);
	surf(sV2VAgentRegret);
	title("Signaled V2V Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");

	subplot(2, 3, 4);
	surf(uV2VCAgentRegret+nV2VCAgentRegret+sV2VCAgentRegret);
	title("Careful Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");

	subplot(2, 3, 5);
	surf(uV2VRAgentRegret+nV2VRAgentRegret+sV2VRAgentRegret);
	title("Reckless Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");

	subplot(2, 3, 6);
	surf(uV2VAgentRegret+nV2VAgentRegret+sV2VAgentRegret);
	title("Total Agent Regret");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Regret");
end