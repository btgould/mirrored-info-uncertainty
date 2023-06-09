function worstCaseSlopes = GetWorstCaseSlopeForSignalerUncertainty(slopeAxes, worldParams, uncertaintyRadius)
	arguments (Input)
		slopeAxes
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

	% Calculate crash prob and find worst case
	[worstCP, worstSlopeIdx] = fuzzyMax(realizedCP);
	worstCaseOffsets = offsets(worstSlopeIdx);
	worstCaseSlopes = anticipatedSlopes + worstCaseOffsets;
	worstCaseSlopes(worstCaseSlopes > 1-worldParams.yInt) = 1 - worldParams.yInt;

	% Update display
	slopeAxes.XLim = [0, 1 - worldParams.yInt];
	slopeAxes.YLim = [0, 1 - worldParams.yInt];

	plot(slopeAxes, anticipatedSlopes, worstCaseSlopes);
	title(slopeAxes, "Worst Case Slope Under Uncertainty Radius");
	xlabel(slopeAxes, "Assumed Slope");
	ylabel(slopeAxes, "Worst Case Slope");

	% Plot limits of uncertainty
	slopeAxes.NextPlot = "add";
	plot(slopeAxes, anticipatedSlopes, anticipatedSlopes-uncertaintyRadius, "--r");
	plot(slopeAxes, anticipatedSlopes, anticipatedSlopes+uncertaintyRadius, "--r");
	slopeAxes.NextPlot = "replacechildren";
end

function [maximum, idx] = fuzzyMax(data)
	% Clean up from floating point errors
	data(abs(data) < eps) = 0;

	% Take maximum
	[maximum, idx] = max(data);

	% Return last idx to have maximum value
	lastRow = data(end, :);
	lastRowIsMax = abs(maximum-lastRow) < eps;
	idx(lastRowIsMax) = size(data, 1);

	% Check for case where no loss is possible
	midIdx = int32(max(size(maximum))/2);
	idx(abs(maximum-min(data)) < eps) = midIdx;
end