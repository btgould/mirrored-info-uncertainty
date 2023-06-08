classdef SocialCost
	properties
		regretCost double {mustBeNonnegative}
		accidentCost double {mustBeNonnegative}
	end
	properties (Dependent)
		total
	end
	methods
		function obj = SocialCost(regret, accident)
			obj.regretCost = regret;
			obj.accidentCost = accident;
		end

		function d = double(obj)
			d = obj.total;
		end

		function t = get.total(obj)
			t = obj.regretCost + obj.accidentCost;
		end
	end
end