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

uncertiantyRadiusLbl = uilabel(g, "Text", "Uncertainty Radius");
falseuncertiantyRadiusLblSpFnLbl.Layout.Row = 7;
uncertiantyRadiusLbl.Layout.Column = 1;
uncertaintyRadiusSlider = uislider(g, "Limits", [0, 1]);
uncertaintyRadiusSlider.Layout.Row = 7;
uncertaintyRadiusSlider.Layout.Column = 2;
uncertaintyRadiusSlider.Value = 0.1;

% Figures
crashProbFig = figure();
dispComponents.cpPlot = plot(1);
dispComponents.cpPlot.Parent.XLim = [0, 1];
dispComponents.cpPlot.Parent.YLim = [0, 1];
title("Crash Probability as a Function of Beta");
xlabel("Beta");
ylabel("Crash Probability");

slopeFig = figure();
dispComponents.slopeAxis = plot(1).Parent;

UpdatePlots(dispComponents, worldParams, uncertaintyRadiusSlider.Value)

% Slider function hooks
slopeSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateSlope(event.Value), uncertaintyRadiusSlider.Value);
yIntSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateYInt(event.Value), uncertaintyRadiusSlider.Value);
V2VMassSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateV2VMass(event.Value), uncertaintyRadiusSlider.Value);
crashCostSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateCrashCost(event.Value), uncertaintyRadiusSlider.Value);
trueSpFnSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateTrueSignalProbFn(@(y) event.Value.*y), uncertaintyRadiusSlider.Value);
falseSpFnSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams.UpdateFalseSignalProbFn(@(y) event.Value.*y), uncertaintyRadiusSlider.Value);
uncertaintyRadiusSlider.ValueChangingFcn = @(src, event) UpdatePlots(dispComponents, ...
	worldParams, event.Value);

function UpdatePlots(dispComponents, worldParams, uncertaintyRadius)
	CrashProbForPlot(dispComponents.cpPlot, worldParams);
	GetWorstCaseSlope(dispComponents.slopeAxis, worldParams, uncertaintyRadius);
end

function [crashProbs, behavior] = CrashProbForPlot(cpPlot, worldParams)
	beta = linspace(0, 1, 100);

	behavior = GetEqBehavior(worldParams, beta);
	crashProbs = GetCrashProb(worldParams, behavior, beta);

	cpPlot.XData = beta;
	cpPlot.YData = crashProbs;
end

function worstCaseSlopes = GetWorstCaseSlope(slopeAxis, worldParams, uncertaintyRadius)
	arguments (Input)
		slopeAxis
		worldParams(1, 1) WorldParams
		uncertaintyRadius(1, 1) double{mustBePositive}
	end
	arguments (Output)
		worstCaseSlopes double{mustBeInRange(worstCaseSlopes, -0.1, 1)}
		% Small negative window here to account for 0 not being a chosen offset
	end

	% Calculate signaler expected outcome for each possible slope
	anticipatedSlopes = linspace(0, 1-worldParams.yInt, 100); % TODO: magic 100s
	signalerAnticipatedWP = worldParams.Copy().UpdateSlope(anticipatedSlopes);
	chosenBeta = GetOptimalBeta(signalerAnticipatedWP);

	% Compute set of possible realized slopes
	anticipatedSlopeMat = repmat(anticipatedSlopes, [100, 1]);
	offsets = linspace(-uncertaintyRadius, uncertaintyRadius, 100);
	offsetMat = repmat(offsets, [100, 1]).';
	realizedSlopeMat = anticipatedSlopeMat + offsetMat;
	realizedSlopeMat(realizedSlopeMat < 0) = 0;
	realizedSlopeMat(realizedSlopeMat > 1-worldParams.yInt) = 1 - worldParams.yInt;

	% Calculate realized outcomes for all realized slopes in range
	realizedWP = worldParams.Copy().UpdateSlope(realizedSlopeMat);
	betaMat = repmat(chosenBeta, [100, 1]);
	realizedCP = GetCrashProb(realizedWP, GetEqBehavior(realizedWP, betaMat), betaMat);

	% Calculate loss and find worst case
	[~, optimalCP] = GetOptimalBeta(realizedWP);
	loss = realizedCP - optimalCP;
	[worstLoss, worstSlopeIdx] = fuzzyMax(loss); % TODO: display worst loss
	worstCaseOffsets = offsets(worstSlopeIdx);
	worstCaseSlopes = anticipatedSlopes + worstCaseOffsets;

	% Update display
	slopeAxis.XLim = [0, 1 - worldParams.yInt];
	slopeAxis.YLim = [0, 1 - worldParams.yInt];

	plot(slopeAxis, anticipatedSlopes, worstCaseSlopes);
	title("Worst Case Slope Under Uncertainty Radius");
	xlabel("Assumed Slope");
	ylabel("Worst Case Slope");

	% Plot limits of uncertainty
	slopeAxis.NextPlot = "add";
	plot(slopeAxis, anticipatedSlopes, anticipatedSlopes-uncertaintyRadius, "--r");
	plot(slopeAxis, anticipatedSlopes, anticipatedSlopes+uncertaintyRadius, "--r");
	slopeAxis.NextPlot = "replacechildren";
end

function [maximum, idx] = fuzzyMax(data)
	% Clean up from floating point errors
	data(abs(data) < eps) = 0;

	% Take maximum
	[maximum, idx] = max(data);

	% Check for case where no loss is possible
	midIdx = int32(max(size(maximum))/2);
	idx(maximum == min(data)) = midIdx;
end
