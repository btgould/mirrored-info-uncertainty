function behavior = GetEqBehavior(worldParams, beta)
    arguments (Input)
        worldParams WorldParams
        beta double
    end
    arguments (Output)
        behavior Behavior
    end

    ty = worldParams.trueSignalProbFn(worldParams.V2VMass);
    fy = worldParams.falseSignalProbFn(worldParams.V2VMass);

    Pvs = fy ./ (worldParams.crashCost.*ty + fy);
    Pn = 1 ./ (1 + worldParams.crashCost);
    Pvu = (1-beta.*fy) ./ (1 + worldParams.crashCost.*(1-beta.*ty) - beta.*fy);
    Qvs = beta.*((ty-fy).*Pvs + fy);
    Qn = beta.*((ty-fy).*Pn + fy);
    Qvu = beta.*((ty-fy).*Pvu + fy);

    % Calculate regions where each eq is active
    E1U = zeros(size(worldParams.slope)) + worldParams.yInt; % p(0)
    E2U = worldParams.slope .* ((1 - beta.*Pvu.*(ty-fy)-beta.*fy).*worldParams.V2VMass) + worldParams.yInt;
    E3U = worldParams.slope .* ((1 - beta.*Pn.*(ty-fy)-beta.*fy).*worldParams.V2VMass) + worldParams.yInt;
    E4U = worldParams.slope .* (1 - (beta.*Pn.*(ty-fy)-beta.*fy).*worldParams.V2VMass) + worldParams.yInt;
    E5U = worldParams.slope .* (1 - (beta.*Pvs.*(ty-fy)-beta.*fy).*worldParams.V2VMass) + worldParams.yInt;
    E6U = worldParams.slope + worldParams.yInt; % p(1)

    E1 = Pvu < E1U;
    E2 = E1U <= Pvu & Pvu <= E2U;
    E3 = E2U < Pvu & Pn < E3U; 
    E4 = E3U <= Pn & Pn <= E4U; 
    E5 = E4U < Pn & Pvs < E5U; 
    E6 = E5U <= Pvs & Pvs <= E6U; 
    E7 = E6U < Pvs;

    % Describe eq behavior in each region 
    xvu = zeros(size(worldParams.slope));
    xvui = (Pvu - worldParams.yInt) ./ (worldParams.slope.*(1-Qvu));
    xvu(E2) = xvui(E2);
    xvu(E3 | E4 | E5 | E6 | E7) = worldParams.V2VMass;

    xn = zeros(size(worldParams.slope));
    xni = (Pn - worldParams.yInt) ./ worldParams.slope - (1 - Qn).*worldParams.V2VMass;
    xn(E4) = xni(E4);
    xn(E5 | E6 | E7) = 1-worldParams.V2VMass;

    xvs = zeros(size(worldParams.slope));
    xvsi = ((Pvs - worldParams.yInt)./worldParams.slope - 1 + Qvs.*worldParams.V2VMass) ./ Qvs;
    xvs(E6) = xvsi(E6);
    xvs(E7) = worldParams.V2VMass;

    behavior = Behavior(xn, xvu, xvs);
end