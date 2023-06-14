function [beta, crashProb, eqs] = GetOptimalBeta(worldParams)
	% Calculates the optimal (crash probability minimizing) signaling
	% policy for some set of world parameters. Also returns the crash
	% probability and index of the equilibrium family induced by this
	% signaling policy.
	arguments (Input)
		worldParams WorldParams
	end
	arguments (Output)
		beta double
		crashProb double
		eqs uint8{mustBeInRange(eqs, 1, 8)}
	end

	% NOTE: I would really like to do this as an array, rather than a
	% struct, but since I don't know the dimensions of slope that will be
	% passed in, I can't. The ":" operator flattens ALL remaining
	% dimensions, which is a problem if I want to accept both 1D and 2D
	% uncertainty matrices.
	crashProbs.beta0 = zeros(size(worldParams.slope));
	crashProbs.beta1 = zeros(size(worldParams.slope));
	eqList.beta0 = zeros(size(worldParams.slope));
	eqList.beta1 = zeros(size(worldParams.slope));

	% Calculate crash prob for each possible minimizer beta
	[behavior, eqList.beta0] = GetEqBehavior(worldParams, 0);
	crashProbs.beta0 = GetCrashProb(worldParams, behavior, 0);
	[behavior, eqList.beta1] = GetEqBehavior(worldParams, 1);
	crashProbs.beta1 = GetCrashProb(worldParams, behavior, 1);

	% Find min crash prob and beta that causes it
	oldSize = size(crashProbs.beta0);
	newSize = cat(2, 1, oldSize);
	crashProbs.beta0 = reshape(crashProbs.beta0, newSize);
	crashProbs.beta1 = reshape(crashProbs.beta1, newSize);
	crashProbMat = cat(1, crashProbs.beta0, crashProbs.beta1);

	% [crashProb, beta] = min(crashProbMat);
	[crashProb, beta] = fuzzyMin(crashProbMat, 1e-5);
	crashProb = reshape(crashProb, oldSize);
	beta = reshape(beta, oldSize);
	eqs = zeros(size(worldParams.slope));
	eqs(beta == 1) = eqList.beta0(beta == 1);
	eqs(beta == 2) = eqList.beta1(beta == 2);

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