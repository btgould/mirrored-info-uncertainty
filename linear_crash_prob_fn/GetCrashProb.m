function crashProb = GetCrashProb(a, b, xn, xvu, xvs, trueSignalProbFn, falseSignalProbFn, V2VMass, beta)
    ty = trueSignalProbFn(V2VMass);
    fy = falseSignalProbFn(V2VMass);
    crashProb = (b + a.*xn + a.*xvu + a.*beta.*fy.*(xvs-xvu))./(a.*beta.*(fy-ty).*(xvs-xvu) + 1);
end