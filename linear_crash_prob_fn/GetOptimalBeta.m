function [beta, crashProb, eqs] = GetOptimalBeta(worldParams)
	arguments (Input)
		worldParams WorldParams
	end
	arguments (Output)
		beta double
		crashProb double
		eqs double
	end

	crashProbs = squeeze(zeros(cat(2, 2, size(worldParams.slope))));
	eqList = crashProbs;
	for beta = [0, 1]
		[behavior, eqList(beta+1, :)] = GetEqBehavior(worldParams, beta);
		crashProbs(beta+1, :) = GetCrashProb(worldParams, behavior, beta);
	end

	% [crashProb, beta] = min(crashProbs);
	[crashProb, beta] = fuzzyMin(crashProbs, 1e-5);

	eqs = zeros(size(beta, 2), 1);
	for i = 1:size(beta, 2)
		eqs(i) = eqList(beta(i), i);
	end

	beta = beta - 1; % Adjusts for offset caused by matlab's one indexing
end

function [minimum, idx] = fuzzyMin(data, eps)
	% Get minimum
	[minimum, idx] = min(data);

	% Get data indices
	d = diff(data);
	idx(d > eps) = 1;
	idx(d <= eps) = 2; % Assign worst case to indices near zero
	% TODO: I have no justification for if this is actually worst case
	% It looks nice initially, but I don't think that it is. I have found
	% regions where there are still gaps
end