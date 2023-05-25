classdef WorldParams
	properties
		slope double{mustBeInRange(slope, 0, 1)}
		yInt double{mustBeInRange(yInt, 0, 1, "exclude-upper")}
		V2VMass double{mustBeInRange(V2VMass, 0, 1)}
		crashCost double{mustBeGreaterThanOrEqual(crashCost, 1)}

		trueSignalProbFn function_handle
		falseSignalProbFn function_handle
	end
	methods
		function obj = WorldParams(slope, yInt, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn)
			obj.slope = slope;
			obj.yInt = yInt;
			obj.V2VMass = V2VMass;
			obj.crashCost = crashCost;

			obj.trueSignalProbFn = trueSignalProbFn;
			obj.falseSignalProbFn = falseSignalProbFn;
		end
	end
end