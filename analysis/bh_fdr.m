function adjusted = bh_fdr(p)
    adjusted = nan(size(p));
    valid = isfinite(p);
    [sorted, order] = sort(p(valid));
    n = numel(sorted);
    if n == 0
        return
    end
    values = flipud(cummin(flipud(min(1, sorted(:) .* n ./ (1:n)'))));
    restored = nan(n, 1);
    restored(order) = values;
    adjusted(valid) = restored;
end
