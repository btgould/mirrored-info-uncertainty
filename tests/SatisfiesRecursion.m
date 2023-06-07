function [recurses, diff] = SatisfiesRecursion(beta, worldParams, behavior, crashProbVal, crashProbFn)
	arguments (Input)
		beta double{mustBeInRange(beta, 0, 1)}
		worldParams(1, 1) WorldParams
		behavior(1, 1) Behavior
		crashProbVal double{mustBeInRange(crashProbVal, 0, 1)}
		crashProbFn (1,1) function_handle
	end
	arguments (Output)
		recurses logical
		diff double
	end

	ty = worldParams.trueSignalProbFn(worldParams.V2VMass);
	fy = worldParams.falseSignalProbFn(worldParams.V2VMass);
	signalProb = beta .* (crashProbVal.*ty + (1-crashProbVal).*fy);

	recursion = crashProbFn(behavior.xn + ...
		(1-signalProb).*behavior.xvu + ...
		signalProb.*behavior.xvs);

	diff = recursion - crashProbVal;
	recurses = abs(diff) < eps;
end