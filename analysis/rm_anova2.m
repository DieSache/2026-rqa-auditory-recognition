% Test both factors and their interaction in a balanced two-factor repeated-measures design.
function stats = rm_anova2(Y)
    [n, a, b] = size(Y);
    grand = mean(Y(:));
    subject = squeeze(mean(mean(Y, 3), 2));
    am = squeeze(mean(mean(Y, 3), 1));
    bm = squeeze(mean(mean(Y, 2), 1));
    cells = squeeze(mean(Y, 1));
    sa = squeeze(mean(Y, 3));
    sb = squeeze(mean(Y, 2));
    ssTotal = sum((Y(:) - grand).^2);
    ssSubject = a * b * sum((subject - grand).^2);
    ssA = n * b * sum((am - grand).^2);
    ssB = n * a * sum((bm - grand).^2);
    ssAB = n * sum((cells - am(:) - bm(:)' + grand).^2, 'all');
    ssSA = b * sum((sa - subject - am(:)' + grand).^2, 'all');
    ssSB = a * sum((sb - subject - bm(:)' + grand).^2, 'all');
    ssSAB = max(0, ssTotal - ssSubject - ssA - ssB - ssAB - ssSA - ssSB);
    stats.a = effect(ssA, ssSA, a - 1, (n - 1) * (a - 1));
    stats.b = effect(ssB, ssSB, b - 1, (n - 1) * (b - 1));
    stats.interaction = effect(ssAB, ssSAB, (a - 1) * (b - 1), (n - 1) * (a - 1) * (b - 1));
end

function s = effect(ss, error, df, dfError)
    s.F = (ss / df) / (error / dfError);
    s.p = 1 - fcdf(s.F, df, dfError);
    s.df = df;
    s.df_error = dfError;
    s.eta2 = ss / (ss + error);
end
