classdef Outcome
	properties
		eqs uint8{mustBeInRange(eqs, 1, 7)}
		behavior (1,1) Behavior
		crashProb double{mustBeInRange(crashProb, 0, 1)}
		socialCost (1,1) SocialCost
	end
end