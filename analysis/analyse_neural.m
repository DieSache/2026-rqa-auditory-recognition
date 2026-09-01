% Derive the neural time-series, RQA, and activation-behaviour outputs used in the manuscript.
function [rqa, activation, amplitude, thresholdRqa] = analyse_neural(cfg, behaviour)
    timeseriesDir = fullfile(cfg.output, '3_timeseries');
    statsDir = fullfile(cfg.output, 'statistics');
    if ~exist(timeseriesDir, 'dir')
        mkdir(timeseriesDir);
    end
    if ~exist(statsDir, 'dir')
        mkdir(statsDir);
    end
    for method = ["cluster" "fdr"]
        path = fullfile(timeseriesDir, method);
        if ~exist(path, 'dir')
            mkdir(path);
        end
    end

    rng default;
    rqa = table();
    activation = table();
    amplitude = table();
    thresholdRqa = table();
    variance = nan(3);
    dimensionality = nan(3, 1);
    for b = 1:3
        block = cfg.blocks(b);
        loaded = load(fullfile(cfg.input, 'broadness', block.name, 'BROADNESS.mat'), 'BROADNESS');
        B = loaded.BROADNESS;
        time = B.Time(:);
        ts = B.TimeSeries_BrainNetworks;
        eigenspectrum = B.Variance_BrainNetworks(:);
        variance(:, b) = eigenspectrum(1:3);
        dimensionality(b) = BROADNESS_EffectiveDimensionality(eigenspectrum);
        components = 1:dimensionality(b);

        for network = 1:3
            write_timeseries(timeseriesDir, block, network, time, ts(:, network, :, :));
            write_significance(timeseriesDir, block, network, time, ts(:, network, :, :), cfg);
        end
        export_network_maps(cfg, block, B);

        window = [0 block.events(end) + .8];
        R = BROADNESS_PhaseSpace_RQA(B, 'principalcomps', components, ...
                                     'timeinterval', window, 'threshold', cfg.rqaThreshold, 'video', 'off', 'figure', 'off');
        rqa = addrow(rqa, rqa_rows(cfg, block, window, R));
        thresholdRqa = addrow(thresholdRqa, threshold_rows(cfg, block, window, R));
        amplitude = addrow(amplitude, amplitude_rows(cfg, block, components, window, time, ts));
        activation = addrow(activation, activation_correlations(cfg, block, time, ts, behaviour.summary));
        clear B R loaded ts;
    end

    varianceTable = table([3; 5; 7], variance(1, :)', variance(2, :)', variance(3, :)', dimensionality, ...
                          'VariableNames', {'melody_length', 'BN1', 'BN2', 'BN3', 'effective_dimensionality'});
    writetable(varianceTable, fullfile(statsDir, 'network_variance.csv'));
    writetable(activation, fullfile(statsDir, 'activation_behaviour.csv'));
end

% Summarize activation magnitude over the same components and interval as RQA.
function T = amplitude_rows(cfg, block, components, window, time, ts)
    T = table();
    keep = time >= window(1) & time <= window(2);
    map = sortrows(cfg.map(cfg.map.melody_length == block.length, :), 'participant_index');
    for participant = 1:height(map)
        for condition = 1:3
            x = ts(keep, components, condition, map.participant_index(participant));
            x = x(isfinite(x));
            row = table(map.subject_id(participant), block.name, block.length, condition, ...
                        sqrt(mean(x.^2)), 'VariableNames', ...
                        {'subject_id', 'block', 'melody_length', 'condition_index', 'amplitude_rms'});
            T = addrow(T, row);
        end
    end
end

