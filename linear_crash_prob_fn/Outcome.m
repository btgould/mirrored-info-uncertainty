classdef Outcome
	properties
		beta double{mustBeInRange(beta, 0, 1)}
		eqs uint8{mustBeInRange(eqs, 1, 8)} % I use 8 here to signal we are not at equilibrium
		behavior(1, 1) Behavior = Behavior(0, 0, 0);
		crashProb double{mustBeInRange(crashProb, 0, 1)}
		socialCost(1, 1) SocialCost = SocialCost(0, 0);
	end
	methods
		function obj = Outcome(beta, eqs, behavior, crashProb, socialCost)
			obj.beta = beta;
			obj.eqs = eqs;
			obj.behavior = behavior;
			obj.crashProb = crashProb;
			obj.socialCost = socialCost;
		end
	end
end