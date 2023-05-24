function crashProb = GetCrashProb(worldParams, behavior, beta)
    arguments (Input)
        worldParams WorldParams
        behavior Behavior
        beta double
    end
    arguments (Output)
        crashProb double
    end

    ty = worldParams.trueSignalProbFn(worldParams.V2VMass);
    fy = worldParams.falseSignalProbFn(worldParams.V2VMass);
    crashProb = (worldParams.yInt + worldParams.slope.*behavior.xn + ...
        worldParams.slope.*behavior.xvu + worldParams.slope.*beta.*fy.*(behavior.xvs-behavior.xvu)) ...
        ./ (worldParams.slope.*beta.*(fy-ty).*(behavior.xvs-behavior.xvu) + 1);
end