% Re-threshold cached distance matrices without repeating phase-space estimation.
function T = threshold_rows(cfg, block, window, R)
    T = table();
    map = sortrows(cfg.map(cfg.map.melody_length == block.length, :), 'participant_index');
    for threshold = cfg.rqaThresholdSensitivity
        for participant = 1:numel(R.RQA_metrics)
            subject = map.subject_id(map.participant_index == participant);
            for condition = 1:3
                m = rqa_metrics(R.RecurrencePlots.DistMat{condition, participant}, threshold);
                row = table(threshold, participant, subject, string(block.name), block.length, window(1), window(2), condition, ...
                            cfg.families(condition), cfg.familyLabels(condition), 'VariableNames', ...
                            {'threshold', 'participant_index', 'subject_id', 'block', 'melody_length', 'window_start_sec', ...
                            'window_end_sec', 'condition_index', 'condition_family', 'condition_label'});
                row = [row array2table(cell2mat(m(:)'), 'VariableNames', cellstr(cfg.metrics))];
                T = addrow(T, row);
            end
        end
    end
end

function m = rqa_metrics(D, threshold)
    RP = D < max(D(:)) * threshold;
    recurrence = sum(RP(:));
    [~, diagonal] = dl(RP); diagonal(diagonal < 2) = [];
    L = mean(diagonal);
    if isempty(diagonal), diagonal = 0; end
    if recurrence > 0, DET = sum(diagonal) / recurrence; else, DET = NaN; end
    counts = hist(diagonal(:), 1:min(size(RP)));
    ENTR = entropy(counts(:));
    [~, vertical] = tt(RP); vertical(vertical < 2) = [];
    TT = mean(vertical);
    if sum(vertical) > 0, LAM = sum(vertical) / recurrence; else, LAM = NaN; end
    if isempty(vertical), Vmax = NaN; else, Vmax = max(vertical); end
    if numel(diagonal) >= 2, Lmax = max(diagonal(1:end-1)); else, Lmax = max(diagonal); end
    m = num2cell([recurrence / numel(RP), L, DET, ENTR, TT, LAM, Vmax, 1 / Lmax]);
end

function write_timeseries(outDir, block, network, time, values)
    values = squeeze(values);
    if size(values, 2) == 3
        values = permute(values, [1 3 2]);
    end
    names = ["M" "NTE" "NTL"];
    T = table(time, 'VariableNames', {'Time'});
    for c = 1:3
        x = values(:, :, c);
        n = sum(isfinite(x), 2);
        T.(names(c)) = mean(x, 2, 'omitnan');
        T.(names(c) + "_STE") = std(x, 0, 2, 'omitnan') ./ sqrt(n);
    end
    writetable(T, fullfile(outDir, sprintf('%s_bn_%d.csv', block.name, network)));
end

% Identify periods where change conditions differ from the memorized condition.
function write_significance(outDir, block, network, time, values, cfg)
    values = squeeze(values);
    if size(values, 2) == 3
        values = permute(values, [1 3 2]);
    end
    reference = values(:, :, 1);
    conditionNames = ["NTE" "NTL"];
    for method = ["cluster" "fdr"]
        rows = table();
        for c = 2:3
            testing = values(:, :, c);
            if method == "fdr"
                p = paired_p(testing - reference);
                mask = bh_fdr(p) < .05;
                windows = mask_windows(mask, time);
            else
                windows = cluster_windows(testing - reference, time, cfg.clusterPermutations);
            end
            for w = 1:size(windows, 1)
                row = table(conditionNames(c - 1), windows(w, 1), windows(w, 2), ...
                            'VariableNames', {'condition', 'start', 'end'});
                rows = addrow(rows, row);
            end
        end
        if isempty(rows)
            rows = table(strings(0, 1), zeros(0, 1), zeros(0, 1), 'VariableNames', {'condition', 'start', 'end'});
        end
        writetable(rows, fullfile(outDir, method, sprintf('significance_windows_%s_bn_%d.csv', block.name, network)));
    end
end

function p = paired_p(X)
    n = sum(isfinite(X), 2);
    mu = mean(X, 2, 'omitnan');
    sd = std(X, 0, 2, 'omitnan');
    p = nan(size(mu));
    zero = n >= 2 & sd == 0;
    p(zero & mu == 0) = 1;
    p(zero & mu ~= 0) = 0;
    valid = n >= 2 & sd > 0;
    t = mu(valid) ./ (sd(valid) ./ sqrt(n(valid)));
    df = n(valid) - 1;
    p(valid) = betainc(df ./ (df + t.^2), df / 2, .5);
end

% Control time-wise error while preserving the temporal dependence of within-subject effects.
function windows = cluster_windows(X, time, nPerm)
    tObs = t_values(X);
    threshold = sqrt(2) * erfcinv(.05);
    [observed, bounds] = clusters(tObs, threshold);
    null = zeros(nPerm, 1);
    for p = 1:nPerm
        flips = ones(1, size(X, 2));
        flips(rand(1, size(X, 2)) < .5) = -1;
        values = clusters(t_values(X .* flips), threshold);
        if ~isempty(values)
            null(p) = max(values);
        end
    end
    windows = zeros(0, 2);
    for i = 1:numel(observed)
        if (sum(null >= observed(i)) + 1) / (nPerm + 1) <= .05
            windows(end + 1, :) = [time(bounds(i, 1)) time(bounds(i, 2))];
        end
    end
end

function t = t_values(X)
    n = sum(isfinite(X), 2);
    t = mean(X, 2, 'omitnan') ./ (std(X, 0, 2, 'omitnan') ./ sqrt(n));
    t(~isfinite(t) | n < 2) = 0;
end

function [values, bounds] = clusters(t, threshold)
    [ps, pe] = runs(t >= threshold);
    [ns, ne] = runs(t <= -threshold);
    bounds = [[ps; ns] [pe; ne]];
    [~, order] = sort(bounds(:, 1));
    bounds = bounds(order, :);
    values = zeros(size(bounds, 1), 1);
    for i = 1:size(bounds, 1)
        values(i) = sum(abs(t(bounds(i, 1):bounds(i, 2))));
    end
end

function windows = mask_windows(mask, time)
    [starts, ends] = runs(mask);
    windows = [time(starts) time(ends)];
end

function [starts, ends] = runs(mask)
    edges = diff([false; mask(:); false]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
end

% Attach participant identities and experimental labels to the blockwise RQA output.
function rows = rqa_rows(cfg, block, window, R)
    rows = table();
    map = sortrows(cfg.map(cfg.map.melody_length == block.length, :), 'participant_index');
    for participant = 1:numel(R.RQA_metrics)
        m = R.RQA_metrics{participant};
        subject = map.subject_id(map.participant_index == participant);
        for c = 1:3
            row = table(participant, subject, block.name, block.length, window(1), window(2), c, cfg.families(c), cfg.familyLabels(c), ...
                        m.RR(c), m.L(c), m.DET(c), m.ENTR(c), m.TT(c), m.LAM(c), m.V_max(c), m.DIV(c), ...
                        'VariableNames', {'participant_index', 'subject_id', 'block', 'melody_length', 'window_start_sec', 'window_end_sec', 'condition_index', 'condition_family', 'condition_label', 'RR', 'L', 'DET', 'ENTR', 'TT', 'LAM', 'V_max', 'DIV'});
            rows = addrow(rows, row);
        end
    end
end

% Relate the first three network activations at each time point to behaviour.
function rows = activation_correlations(cfg, block, time, ts, behaviour)
    rows = table();
    map = sortrows(cfg.map(cfg.map.melody_length == block.length, :), 'participant_index');
    blockBehaviour = behaviour(behaviour.block == block.name, :);
    for network = 1:3
        for c = 1:3
            yAccuracy = nan(height(map), 1);
            yRt = yAccuracy;
            for s = 1:height(map)
                match = blockBehaviour.subject_id == map.subject_id(s) & blockBehaviour.condition_index == c;
                if any(match)
                    yAccuracy(s) = blockBehaviour.accuracy(find(match, 1));
                    yRt(s) = blockBehaviour.mean_rt(find(match, 1));
                end
            end
            X = squeeze(ts(:, network, c, map.participant_index));
            for outcome = ["accuracy" "mean_rt"]
                if outcome == "accuracy"
                    y = yAccuracy;
                else
                    y = yRt;
                end
                nTime = numel(time);
                r = nan(nTime, 1);
                p = r;
                n = zeros(nTime, 1);
                for t = 1:nTime
                    valid = isfinite(X(t, :)') & isfinite(y);
                    n(t) = sum(valid);
                    [r(t), p(t)] = pearson_stats(X(t, valid)', y(valid));
                end
                adjusted = bh_fdr(p);
                significant = adjusted < .05;
                tCrit = tinv(.975, max(n) - 2);
                unc = sqrt(tCrit^2 / (tCrit^2 + max(n) - 2));
                if any(significant)
                    fdr = min(abs(r(significant)));
                else
                    fdr = NaN;
                end
                row = table(repmat(block.name, nTime, 1), repmat(block.length, nTime, 1), repmat(network, nTime, 1), repmat(c, nTime, 1), ...
                            repmat(cfg.families(c), nTime, 1), repmat(cfg.familyLabels(c), nTime, 1), repmat(outcome, nTime, 1), time, r, p, adjusted, n, p < .05, significant, repmat(unc, nTime, 1), repmat(fdr, nTime, 1), ...
                            'VariableNames', {'block', 'melody_length', 'network_index', 'condition_index', 'condition_family', 'condition_label', 'outcome', 'time', 'r', 'p_value', 'p_value_fdr', 'n', 'significant_uncorrected', 'significant_fdr', 'r_uncorrected_threshold', 'r_fdr_threshold'});
                rows = addrow(rows, row);
            end
        end
    end
end
