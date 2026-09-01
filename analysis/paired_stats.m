function s = paired_stats(x, y)
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);
    d = x - y;
    s = struct('n', numel(d), 'mean_a', mean(x), 'mean_b', mean(y), ...
               'mean_difference', mean(d), 'sd_difference', std(d), 't', NaN, 'df', NaN, 'p', NaN, ...
               'ci_low', NaN, 'ci_high', NaN, 'dz', mean(d) / std(d));
    if s.n >= 2
        [~, s.p, ci, test] = ttest(x, y);
        s.t = test.tstat;
        s.df = test.df;
        s.ci_low = ci(1);
        s.ci_high = ci(2);
    end
end
