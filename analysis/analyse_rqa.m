% Produce RQA statistics from a common participant sample across all metrics.
function [anovaTable, descriptiveTable, comparisonTable] = analyse_rqa(cfg, raw, writeOutputs)
    if nargin < 3
        writeOutputs = true;
    end
    excluded = unique(raw.subject_id(raw.RR == 0));
    rqa = raw(~ismember(raw.subject_id, excluded), :);

    [anovaTable, cubes] = rqa_anova(rqa, cfg);
    descriptiveTable = rqa_descriptives(cubes, cfg);
    comparisonTable = rqa_comparisons(cubes, anovaTable, cfg);
    if writeOutputs
        statsDir = fullfile(cfg.output, 'statistics');
        writetable(anovaTable, fullfile(statsDir, 'rqa_anova.csv'));
        writetable(descriptiveTable, fullfile(statsDir, 'rqa_descriptives.csv'));
        writetable(comparisonTable, fullfile(statsDir, 'rqa_comparisons.csv'));
        writetable(plot_data(rqa), fullfile(cfg.output, 'rqa_metric_distributions_plot_data.csv'));
    end
end

% Test condition and melody-length effects in complete repeated-measures RQA data.
function [T, cubes] = rqa_anova(rqa, cfg)
    subjects = unique(rqa.subject_id, 'stable');
    T = table();
    cubes = cell(numel(cfg.metrics), 1);
    for m = 1:numel(cfg.metrics)
        Y = metric_cube(rqa, subjects, cfg.metrics(m));
        Y = Y(all(isfinite(reshape(Y, size(Y, 1), [])), 2), :, :);
        cubes{m} = Y;
        stats = rm_anova2(Y);
        effects = {stats.a, stats.b, stats.interaction};
        names = ["condition" "melody_length" "condition_x_melody_length"];
        for e = 1:3
            s = effects{e};
            row = table(cfg.metrics(m), names(e), size(Y, 1), "M | Early Change | Late Change", "M3 | M5 | M7", s.F, s.df, s.df_error, s.p, s.eta2, ...
                        'VariableNames', {'metric', 'effect', 'n', 'condition_levels', 'melody_length_levels', 'F_statistic', 'df_effect', 'df_error', 'p_value', 'partial_eta_squared'});
            T = addrow(T, row);
        end
    end
    T.p_value_fdr_8way = nan(height(T), 1);
    for effect = unique(T.effect)'
        mask = T.effect == effect;
        T.p_value_fdr_8way(mask) = bh_fdr(T.p_value(mask));
    end
    T = movevars(T, 'p_value_fdr_8way', 'After', 'p_value');
end

function Y = metric_cube(rqa, subjects, metric)
    Y = nan(numel(subjects), 3, 3);
    lengths = [3 5 7];
    for l = 1:3
        for c = 1:3
            rows = rqa(rqa.melody_length == lengths(l) & rqa.condition_index == c, {'subject_id', char(metric)});
            [found, index] = ismember(rows.subject_id, subjects);
            values = rows.(metric);
            Y(index(found), c, l) = values(found);
        end
    end
end

function T = rqa_descriptives(cubes, cfg)
    T = table();
    for m = 1:numel(cfg.metrics)
        Y = cubes{m};
        conditionMeans = squeeze(mean(Y, 3));
        for c = 1:3
            x = conditionMeans(:, c);
            row = table(cfg.metrics(m), c, cfg.families(c), cfg.familyLabels(c), numel(x), mean(x), std(x), ...
                        'VariableNames', {'metric', 'condition_index', 'condition_family', 'condition_label', 'n', 'mean', 'sd'});
            T = addrow(T, row);
        end
    end
end

% Test planned condition contrasts on the melody-averaged RQA measures.
function T = rqa_comparisons(cubes, anovaTable, cfg)
    T = table();
    pairs = [1 2; 1 3; 2 3];
    for m = 1:numel(cfg.metrics)
        means = squeeze(mean(cubes{m}, 3));
        omnibus = anovaTable(anovaTable.metric == cfg.metrics(m) & anovaTable.effect == "condition", :);
        for p = 1:3
            a = pairs(p, 1);
            b = pairs(p, 2);
            s = paired_stats(means(:, a), means(:, b));
            row = table(cfg.metrics(m), omnibus.p_value, omnibus.p_value_fdr_8way, a, b, cfg.familyLabels(a), cfg.familyLabels(b), s.n, s.mean_a, s.mean_b, s.mean_difference, s.sd_difference, s.t, s.df, s.p, s.ci_low, s.ci_high, s.dz, ...
                        'VariableNames', {'metric', 'omnibus_p_value', 'omnibus_p_value_fdr_8way', 'condition_a_index', 'condition_b_index', 'condition_a_label', 'condition_b_label', 'n_subjects', 'mean_a', 'mean_b', 'mean_difference', 'sd_difference', 't_statistic', 'degrees_of_freedom', 'p_value', 'ci_low', 'ci_high', 'cohens_dz'});
            T = addrow(T, row);
        end
    end
end

function T = plot_data(rqa)
    T = table();
    base = {'participant_index', 'block', 'melody_length', 'window_start_sec', 'window_end_sec', 'condition_index', 'condition_family', 'condition_label'};
    [~, lengthIndex] = ismember(rqa.melody_length, [3 5 7]);
    group = (lengthIndex - 1) * 3 + rqa.condition_index;
    for metric = ["DET" "DIV" "ENTR" "L" "LAM" "RR" "TT" "V_max"]
        rows = rqa(:, base);
        rows.plot_group_index = group;
        rows.metric = repmat(metric, height(rows), 1);
        rows.value = rqa.(metric);
        T = addrow(T, rows);
    end
end
