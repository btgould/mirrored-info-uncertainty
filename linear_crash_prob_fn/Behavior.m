classdef Behavior
	properties
		xn double {mustBeInRange(xn, 0, 1)}
		xvu double {mustBeInRange(xvu, 0, 1)}
		xvs double {mustBeInRange(xvs, 0, 1)}
	end
	methods
		function obj = Behavior(xn, xvu, xvs)
			obj.xn = xn;
			obj.xvu = xvu;
			obj.xvs = xvs;
		end
	end
end