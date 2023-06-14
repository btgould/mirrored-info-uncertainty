classdef WorldParams < handle
	properties
		slope double{mustBeInRange(slope, 0, 1)}
		yInt double{mustBeInRange(yInt, 0, 1, "exclude-upper")}
		V2VMass double{mustBeInRange(V2VMass, 0, 1, "exclude-lower")}
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
		function other = Copy(obj)
			arguments (Output)
				other(1, 1) WorldParams
			end
			other = WorldParams(obj.slope, obj.yInt, obj.V2VMass, obj.crashCost, ...
				obj.trueSignalProbFn, obj.falseSignalProbFn);
		end
		function obj = UpdateSlope(obj, newSlope)
			try
				obj.slope = newSlope;
			catch ME
				warning("Tried to set slope to invalid value %f. Using instead old slope %f.", ...
					newSlope, obj.slope);
			end
		end
		function obj = UpdateYInt(obj, newYInt)
			try
				obj.yInt = newYInt;
			catch ME
				warning("Tried to set yInt to invalid value %f. Using instead old yInt %f.", ...
					newYInt, obj.yInt);
			end
		end
		function obj = UpdateV2VMass(obj, newV2VMass)
			try
				obj.V2VMass = newV2VMass;
			catch ME
				warning("Tried to set V2VMass to invalid value %f. Using instead old V2VMass %f.", ...
					newV2VMass, obj.V2VMass);
			end
		end
		function obj = UpdateCrashCost(obj, newCrashCost)
			try
				obj.crashCost = newCrashCost;
			catch ME
				warning("Tried to set crashCost to invalid value %f. Using instead old crashCost %f.", ...
					newCrashCost, obj.crashCost);
			end
		end
		function obj = UpdateTrueSignalProbFn(obj, newFn)
			obj.trueSignalProbFn = newFn;
		end
		function obj = UpdateFalseSignalProbFn(obj, newFn)
			obj.falseSignalProbFn = newFn;
		end
	end
end