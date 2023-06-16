function thresholds = GetNoLossUncertaintyThresholds(worldParams)
	% Assumes linear crash prob fn: p(x) = ax + b. Finds thresholds on the
	% slope "a" that guarantee one signaling policy will always be optimal
	% for all more extreme slopes.
	%
	% Returns a 1x2 array. The first entry is the minThreshold. For all
	% slopes lower than this threshold, beta=1 is optimal. Second entry is
	% maxThreshold. For all slopes larger, beta=0 is guaranteed optimal.
	arguments (Input)
		worldParams(1, 1) WorldParams
	end
	arguments (Output)
		thresholds(1, 2) double{mustBeInRange(thresholds, 0, 1)}
	end

	slopes = linspace(0, 1-worldParams.yInt, 100);
	newWP = worldParams.Copy().UpdateSlope(slopes);

	[~, minEqs] = GetEqBehavior(newWP, 1);
	[~, maxEqs] = GetEqBehavior(newWP, 0);

	minEqsBounded = 3 <= minEqs & minEqs <= 7;
	maxEqsBounded = maxEqs == 1 | maxEqs == 2;

	if all(~minEqsBounded)
		minThreshold = 0;
	else
		minThreshold = max(slopes(minEqsBounded));
	end
	if all(~maxEqsBounded)
		maxThreshold = 1;
	else
		maxThreshold = min(slopes(maxEqsBounded));
	end

	thresholds = [minThreshold, maxThreshold];
end