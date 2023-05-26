clear;
worldParams = WorldParams(0, 0.1, 0.9, 3, @(y) 0.8.*y, @(y) 0.1.*y);

% UI / control stuff
uifig = uifigure();
g = uigridlayout(uifig, [3, 2]);
g.ColumnWidth = {'1x', '2x'};
g.RowHeight = {50, 50, 50};

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

% Signaler heatmap
signalerFig = figure();
signalerFig.Position(3:4) = [1120, 720];

subplot(2, 2, 1);
uiHeatmaps.signalerHeatmap = heatmap(0, "GridVisible", false);
title("Loss Caused by Signaler Slope Uncertainty")
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(2, 2, 3);
uiHeatmaps.signalerActualEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Realized Equilibria")
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(2, 2, 4);
uiHeatmaps.signalerAssumedEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Signaler Assumed Equilibria")
xlabel("Assumed slope");
ylabel("Actual slope");

% Agent heatmaps
agentFig = figure();
agentFig.Position(3:4) = [1120, 720];

subplot(2, 2, 1);
uiHeatmaps.agentLossHeatmap = heatmap(0, "GridVisible", false);
title("Loss Caused by Agent Slope Uncertainty");
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(2, 2, 2);
uiHeatmaps.agentBenefitHeatmap = heatmap(0, "GridVisible", false);
title("Where Agent Slope Uncertainty is Beneficial");
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(2, 2, 3);
uiHeatmaps.agentActualEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Realized Equilibria");
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(2, 2, 4);
uiHeatmaps.agentAssumedEqHeatmap = heatmap(0, "GridVisible", false, "ColorLimits", [1, 7]);
title("Agent Assumed Equilibria"); % TODOL what are the axis titles actually here?
xlabel("Assumed slope");
ylabel("Actual slope");

UpdateLosses(uiHeatmaps, worldParams);

% Slider function hooks
yIntSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiHeatmaps, ...
	worldParams.UpdateYInt(event.Value));
V2VMassSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiHeatmaps, ...
	worldParams.UpdateV2VMass(event.Value));
crashCostSlider.ValueChangingFcn = @(src, event) UpdateLosses(uiHeatmaps, ...
	worldParams.UpdateCrashCost(event.Value));

%% Helper Functions
function UpdateLosses(uiHeatmaps, worldParams)
	% Recalculate data
	[crashProbWCertainty, crashProbWUncertainty, actualEqs, assumedEqs] = ...
		SignalerSlopeUncertainty(worldParams);
	signalerLoss = crashProbWUncertainty - crashProbWCertainty;
	uiHeatmaps.signalerHeatmap.ColorData = signalerLoss;
	uiHeatmaps.signalerActualEqHeatmap.ColorData = actualEqs;
	uiHeatmaps.signalerAssumedEqHeatmap.ColorData = assumedEqs;

	[crashProbWCertainty, crashProbWUncertainty, actualEqs, assumedEqs] = ...
		AgentSlopeUncertainty(worldParams);
	agentLoss = crashProbWUncertainty - crashProbWCertainty;
	uiHeatmaps.agentLossHeatmap.ColorData = agentLoss;
	uiHeatmaps.agentBenefitHeatmap.ColorData = double(agentLoss < 0);
	uiHeatmaps.agentActualEqHeatmap.ColorData = actualEqs;
	uiHeatmaps.agentAssumedEqHeatmap.ColorData = assumedEqs;

	% Renormalize colormaps
	colors = [255, 75, 75; 255, 255, 255; 1, 114, 189] ./ 255;
	points = [min(agentLoss, [], 'all'), 0, max(agentLoss, [], 'all')];
	lossMap = LabelledColormap(points, colors, agentLoss);
	uiHeatmaps.agentLossHeatmap.Colormap = lossMap;

	colors = [119, 3, 252; 0, 3, 255; 0, 255, 0; 255, 255, 255; ...
		252, 173, 3; 255, 0, 0; 244, 3, 252] ./ 255;
	points = [1, 2, 3, 4, 5, 6, 7];
	eqMap = LabelledColormap(points, colors, assumedEqs);
	uiHeatmaps.signalerActualEqHeatmap.Colormap = eqMap;
	uiHeatmaps.signalerAssumedEqHeatmap.Colormap = eqMap;
	uiHeatmaps.agentActualEqHeatmap.Colormap = eqMap;
	uiHeatmaps.agentAssumedEqHeatmap.Colormap = eqMap;

	drawnow;
end
