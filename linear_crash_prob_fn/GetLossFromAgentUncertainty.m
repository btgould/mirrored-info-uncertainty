function loss = GetLossFromAgentUncertainty(realWP, granularity)
	arguments (Input)
		realWP(1, 1) WorldParams = WorldParams(0.7, 0.1, 0.9, 3, @(y) 0.6.*y, @(y) 0.3.*y);
		granularity(1, 1) uint16{mustBePositive} = 100
	end
	arguments (Output)
		loss double
	end

	% Calculate worst case slope for each slope and uncertainty radius
	slopes = linspace(0, 1-realWP.yInt, granularity); % This is OK because I assume p(0) is common knowledge
	uncertaintyRadii = linspace(0, 1-realWP.yInt, granularity);
	[slopeMat, uncertaintyMat] = meshgrid(slopes, uncertaintyRadii);
	worstCaseSlopes = slopeMat - uncertaintyMat;

	% Cap slope assumptions within feasible range
	worstCaseSlopes(worstCaseSlopes < 0) = 0;

	% Calculate accident probabilty induced by uncertainty
	agentBelievedWP = realWP.Copy().UpdateSlope(slopeMat);
	worstCaseWP = realWP.Copy().UpdateSlope(worstCaseSlopes);
    
    realizedCP = GetInducedCPGS(realWP, agentBelievedWP, worstCaseWP);

	% Calculate loss
    crashProbUnderCertainty = GetOptimalCPGS(realWP, agentBelievedWP);
	loss = realizedCP - crashProbUnderCertainty;
end

function inducedCP = GetInducedCPGS(realWP, agentBelievedWP, worstCaseWP)
	arguments (Input)
		realWP WorldParams
        agentBelievedWP WorldParams
        worstCaseWP WorldParams
	end
	arguments (Output)
		inducedCP double
    end

    betas = linspace(0, 1, 100);
    minWorstCaseCP = zeros(size(agentBelievedWP.slope)) + 2;
    inducedCP = zeros(size(agentBelievedWP.slope)) + 2;

    for beta = betas
        anticipatedBehavior = GetEqBehavior(worstCaseWP, beta);
        worstCaseCP = GetCrashProb(realWP, anticipatedBehavior, beta);

        newMin = worstCaseCP < minWorstCaseCP;
        minWorstCaseCP(newMin) = worstCaseCP(newMin);

        inducedBehavior = GetEqBehavior(agentBelievedWP, beta);
        inducedCPCurr = GetCrashProb(realWP, inducedBehavior, beta);

        inducedCP(newMin) = inducedCPCurr(newMin);
    end
end

function minCrashProb = GetOptimalCPGS(realWP, agentBelievedWP)
	arguments (Input)
		realWP WorldParams
        agentBelievedWP WorldParams
	end
	arguments (Output)
		minCrashProb double
    end

    betas = linspace(0, 1, 100);
    minCrashProb = zeros(size(agentBelievedWP.slope)) + 2;

    for beta = betas
        behavior = GetEqBehavior(agentBelievedWP, beta);
        crashProbs = GetCrashProb(realWP, behavior, beta);

        newMin = crashProbs < minCrashProb;
        minCrashProb(newMin) = crashProbs(newMin);
    end
end