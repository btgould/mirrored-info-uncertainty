% Goal of this script: Assume crash prob is linear: p(x) = ax + b. Find
% crash prob minimizing beta. With this beta, plot induced crash prob for
% different values of a and b. 
clear;

a = 0.8;
b = 0.1;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
V2VMass = 0.9;
crashCost = 20;

[crashProb, beta] = GetOptimalBeta(a, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
crashProbs = [];
for slope = linspace(0, 1-b, 100)
    [xn, xvu, xvs] = GetEqBehavior(slope, b, beta, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
    crashProbs(end+1) = GetCrashProb(slope, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta);
end

loss = crashProbs - crashProb

function [crashProb, beta] = GetOptimalBeta(a, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn)
    crashProbs = [0, 0];
    for beta = [0, 1]
        [xn, xvu, xvs] = GetEqBehavior(a, b, beta, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
        crashProbs(beta+1) = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta);
    end

    [crashProb, beta] = min(crashProbs);
    beta = beta - 1;
end

function [xn, xvu, xvs] = GetEqBehavior(a, b, beta, y, r, trueSignalProbFn, falseSignalProbFn)
    ty = trueSignalProbFn(y);
    fy = falseSignalProbFn(y);

    Pvs = fy ./ (r.*ty + fy);
    Pn = 1 ./ (1 + r);
    Pvu = (1-beta.*fy) ./ (1 + r.*(1-beta.*ty) - beta.*fy);
    Qvs = beta*((ty-fy)*Pvs + fy);
    Qn = beta*((ty-fy)*Pn + fy);
    Qvu = beta*((ty-fy)*Pvu + fy);

    E1U = b; % p(0)
    E2U = a .* ((1 - beta.*Pvu.*(ty-fy)-beta.*fy).*y) + b;
    E3U = a .* ((1 - beta.*Pn.*(ty-fy)-beta.*fy).*y) + b;
    E4U = a .* (1 - (beta.*Pn.*(ty-fy)-beta.*fy).*y) + b;
    E5U = a .* (1 - (beta.*Pvs.*(ty-fy)-beta.*fy).*y) + b;
    E6U = a + b; % p(1)

    if Pvu < E1U
        xn = 0;
        xvu = 0;
        xvs = 0;
    elseif Pvu <= E2U
        xn = 0;
        xvu = (Pvu - b) ./ (a.*(1-Qvu));
        xvs = 0;
    elseif Pn < E3U
        xn = 0;
        xvu = y;
        xvs = 0;
    elseif Pn <= E4U
        xn = (Pn - b) ./ a - (1 - Qn).*y;
        xvu = y;
        xvs = 0;
    elseif Pvs < E5U 
        xn = 1-y;
        xvu = y;
        xvs = 0;
    elseif Pvs <= E6U
        xn = 1-y;
        xvu = y;
        xvs = ((Pvs - b)./a - 1 + Qvs.*y) ./ Qvs;
    else 
        xn = 1-y;
        xvu = y;
        xvs = y;
    end
end

function crashProb = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta)
    ty = trueSignalProbFn(V2VMass);
    fy = falseSignalProbFn(V2VMass);
    crashProb = (b + a.*xn + a.*xvu + a.*beta.*fy.*(xvs-xvu))./(a.*beta.*(fy-ty).*(xvs-xvu) + 1);
end