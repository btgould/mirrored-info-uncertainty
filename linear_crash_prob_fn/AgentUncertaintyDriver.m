clear;

worldParams = WorldParams(0.7, 0.1, 0.9, 3, @(y) 0.8.*y, @(y) 0.1.*y);

% UI / control stuff
uifig = uifigure();
g = uigridlayout(uifig, [7, 2]);
g.ColumnWidth = {'1x', '2x'};
g.RowHeight = {50, 50, 50, 50, 50, 50, 50};

slopeLbl = uilabel(g, "Text", "slope");
slopeLbl.Layout.Row = 1;
slopeLbl.Layout.Column = 1;
slopeSlider = uislider(g, "Limits", [0, 1]);
slopeSlider.Layout.Row = 1;
slopeSlider.Layout.Column = 2;
slopeSlider.Value = worldParams.slope;

yIntLbl = uilabel(g, "Text", "y-intercept");
yIntLbl.Layout.Row = 2;
yIntLbl.Layout.Column = 1;
yIntSlider = uislider(g, "Limits", [0, 1]);
yIntSlider.Layout.Row = 2;
yIntSlider.Layout.Column = 2;
yIntSlider.Value = worldParams.yInt;

V2VMassLbl = uilabel(g, "Text", "V2V Mass");
V2VMassLbl.Layout.Row = 3;
V2VMassLbl.Layout.Column = 1;
V2VMassSlider = uislider(g, "Limits", [0, 1]);
V2VMassSlider.Layout.Row = 3;
V2VMassSlider.Layout.Column = 2;
V2VMassSlider.Value = worldParams.V2VMass;

crashCostLbl = uilabel(g, "Text", "Crash Cost");
crashCostLbl.Layout.Row = 4;
crashCostLbl.Layout.Column = 1;
crashCostSlider = uislider(g, "Limits", [1, 100]);
crashCostSlider.Layout.Row = 4;
crashCostSlider.Layout.Column = 2;
crashCostSlider.Value = worldParams.crashCost;

trueSpFnLbl = uilabel(g, "Text", "True Signal Prob Slope");
trueSpFnLbl.Layout.Row = 5;
trueSpFnLbl.Layout.Column = 1;
trueSpFnSlider = uislider(g, "Limits", [0, 1]);
trueSpFnSlider.Layout.Row = 5;
trueSpFnSlider.Layout.Column = 2;
trueSpFnSlider.Value = worldParams.trueSignalProbFn(1);

falseSpFnLbl = uilabel(g, "Text", "False Signal Prob Slope");
falseSpFnLbl.Layout.Row = 6;
falseSpFnLbl.Layout.Column = 1;
falseSpFnSlider = uislider(g, "Limits", [0, trueSpFnSlider.Value]);
falseSpFnSlider.Layout.Row = 6;
falseSpFnSlider.Layout.Column = 2;
falseSpFnSlider.Value = worldParams.falseSignalProbFn(1);

% Figures
lossFig = figure();
dispComponents.lossHeatmap = heatmap(1);
title(dispComponents.lossHeatmap, "Loss Caused by Uncertainty");
xlabel(dispComponents.lossHeatmap, "Agent Assumed Slope");
ylabel(dispComponents.lossHeatmap, "Uncertainty Radius");

UpdatePlots(dispComponents, worldParams)

% Slider function hooks
slopeSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateSlope(event.Value));
yIntSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateYInt(event.Value));
V2VMassSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateV2VMass(event.Value));
crashCostSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateCrashCost(event.Value));
trueSpFnSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateTrueSignalProbFn(@(y) event.Value.*y));
falseSpFnSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateFalseSignalProbFn(@(y) event.Value.*y));
uncertaintyRadiusSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams);

function UpdatePlots(dispComponents, worldParams)
	LossInCrashProb(dispComponents.lossHeatmap, worldParams);
end

function loss = LossInCrashProb(lossHeatmap, worldParams)
	loss = GetLossFromAgentUncertainty(worldParams);
	lossHeatmap.ColorData = loss;

	% Renormalize colormap 
	colors = [255, 75, 75; 255, 255, 255; 1, 114, 189] ./ 255;
	points = [min(loss, [], "all"), 0, max(loss, [], "all")];
	cMap = LabelledColormap(points, colors, loss);
	lossHeatmap.Colormap = cMap;
end
