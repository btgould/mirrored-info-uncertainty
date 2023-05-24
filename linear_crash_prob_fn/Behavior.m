classdef Behavior
    properties
        xn
        xvu
        xvs
    end
    methods
        function obj = Behavior(xn, xvu, xvs)
            obj.xn = xn;
            obj.xvu = xvu;
            obj.xvs = xvs;
        end
    end
end