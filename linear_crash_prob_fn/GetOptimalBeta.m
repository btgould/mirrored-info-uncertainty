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
		[behavior, eqList(beta+1, :)] = GetEqBehavior(worldParams, beta); % TODO: eqs gets overwritten on second iteration
		crashProbs(beta+1, :) = GetCrashProb(worldParams, behavior, beta);
	end

	[crashProb, beta] = min(crashProbs);

	eqs = zeros(size(beta, 2), 1);
	for i = 1:size(beta, 2)
		eqs(i) = eqList(beta(i), i);
	end


	beta = beta - 1; % Adjusts for offset caused by matlab's one indexing
end