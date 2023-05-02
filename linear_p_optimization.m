% Goal of this script: Assume crash prob is linear: p(x) = ax + b. Find
% crash prob minimizing beta. With this beta, plot induced crash prob for
% different values of a and b. 
clear;

a = 0.3;
b = 0.1;
trueSignalProbFn = @(y) 0.8 .* y;
falseSignalProbFn = @(y) 0.1 .* y;
V2VMass = 0.9;
crashCost = 3;

granularity= 100;

% Calculate optimal beta for each assumed slope 
slopes = linspace(0, 1-b, granularity);
[optimalCrashProb, beta] = GetOptimalBeta(slopes, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);

% Calculate loss of assumed optimal beta on different slopes
[betaMat, slopeMat] = meshgrid(beta, slopes);
[inducedxn, inducedxvu, inducedxvs] = GetEqBehavior(slopeMat, b, betaMat, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
inducedCrashProb = GetCrashProb(slopeMat, b, inducedxn, inducedxvu, inducedxvs, trueSignalProbFn, falseSignalProbFn, V2VMass, betaMat);
loss = inducedCrashProb - repmat(squeeze(optimalCrashProb), 100, 1).';

% Plot
fig = heatmap(loss);
xlabel("Assumed slope");
ylabel("Actual slope");


function [crashProb, beta] = GetOptimalBeta(a, b, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn)
    crashProbs = squeeze(zeros(cat(2, [2], size(a))));
    for beta = [0, 1]
        [xn, xvu, xvs] = GetEqBehavior(a, b, beta, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn);
        crashProbs(beta+1, :) = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta);
    end

    [crashProb, beta] = min(crashProbs);
    beta = beta - 1;
end

function [xn, xvu, xvs] = GetEqBehavior(a, b, beta, V2VMass, crashCost, trueSignalProbFn, falseSignalProbFn)
    ty = trueSignalProbFn(V2VMass);
    fy = falseSignalProbFn(V2VMass);

    Pvs = fy ./ (crashCost.*ty + fy);
    Pn = 1 ./ (1 + crashCost);
    Pvu = (1-beta.*fy) ./ (1 + crashCost.*(1-beta.*ty) - beta.*fy);
    Qvs = beta.*((ty-fy).*Pvs + fy);
    Qn = beta.*((ty-fy).*Pn + fy);
    Qvu = beta.*((ty-fy).*Pvu + fy);

    % Calculate regions where each eq is active
    E1U = zeros(size(a)) + b; % p(0)
    E2U = a .* ((1 - beta.*Pvu.*(ty-fy)-beta.*fy).*V2VMass) + b;
    E3U = a .* ((1 - beta.*Pn.*(ty-fy)-beta.*fy).*V2VMass) + b;
    E4U = a .* (1 - (beta.*Pn.*(ty-fy)-beta.*fy).*V2VMass) + b;
    E5U = a .* (1 - (beta.*Pvs.*(ty-fy)-beta.*fy).*V2VMass) + b;
    E6U = a + b; % p(1)

    E1 = Pvu < E1U;
    E2 = E1U <= Pvu & Pvu <= E2U;
    E3 = E2U < Pvu & Pn < E3U; 
    E4 = E3U <= Pn & Pn <= E4U; 
    E5 = E4U < Pn & Pvs < E5U; 
    E6 = E5U <= Pvs & Pvs <= E6U; 
    E7 = E6U < Pvs;

    % Describe eq behavior in each region 
    xvu = zeros(size(a));
    xvui = (Pvu - b) ./ (a.*(1-Qvu));
    xvu(E2) = xvui(E2);
    xvu(E3 | E4 | E5 | E6 | E7) = V2VMass;

    xn = zeros(size(a));
    xni = (Pn - b) ./ a - (1 - Qn).*V2VMass;
    xn(E4) = xni(E4);
    xn(E5 | E6 | E7) = 1-V2VMass;

    xvs = zeros(size(a));
    xvsi = ((Pvs - b)./a - 1 + Qvs.*V2VMass) ./ Qvs;
    xvs(E6) = xvsi(E6);
    xvs(E7) = V2VMass;
end

function crashProb = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta)
    ty = trueSignalProbFn(V2VMass);
    fy = falseSignalProbFn(V2VMass);
    crashProb = (b + a.*xn + a.*xvu + a.*beta.*fy.*(xvs-xvu))./(a.*beta.*(fy-ty).*(xvs-xvu) + 1);
end