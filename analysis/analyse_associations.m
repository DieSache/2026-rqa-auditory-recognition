% Relate recurrent structure and activation to behaviour using the manuscript's eligible samples.
function analyse_associations(cfg, rawRqa, behaviour, activation)
    excluded = unique(rawRqa.subject_id(rawRqa.RR == 0));
    rqa = rawRqa(~ismember(rawRqa.subject_id, excluded), :);
    linked = innerjoin(rqa, behaviour.summary, 'Keys', {'subject_id', 'block', 'condition_index'}, 'RightVariables', {'accuracy', 'mean_rt'});
    outDir = fullfile(cfg.output, '5_rqa_correlations');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    byCell = correlations(linked, {'block', 'melody_length', 'condition_index', 'condition_family'}, cfg.metrics);
    vars = [{'accuracy', 'mean_rt'}, cellstr(cfg.metrics)];
    byCondition = groupsummary(linked, {'subject_id', 'condition_index', 'condition_family'}, 'mean', vars);
    byCondition = rename_means(byCondition, vars);
    byLength = groupsummary(linked, {'subject_id', 'block', 'melody_length'}, 'mean', vars);
    byLength = rename_means(byLength, vars);
    byCondition = correlations(byCondition, {'condition_index', 'condition_family'}, cfg.metrics);
    byLength = correlations(byLength, {'block', 'melody_length'}, cfg.metrics);
    models = mixed_models(linked, cfg.metrics);

    writetable(byCell, fullfile(outDir, 'by_cell.csv'));
    writetable(byCondition, fullfile(outDir, 'by_condition.csv'));
    writetable(byLength, fullfile(outDir, 'by_length.csv'));
    writetable(models, fullfile(cfg.output, 'statistics', 'rqa_behaviour_models.csv'));
    writetable(significance_bars(activation), fullfile(cfg.output, 'statistics', 'activation_behaviour_significance.csv'));
end

% Compute grouped RQA-behaviour correlations and their metric-wise correction families.
function T = correlations(data, groups, metrics)
    T = table();
    [id, groupTable] = findgroups(data(:, groups));
    for metric = metrics
        for g = 1:height(groupTable)
            mask = id == g;
            x = data.(metric)(mask);
            for outcome = ["accuracy" "mean_rt"]
                y = data.(outcome)(mask);
                valid = isfinite(x) & isfinite(y);
                [r, p] = pearson_stats(x(valid), y(valid));
                row = groupTable(g, :);
                row.metric = metric;
                row.outcome = outcome;
                row.n = sum(valid);
                row.r = r;
                row.p_value = p;
                T = addrow(T, row);
            end
        end
    end
    T.p_value_fdr_8way = nan(height(T), 1);
    fdrGroups = [groups, {'outcome'}];
    [id, sets] = findgroups(T(:, fdrGroups));
    for g = 1:height(sets)
        mask = id == g;
        T.p_value_fdr_8way(mask) = bh_fdr(T.p_value(mask));
    end
    T = movevars(T, 'p_value_fdr_8way', 'After', 'p_value');
end

function T = rename_means(T, names)
    for i = 1:numel(names)
        old = "mean_" + names{i};
        T.Properties.VariableNames{strcmp(T.Properties.VariableNames, old)} = names{i};
    end
end

% Test overall and condition- or melody-dependent within-subject RQA associations.
function T = mixed_models(data, metrics)
    T = table();
    for metric = metrics
        for outcome = ["accuracy" "mean_rt"]
            x = data.(metric);
            y = data.(outcome);
            valid = isfinite(x) & isfinite(y);
            x = x(valid);
            y = y(valid);
            model = table(categorical(data.subject_id(valid)), categorical(data.condition_family(valid)), categorical("M" + data.melody_length(valid)), y, (x - mean(x)) / std(x), ...
                          'VariableNames', {'subject_id', 'condition_family', 'melody_length', 'behaviour_value', 'rqa_value_z'});
            fit = fitlme(model, ['behaviour_value ~ condition_family*melody_length + rqa_value_z + ', ...
                                 'condition_family:rqa_value_z + melody_length:rqa_value_z + (1|subject_id)']);
            a = anova(fit, 'DFMethod', 'Satterthwaite');
            for term = ["rqa_value_z" "condition_family:rqa_value_z" "melody_length:rqa_value_z"]
                rowIndex = find(string(a.Term) == term, 1);
                row = table(metric, outcome, height(model), term, a.FStat(rowIndex), a.DF1(rowIndex), a.DF2(rowIndex), a.pValue(rowIndex), ...
                            'VariableNames', {'metric', 'outcome', 'n_rows', 'effect', 'F_statistic', 'df_effect', 'df_error', 'p_value'});
                T = addrow(T, row);
            end
        end
    end
    T.fdr_family = replace(T.effect, ["rqa_value_z" "condition_family:rqa_value_z" "melody_length:rqa_value_z"], ...
                           ["overall_8way" "condition_interaction_8way" "melody_interaction_8way"]);
    T.p_value_fdr_family = nan(height(T), 1);
    [id, sets] = findgroups(T(:, {'outcome', 'fdr_family'}));
    for g = 1:height(sets)
        mask = id == g;
        T.p_value_fdr_family(mask) = bh_fdr(T.p_value(mask));
    end
    T = movevars(T, {'fdr_family', 'p_value_fdr_family'}, 'After', 'p_value');
end

% Convert significant activation-behaviour samples into intervals for the time-series figures.
function T = significance_bars(data)
    groups = {'block', 'melody_length', 'network_index', 'condition_index', 'condition_family', 'condition_label', 'outcome'};
    [id, groupTable] = findgroups(data(:, groups));
    T = table();
    for g = 1:height(groupTable)
        rows = sortrows(data(id == g, :), 'time');
        [starts, ends] = runs(rows.significant_fdr);
        for i = 1:numel(starts)
            row = groupTable(g, :);
            row.start_time = rows.time(starts(i));
            row.end_time = rows.time(ends(i));
            row.n_timepoints = ends(i) - starts(i) + 1;
            row.min_r = min(rows.r(starts(i):ends(i)));
            row.max_r = max(rows.r(starts(i):ends(i)));
            row.r_fdr_threshold = rows.r_fdr_threshold(starts(i));
            T = addrow(T, row);
        end
    end
end

function [starts, ends] = runs(mask)
    edges = diff([false; logical(mask(:)); false]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
end
