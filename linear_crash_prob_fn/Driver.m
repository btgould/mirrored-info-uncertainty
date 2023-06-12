clear;
worldParams = WorldParams(0, 0.1, 0.9, 3, @(y) 0.8.*y, @(y) 0.1.*y);

% UI / control stuff
uifig = uifigure();
g = uigridlayout(uifig, [6, 2]);
g.ColumnWidth = {'1x', '2x'};
g.RowHeight = {50, 50, 50, 50, 50, 50};

yIntLbl = uilabel(g, "Text", "y-intercept");
yIntLbl.Layout.Row = 1;
yIntLbl.Layout.Column = 1;
yIntSlider = uislider(g, "Limits", [0, 1]);
yIntSlider.Layout.Row = 1;
yIntSlider.Layout.Column = 2;
yIntSlider.Value = worldParams.yInt;

V2VMassLbl = uilabel(g, "Text", "V2V Mass");
V2VMassLbl.Layout.Row = 2;
V2VMassLbl.Layout.Column = 1;
V2VMassSlider = uislider(g, "Limits", [0, 1]);
V2VMassSlider.Layout.Row = 2;
V2VMassSlider.Layout.Column = 2;
V2VMassSlider.Value = worldParams.V2VMass;

crashCostLbl = uilabel(g, "Text", "Crash Cost");
crashCostLbl.Layout.Row = 3;
crashCostLbl.Layout.Column = 1;
crashCostSlider = uislider(g, "Limits", [1, 100]);
crashCostSlider.Layout.Row = 3;
crashCostSlider.Layout.Column = 2;
crashCostSlider.Value = worldParams.crashCost;

trueSpFnLbl = uilabel(g, "Text", "True Signal Prob Slope");
trueSpFnLbl.Layout.Row = 4;
trueSpFnLbl.Layout.Column = 1;
trueSpFnSlider = uislider(g, "Limits", [0, 1]);
trueSpFnSlider.Layout.Row = 4;
trueSpFnSlider.Layout.Column = 2;
trueSpFnSlider.Value = worldParams.trueSignalProbFn(1);
uiComponents.trueSpFnSlider = trueSpFnSlider;

falseSpFnLbl = uilabel(g, "Text", "False Signal Prob Slope");
falseSpFnLbl.Layout.Row = 5;
falseSpFnLbl.Layout.Column = 1;
falseSpFnSlider = uislider(g, "Limits", [0, trueSpFnSlider.Value]);
falseSpFnSlider.Layout.Row = 5;
falseSpFnSlider.Layout.Column = 2;
falseSpFnSlider.Value = worldParams.falseSignalProbFn(1);
uiComponents.falseSpFnSlider = falseSpFnSlider;

scBreakdownBtn = uibutton(g);
scBreakdownBtn.Layout.Row = 6;
scBreakdownBtn.Layout.Column = 1;
scBreakdownBtn.Text = "View Social Cost Breakdown";
scBreakdownBtn.ButtonPushedFcn = @(src, event) SCBreakdown(worldParams);

% Signaler heatmap
signalerFig = figure();
signalerFig.Position(3:4) = [1120, 720];

subplot(2, 2, 1);
uiComponents.signalerLossHeatmap = heatmap(0, "GridVisible", false);
title("Loss Caused by Signaler Slope Uncertainty")
xlabel("Assumed Slope");
ylabel("Actual Slope");

subplot(2, 2, 2);
uiComponents.signalerSCLossHeatmap = heatmap(0, "GridVisible", false);
title("SC Loss Caused by Signaler Slope Uncertainty");
xlabel("Assumed Slope");
ylabel("Actual Slope");

subplot(2, 2, 3);
uiComponents.surEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Realized Equilibria")
xlabel("Signaler Assumed Slope");
ylabel("Actual Slope");

subplot(2, 2, 4);
uiComponents.susaEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Signaler Anticipated Equilibria")
xlabel("Assumed Slope");

% Agent heatmaps
agentFig = figure();
agentFig.Position(3:4) = [1120, 720];

subplot(2, 2, 1);
uiComponents.agentLossHeatmap = heatmap(0, "GridVisible", false);
title("Loss Caused by Agent Slope Uncertainty");
xlabel("Assumed Slope");
ylabel("Actual Slope");

