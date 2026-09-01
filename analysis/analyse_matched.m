% Test the joint RQA contribution beyond whole-window activation amplitude.
function analyse_matched(cfg, rawRqa, behaviour, amplitude)
    excluded = unique(rawRqa.subject_id(rawRqa.RR == 0));
    rqa = rawRqa(~ismember(rawRqa.subject_id, excluded), :);
    data = innerjoin(rqa, behaviour, 'Keys', {'subject_id', 'block', 'melody_length', 'condition_index'}, ...
                     'RightVariables', {'accuracy'});
    data = innerjoin(data, amplitude, 'Keys', {'subject_id', 'block', 'melody_length', 'condition_index'});
    valid = isfinite(data.accuracy) & isfinite(data.amplitude_rms) & ...
            all(isfinite(data{:, cellstr(cfg.metrics)}), 2);
    data = data(valid, :);
    model = model_data(data, cfg.metrics);

    base = "accuracy ~ condition_family * melody_length + amplitude_z";
    joint = base + " + " + join(cfg.metrics + "_z", " + ");
    reduced = fitlme(model, base + " + (1|subject_id)", 'FitMethod', 'ML', 'DummyVarCoding', 'effects');
    full = fitlme(model, joint + " + (1|subject_id)", 'FitMethod', 'ML', 'DummyVarCoding', 'effects');
    [baseR2, fullR2] = deal(marginal_r2(reduced), marginal_r2(full));
    jointLR = 2 * (full.LogLikelihood - reduced.LogLikelihood);
    rows = table("joint", "all_eight", height(data), numel(unique(data.subject_id)), NaN, NaN, NaN, NaN, ...
                 jointLR, 8, gammainc(max(jointLR, 0) / 2, 4, 'upper'), NaN, fullR2 - baseR2, ...
                 "primary_joint_block", 'VariableNames', paper_names());

    p = nan(numel(cfg.metrics), 1);
    metricRows = table();
    ci = coefCI(full);
    for i = 1:numel(cfg.metrics)
        name = cfg.metrics(i) + "_z";
        dropFormula = base + " + " + join((cfg.metrics(cfg.metrics ~= cfg.metrics(i)) + "_z"), " + ");
        drop = fitlme(model, dropFormula + " + (1|subject_id)", 'FitMethod', 'ML', 'DummyVarCoding', 'effects');
        lr = 2 * (full.LogLikelihood - drop.LogLikelihood);
        p(i) = gammainc(max(lr, 0) / 2, .5, 'upper');
        index = find(string(full.Coefficients.Name) == name, 1);
        row = table("metric", cfg.metrics(i), height(data), numel(unique(data.subject_id)), ...
                    full.Coefficients.Estimate(index), full.Coefficients.SE(index), ci(index, 1), ci(index, 2), ...
                    lr, 1, p(i), NaN, fullR2 - marginal_r2(drop), ...
                    "descriptive_drop_one_due_to_collinearity", 'VariableNames', paper_names());
        metricRows = addrow(metricRows, row);
    end
    metricRows.p_value_fdr_8way = bh_fdr(p);
    rows = addrow(rows, metricRows);
    statsDir = fullfile(cfg.output, 'statistics');
    writetable(rows, fullfile(statsDir, 'matched_rqa_paper.csv'));
end

function D = model_data(data, metrics)
    D = table(categorical(data.subject_id), categorical(data.condition_family), ...
              categorical("M" + data.melody_length), data.accuracy, ...
              zscore(data.amplitude_rms), 'VariableNames', ...
              {'subject_id', 'condition_family', 'melody_length', 'accuracy', 'amplitude_z'});
    for metric = metrics
        D.(metric + "_z") = zscore(data.(metric));
    end
end

function r2 = marginal_r2(fit)
    fixed = fitted(fit, 'Conditional', false);
    [random, residual] = covarianceParameters(fit);
    r2 = var(fixed, 1) / (var(fixed, 1) + random{1}(1) + residual);
end

function names = paper_names
    names = {'result_type', 'metric', 'n_rows', 'n_subjects', 'standardized_coefficient', ...
             'standard_error', 'ci_95_low', 'ci_95_high', 'likelihood_ratio_chisq', ...
             'degrees_of_freedom', 'p_value', 'p_value_fdr_8way', 'incremental_marginal_R2', ...
             'inference_role'};
end
