clear;
worldParams = WorldParams(0, 0.1, 0.9, 3, @(y) 0.8.*y, @(y) 0.1.*y);

uifig = uifigure();
g = uigridlayout(uifig, [3, 2]);
g.ColumnWidth = {'1x', '2x'};
g.RowHeight = {50, 50, 50};

% Sliders and labels
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
uiHeatmaps.signalerHeatmap = heatmap(signalerFig, 0, "GridVisible", false);
title("Loss Caused by Signaler Slope Uncertainty")
xlabel("Assumed slope");
ylabel("Actual slope");

% Agent heatmaps
agentFig = figure();
agentFig.Position(3) = 1120;

subplot(1, 2, 1);
uiHeatmaps.agentLossHeatmap = heatmap(0, "GridVisible", false);
title("Loss Caused by Agent Slope Uncertainty");
xlabel("Assumed slope");
ylabel("Actual slope");

subplot(1, 2, 2);
uiHeatmaps.agentBenefitHeatmap = heatmap(0, "GridVisible", false);
title("Where Agent Slope Uncertainty is Beneficial");
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
	[crashProbWCertainty, crashProbWUncertainty] = SignalerSlopeUncertainty(worldParams);
	signalerLoss = crashProbWUncertainty - crashProbWCertainty;
	uiHeatmaps.signalerHeatmap.ColorData = signalerLoss;

	[crashProbWCertainty, crashProbWUncertainty] = AgentSlopeUncertainty(worldParams);
	agentLoss = crashProbWUncertainty - crashProbWCertainty;
	uiHeatmaps.agentLossHeatmap.ColorData = agentLoss;
	uiHeatmaps.agentBenefitHeatmap.ColorData = double(agentLoss < 0);

	% Renormalize colormap
	colors = [255, 75, 75; 255, 255, 255; 1, 114, 189] ./ 255;
	samples = [min(agentLoss, [], 'all'), 0, max(agentLoss, [], 'all')];
	if min(agentLoss, [], 'all') >= 0
		samples = samples(2:end);
		colors = colors(2:end, :);
	end
	if max(agentLoss, [], 'all') <= 0
		samples = samples(1:end-1);
		colors = colors(1:end-1, :);
	end
	if size(samples, 2) > 1
		map = interp1(samples, colors, linspace(min(agentLoss, [], 'all'), max(agentLoss, [], 'all'), size(agentLoss, 1)));
	else
		map = [1, 1, 1];
	end
	uiHeatmaps.agentLossHeatmap.Colormap = map;

	drawnow;
end
