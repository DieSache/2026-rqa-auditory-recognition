% Nested participant-wise ridge prediction for the matched RQA model.
function analyse_ridge(cfg, rawRqa, behaviour, amplitude)
    rng(20260830, 'twister');
    statsDir = fullfile(cfg.output, 'statistics');
    excluded = unique(rawRqa.subject_id(rawRqa.RR == 0));
    rqa = rawRqa(~ismember(rawRqa.subject_id, excluded), :);
    data = innerjoin(rqa, behaviour, 'Keys', {'subject_id', 'block', 'melody_length', 'condition_index'}, ...
                     'RightVariables', {'accuracy'});
    data = innerjoin(data, amplitude, 'Keys', {'subject_id', 'block', 'melody_length', 'condition_index'});
    valid = isfinite(data.accuracy) & isfinite(data.amplitude_rms) & ...
            all(isfinite(data{:, cellstr(cfg.metrics)}), 2);
    data = sortrows(data(valid, :), {'subject_id', 'melody_length', 'condition_index'});
    subjects = unique(data.subject_id, 'stable');
    lambdas = logspace(2, -5, 29); p0 = 10; nSubjects = numel(subjects);
    nTest = zeros(nSubjects, 1);
    baseSse = nan(nSubjects, 1);
    ridgeSse = baseSse;
    coefficients = nan(nSubjects, numel(cfg.metrics));
    for s = 1:nSubjects
        test = data.subject_id == subjects(s); train = ~test;
        [Xtrain, Xtest] = design(data(train, :), data(test, :), cfg.metrics);
        ytrain = data.accuracy(train); ytest = data.accuracy(test);
        lambda = tune(Xtrain, ytrain, p0, lambdas, data.subject_id(train), cfg.metrics);
        beta = ridge_fit(Xtrain, ytrain, p0, lambda);
        base = Xtest(:, 1:p0) * (Xtrain(:, 1:p0) \ ytrain); prediction = Xtest * beta;
        nTest(s) = sum(test);
        baseSse(s) = sum((ytest - base).^2); ridgeSse(s) = sum((ytest - prediction).^2);
        coefficients(s, :) = beta(p0 + (1:numel(cfg.metrics)));
    end
    bootstrap = paired_bootstrap(baseSse, ridgeSse, 10000);
    signflip = paired_signflip(baseSse, ridgeSse, 100000);
    summary = table(nSubjects, ...
                    sqrt(sum(baseSse) / sum(nTest)), sqrt(sum(ridgeSse) / sum(nTest)), ...
                    100 * (sqrt(sum(baseSse)) - sqrt(sum(ridgeSse))) / sqrt(sum(baseSse)), ...
                    bootstrap(1), bootstrap(2), signflip, sum(ridgeSse < baseSse), ...
                    'VariableNames', {'n_subjects', 'baseline_RMSE', ...
                    'ridge_RMSE', 'RMSE_improvement_percent', 'bootstrap_CI_low', 'bootstrap_CI_high', ...
                    'paired_signflip_p', 'participants_improved'});
    metricRows = table(cfg.metrics', mean(coefficients, 1)', ...
                       'VariableNames', {'metric', 'mean_coefficient'});
    writetable(summary, fullfile(statsDir, 'ridge_summary.csv'));
    writetable(metricRows, fullfile(statsDir, 'ridge_coefficient_stability.csv'));
end

function lambda = tune(X, y, p0, lambdas, groups, metrics)
    subjects = unique(groups, 'stable'); fold = mod((1:numel(subjects))' - 1, 3) + 1;
    sse = zeros(numel(lambdas), 1);
    for f = 1:3
        test = ismember(groups, subjects(fold == f)); train = ~test;
        [Xi, Xv] = rescale(X(train, :), X(test, :), p0, metrics); yi = y(train); yv = y(test);
        for l = 1:numel(lambdas)
            prediction = Xv * ridge_fit(Xi, yi, p0, lambdas(l));
            sse(l) = sse(l) + sum((yv - prediction).^2);
        end
    end
    [~, best] = min(sse);
    lambda = lambdas(best);
end

function [Xtrain, Xtest] = design(a, b, metrics)
    [Xtrain, Xtest] = fixed(a, b); predictors = ["amplitude_rms" metrics];
    for predictor = predictors
        mu = mean(a.(predictor)); sigma = std(a.(predictor)); if sigma == 0, sigma = 1; end
        Xtrain(:, end + 1) = (a.(predictor) - mu) / sigma;
        Xtest(:, end + 1) = (b.(predictor) - mu) / sigma;
    end
end

function [Xtrain, Xtest] = rescale(a, b, p0, metrics)
    Xtrain = a; Xtest = b;
    for col = p0:(p0 + numel(metrics))
        mu = mean(a(:, col)); sigma = std(a(:, col)); if sigma == 0, sigma = 1; end
        Xtrain(:, col) = (a(:, col) - mu) / sigma; Xtest(:, col) = (b(:, col) - mu) / sigma;
    end
end

function [train, test] = fixed(a, b)
    ac = [a.condition_family == "early_change", a.condition_family == "late_change"];
    bc = [b.condition_family == "early_change", b.condition_family == "late_change"];
    al = [a.melody_length == 3, a.melody_length == 5]; bl = [b.melody_length == 3, b.melody_length == 5];
    train = [ones(height(a), 1), ac, al, ac(:, 1).*al, ac(:, 2).*al];
    test = [ones(height(b), 1), bc, bl, bc(:, 1).*bl, bc(:, 2).*bl];
end

function beta = ridge_fit(X, y, p0, lambda)
    penalty = diag([zeros(p0, 1); ones(size(X, 2) - p0, 1)]);
    beta = (X' * X + lambda * size(X, 1) * penalty) \ (X' * y);
end

function ci = paired_bootstrap(baseSse, ridgeSse, draws)
    n = numel(baseSse); sample = randi(n, draws, n);
    base = sum(baseSse(sample), 2); ridge = sum(ridgeSse(sample), 2);
    ci = prctile(100 * (sqrt(base) - sqrt(ridge)) ./ sqrt(base), [2.5 97.5]);
end

function p = paired_signflip(baseSse, ridgeSse, draws)
    d = baseSse - ridgeSse; observed = mean(d);
    signs = 2 * (randi(2, draws, numel(d)) - 1.5); null = mean(signs .* d', 2);
    p = (1 + sum(abs(null) >= abs(observed))) / (draws + 1);
end