subplot(2, 2, 2);
uiComponents.agentSCLossHeatmap = heatmap(0, "GridVisible", false);
title("SC Loss Caused by Agent Slope Uncertainty");
xlabel("Assumed Slope");
ylabel("Actual Slope");

subplot(2, 2, 3);
uiComponents.ausaEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Signaler Anticipated Equilibria");
ylabel("Slope");

subplot(2, 2, 4);
uiComponents.auaaEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Agent Anticipated Equilibria");
xlabel("Agent Assumed Slope");
ylabel("Actual Slope");

UpdateLosses(uiComponents, worldParams);

% Slider function hooks
yIntSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiComponents, ...
	worldParams.UpdateYInt(event.Value));
V2VMassSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiComponents, ...
	worldParams.UpdateV2VMass(event.Value));
crashCostSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiComponents, ...
	worldParams.UpdateCrashCost(event.Value));
trueSpFnSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiComponents, ...
	worldParams.UpdateTrueSignalProbFn(@(y) event.Value.*y));
falseSpFnSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiComponents, ...
	worldParams.UpdateFalseSignalProbFn(@(y) event.Value.*y));

%% Helper Functions
function UpdateLosses(uiComponents, worldParams)
	% Recalculate data
	[signalerAnticipatedOutcome, realizedOutcome] = SignalerSlopeUncertainty(worldParams);
	signalerLoss = realizedOutcome.crashProb - signalerAnticipatedOutcome.crashProb;
	signalerSCLoss = realizedOutcome.socialCost.total - ...
		signalerAnticipatedOutcome.socialCost.total;
	uiComponents.signalerLossHeatmap.ColorData = signalerLoss;
	uiComponents.signalerSCLossHeatmap.ColorData = signalerSCLoss;
	uiComponents.surEqHeatmap.ColorData = realizedOutcome.eqs;
	uiComponents.susaEqHeatmap.ColorData = signalerAnticipatedOutcome.eqs;

	[signalerAnticipatedOutcome, agentAnticipatedOutcome, realizedOutcome] = ...
		AgentSlopeUncertainty(worldParams);
	agentLoss = realizedOutcome.crashProb - signalerAnticipatedOutcome.crashProb;
	agentSCLoss = realizedOutcome.socialCost.total - ...
		signalerAnticipatedOutcome.socialCost.total;
	uiComponents.agentLossHeatmap.ColorData = agentLoss;
	uiComponents.agentSCLossHeatmap.ColorData = agentSCLoss;
	uiComponents.ausaEqHeatmap.ColorData = signalerAnticipatedOutcome.eqs.';
	uiComponents.auaaEqHeatmap.ColorData = agentAnticipatedOutcome.eqs;

	% Renormalize colormaps
	colors = [255, 75, 75; 255, 255, 255; 1, 114, 189] ./ 255;
	points = [min(agentLoss, [], 'all'), 0, max(agentLoss, [], 'all')];
	lossMap = LabelledColormap(points, colors, agentLoss);
	uiComponents.agentLossHeatmap.Colormap = lossMap;

	points = [min(signalerSCLoss, [], 'all'), 0, max(signalerSCLoss, [], 'all')];
	lossMap = LabelledColormap(points, colors, signalerSCLoss);
	uiComponents.signalerSCLossHeatmap.Colormap = lossMap;

	points = [min(agentSCLoss, [], 'all'), 0, max(agentSCLoss, [], 'all')];
	lossMap = LabelledColormap(points, colors, agentSCLoss);
	uiComponents.agentSCLossHeatmap.Colormap = lossMap;

	colors = [119, 3, 252; 0, 3, 255; 0, 255, 0; 255, 255, 255; ...
		252, 173, 3; 255, 0, 0; 244, 3, 252] ./ 255;
	points = [1, 2, 3, 4, 5, 6, 7];
	eqMap = LabelledColormap(points, colors, signalerAnticipatedOutcome.eqs);
	uiComponents.surEqHeatmap.Colormap = eqMap;
	uiComponents.susaEqHeatmap.Colormap = eqMap;
	uiComponents.ausaEqHeatmap.Colormap = eqMap;
	uiComponents.auaaEqHeatmap.Colormap = eqMap;

	% Update limits of false positive rate slider
	uiComponents.falseSpFnSlider.Limits = [0, uiComponents.trueSpFnSlider.Value];

	drawnow;
end

function SCBreakdown(worldParams)
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
