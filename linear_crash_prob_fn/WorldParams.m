classdef WorldParams
	properties
		slope double{mustBeReal}
		yInt double{mustBeReal}
		V2VMass double{mustBeReal}
		crashCost double{mustBeReal}

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