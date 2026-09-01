function [r, p] = pearson_stats(x, y)
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);
    if numel(x) < 3 || std(x) == 0 || std(y) == 0
        r = NaN;
        p = NaN;
        return
    end
    C = corrcoef(x, y);
    r = C(1, 2);
    t = r * sqrt((numel(x) - 2) / max(1 - r^2, eps));
    p = 2 * (1 - tcdf(abs(t), numel(x) - 2));
end
