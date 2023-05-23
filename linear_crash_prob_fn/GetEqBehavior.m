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