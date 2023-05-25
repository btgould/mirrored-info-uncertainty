clear;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
wp = WorldParams(0, 0.1, 0.9, 3, @(y) 0.8.*y, @(y) 0.1.*y);

%% Signaler Uncertainty
[crashProbWCertainty, crashProbWUncertainty] = SignalerSlopeUncertainty(wp);
loss = crashProbWUncertainty - crashProbWCertainty;
ShowUI(loss, trueSignalProbFn, falseSignalProbFn);

% Plot
% figure;
% heatmap(loss);
% title("Loss Caused by Signaler Slope Uncertainty")
% xlabel("Assumed slope");
% ylabel("Actual slope");

%% Agent Uncertainty
% [crashProbWCertainty, crashProbWUncertainty] = AgentSlopeUncertainty(wp);
% loss = crashProbWUncertainty - crashProbWCertainty;
%
% % Plot
% figure
% heatmap(loss);
% title("Loss Caused by Agent Slope Uncertainty");
% xlabel("Assumed slope");
% ylabel("Actual slope");
%
% figure
% heatmap(double(loss < 0));
% title("Where Agent Slope Uncertainty is Beneficial");
% xlabel("Assumed slope");
% ylabel("Actual slope");

%% Helper Functions
function loss = UpdateLoss(hMap, crashProbEvalFn, worldParams)
	[crashProbWCertainty, crashProbWUncertainty] = crashProbEvalFn(worldParams);
	loss = crashProbWUncertainty - crashProbWCertainty;
	hMap.ColorData = loss;
	drawnow;
end

function ShowUI(loss, trueSignalProbFn, falseSignalProbFn)
	uifig = uifigure();
	g = uigridlayout(uifig, [3, 3]);
	g.ColumnWidth = {'1x', '2x', '3x'};
	g.RowHeight = {50};

	% Sliders and labels
	yIntLbl = uilabel(g, "Text", "y-intercept");
	yIntLbl.Layout.Row = 1;
	yIntLbl.Layout.Column = 1;
	yIntSlider = uislider(g, "Limits", [0, 1]);
	yIntSlider.Layout.Row = 1;
	yIntSlider.Layout.Column = 2;
	yIntSlider.Value = 0.1; % TODO: get rid of these magic nums

	V2VMassLbl = uilabel(g, "Text", "V2V Mass");
	V2VMassLbl.Layout.Row = 2;
	V2VMassLbl.Layout.Column = 1;
	V2VMassSlider = uislider(g, "Limits", [0, 1]);
	V2VMassSlider.Layout.Row = 2;
	V2VMassSlider.Layout.Column = 2;
	V2VMassSlider.Value = 0.9; % TODO: get rid of these magic nums

	crashCostLbl = uilabel(g, "Text", "Crash Cost");
	crashCostLbl.Layout.Row = 3;
	crashCostLbl.Layout.Column = 1;
	crashCostSlider = uislider(g, "Limits", [1, 100]);
	crashCostSlider.Layout.Row = 3;
	crashCostSlider.Layout.Column = 2;
	crashCostSlider.Value = 3; % TODO: get rid of these magic nums

	% Heatmap
	heatmapPanel = uipanel(g);
	heatmapPanel.Layout.Row = [1, 3];
	heatmapPanel.Layout.Column = 3;
	h = heatmap(heatmapPanel, loss, "GridVisible", false);

	% Slider function hooks
	yIntSlider.ValueChangingFcn = @(src, event) UpdateLoss(h, @SignalerSlopeUncertainty, ...
		WorldParams(0, event.Value, V2VMassSlider.Value, crashCostSlider.Value, trueSignalProbFn, falseSignalProbFn));
	V2VMassSlider.ValueChangingFcn = @(src, event) UpdateLoss(h, @SignalerSlopeUncertainty, ...
		WorldParams(0, yIntSlider.Value, event.Value, crashCostSlider.Value, trueSignalProbFn, falseSignalProbFn));
	crashCostSlider.ValueChangingFcn = @(src, event) UpdateLoss(h, @SignalerSlopeUncertainty, ...
		WorldParams(0, yIntSlider.Value, V2VMassSlider.Value, event.Value, trueSignalProbFn, falseSignalProbFn));
end