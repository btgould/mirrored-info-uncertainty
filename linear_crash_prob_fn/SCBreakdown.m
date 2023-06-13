function SCBreakdown(worldParams)
	% Calculates social cost under both signaler and agent uncertainty
	% about the slope of p(x), and displays it in a new figure. For
	% analysis, social cost is subdivided into costs from regret and
	% costs from accidents.
	figure;

	[~, realizedOutcome] = SignalerSlopeUncertainty(worldParams);

	subplot(1, 2, 1);
	hold on;
	surf(realizedOutcome.socialCost.regretCost, "FaceColor", "blue");
	surf(realizedOutcome.socialCost.accidentCost, "FaceColor", "red");
	title("Social Cost for Signaler Uncertainty");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Social Cost");
	legend("Regret Cost", "Accident Cost");

	[~, ~, realizedOutcome] = AgentSlopeUncertainty(worldParams);

	subplot(1, 2, 2);
	hold on;
	surf(realizedOutcome.socialCost.regretCost, "FaceColor", "blue");
	surf(realizedOutcome.socialCost.accidentCost, "FaceColor", "red");
	title("Social Cost for Agent Uncertainty");
	xlabel("Assumed Slope");
	ylabel("Actual Slope");
	zlabel("Social Cost");
	legend("Regret Cost", "Accident Cost");
end