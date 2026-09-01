% Derive subject-level behavioural measures and the reported inferential statistics.
function out = analyse_behaviour(cfg)
    trials = load_trials(cfg);
    subjects = unique(trials.subject_id, 'stable');
    [responses, rt, summary] = subject_values(trials, subjects, cfg);

    statsDir = fullfile(cfg.output, 'statistics');
    if ~exist(statsDir, 'dir')
        mkdir(statsDir);
    end

    responseComparisons = response_comparisons(responses);
    rtComparisons = rt_comparisons(rt);
    writetable(summary, fullfile(statsDir, 'behaviour_subject.csv'));
    writetable(descriptives(responses, rt), fullfile(statsDir, 'behaviour_descriptives.csv'));
    writetable(anovas(responses, rt), fullfile(statsDir, 'behaviour_anova.csv'));
    writetable(responseComparisons, fullfile(statsDir, 'behaviour_response_comparisons.csv'));
    writetable(rtComparisons, fullfile(statsDir, 'behaviour_comparisons.csv'));

    out = struct('trials', trials, 'subjects', subjects, 'responses', responses, ...
                 'rt', rt, 'summary', summary);
end

% Reconstruct trial condition and correctness from the task's recorded response scheme.
function trials = load_trials(cfg)
    T = readtable(fullfile(cfg.input, 'trial_inclusion.csv'), 'TextType', 'string');
    subject = pad(string(T.subject_id), 4, 'left', '0');
    mapped = cfg.map.subject_id + ":" + cfg.map.melody_length;
    selected = ismember(subject + ":" + T.melody_length, mapped);
    T = T(selected, :);
    subject = subject(selected);
    included = logical(T.include);
    trial = strtrim(string(T.trial));
    response = lower(strtrim(string(T.response)));
    tone = str2double(string(regexp(cellstr(trial), '(?<=t)\d+(?=e)', 'match', 'once')));
    condition = nan(height(T), 1);
    condition(startsWith(trial, "old_")) = 1;
    for b = 1:3
        block = T.melody_length == cfg.blocks(b).length;
        condition(block & tone == cfg.blocks(b).tones(1)) = 2;
        condition(block & tone == cfg.blocks(b).tones(2)) = 3;
    end
    expected = repmat("y", height(T), 1);
    expected(condition == 1) = "r";
    category = repmat("wrong", height(T), 1);
    category(response == expected) = "right";
    category(response == "0" | strlength(response) == 0 | ismissing(response)) = "no_answer";
    keep = isfinite(condition) & included;
    cond = condition(keep);
    lengths = T.melody_length(keep);
    trials = table(subject(keep), "m" + lengths, lengths, cond, cfg.families(cond)', cfg.familyLabels(cond)', category(keep), T.rt(keep), ...
                   'VariableNames', {'subject_id', 'block', 'melody_length', 'condition_index', 'condition_family', 'condition_label', 'response_category', 'rt'});
    trials = sortrows(trials, {'subject_id', 'melody_length', 'condition_index'});
end

% Create the subject-level condition means used throughout the behavioural analyses.
function [responseCube, rtCube, summary] = subject_values(trials, subjects, cfg)
    responseCube = nan(numel(subjects), 3, 3, 3);
    rtCube = nan(numel(subjects), 2, 3, 3);
    summary = table();
    categories = ["right" "wrong" "no_answer"];
    for s = 1:numel(subjects)
        for l = 1:3
            for c = 1:3
                mask = trials.subject_id == subjects(s) & trials.melody_length == cfg.blocks(l).length & trials.condition_index == c;
                selected = trials(mask, :);
                if isempty(selected)
                    continue
                end
                for r = 1:3
                    responseCube(s, r, c, l) = mean(selected.response_category == categories(r));
                end
                rtCube(s, 1, c, l) = mean(selected.rt(selected.response_category == "right"), 'omitnan');
                rtCube(s, 2, c, l) = mean(selected.rt(selected.response_category == "wrong"), 'omitnan');
                registered = selected.response_category ~= "no_answer";
                row = table(subjects(s), cfg.blocks(l).name, cfg.blocks(l).length, c, cfg.families(c), ...
                            cfg.familyLabels(c), responseCube(s, 1, c, l), responseCube(s, 2, c, l), responseCube(s, 3, c, l), ...
                            mean(selected.rt(registered), 'omitnan'), rtCube(s, 1, c, l), rtCube(s, 2, c, l), height(selected), ...
                            'VariableNames', {'subject_id', 'block', 'melody_length', 'condition_index', ...
                                              'condition_family', 'condition_label', 'accuracy', 'incorrect', 'no_response', ...
                                              'mean_rt', 'correct_rt', 'incorrect_rt', 'n_trials'});
                summary = addrow(summary, row);
            end
        end
    end
    summary = sortrows(summary, {'subject_id', 'melody_length', 'condition_index'});
end

% Report response and reaction-time summaries for the samples supporting each analysis.
function T = descriptives(Y, RT)
    T = table();
    responses = ["Correct" "Incorrect" "No response"];
    rtResponses = ["Correct RT" "Incorrect RT"];
    lengths = [3 5 7];
    complete = all(isfinite(reshape(Y, size(Y, 1), [])), 2);
    for l = 1:3
        for c = 1:3
            row = table(lengths(l), c, "", ...
                        'VariableNames', {'melody_length', 'condition_index', 'measure'});
            for r = 1:3
                x = Y(complete, r, c, l);
                q = row;
                q.measure = responses(r);
                q.n = numel(x);
                q.mean = mean(x);
                q.sd = std(x);
                T = addrow(T, q);
            end
            for r = 1:2
                x = RT(:, r, c, l);
                x = x(isfinite(x));
                q = row;
                q.measure = rtResponses(r);
                q.n = numel(x);
                q.mean = mean(x);
                q.sd = std(x);
                T = addrow(T, q);
            end
        end
    end
end

% Test omnibus within-subject effects using complete repeated-measures observations.
function T = anovas(Y, RT)
    T = table();
    labels = ["Correct" "Incorrect" "No response" "Correct RT" "Incorrect RT"];
    for outcome = 1:5
        if outcome <= 3
            cube = squeeze(Y(:, outcome, :, :));
        else
            cube = squeeze(RT(:, outcome - 3, :, :));
        end
        cube = cube(all(isfinite(reshape(cube, size(cube, 1), [])), 2), :, :);
        a = rm_anova2(cube);
        effects = {a.a, a.b, a.interaction};
        names = ["condition" "melody_length" "interaction"];
        raw = [effects{1}.p effects{2}.p effects{3}.p];
        adjusted = bh_fdr(raw);
        for e = 1:3
            s = effects{e};
            row = table(labels(outcome), names(e), size(cube, 1), s.F, s.df, s.df_error, s.p, adjusted(e), s.eta2, ...
                        'VariableNames', {'outcome', 'effect', 'n', 'F_statistic', 'df_effect', 'df_error', 'p_value', 'p_value_fdr', 'partial_eta_squared'});
            T = addrow(T, row);
        end
    end
end

% Evaluate planned paired response contrasts with correction within each contrast family.
function T = response_comparisons(Y)
    T = table();
    pairs = [1 2; 1 3; 2 3];
    responses = ["correct" "incorrect" "no_response"];
    conditions = ["old" "early" "late"];
    for r = 1:3
        for l = 1:3
            for p = 1:3
                a = pairs(p, 1);
                b = pairs(p, 2);
                T = add_response_row(T, "condition", responses(r), l, conditions(a), responses(r), l, conditions(b), Y(:, r, a, l), Y(:, r, b, l));
            end
        end
    end
    T.p_value_fdr_family = bh_fdr(T.p_value);
    T.significant_fdr_family = T.p_value_fdr_family < .05;
    T.display_significance = stars(T.p_value_fdr_family);
    T = movevars(T, {'p_value_fdr_family', 'significant_fdr_family', 'display_significance'}, 'After', 'p_value');
end

function T = add_response_row(T, family, ra, la, ca, rb, lb, cb, x, y)
    lengths = [3 5 7];
    s = paired_stats(x, y);
    boxa = "m" + lengths(la) + "_" + ra + "_" + ca;
    boxb = "m" + lengths(lb) + "_" + rb + "_" + cb;
    row = table(family, boxa, boxb, ra, lengths(la), ca, rb, lengths(lb), cb, s.n, s.mean_a, s.mean_b, s.mean_difference, s.sd_difference, s.t, s.df, s.p, ...
                'VariableNames', {'comparison_family', 'box_a', 'box_b', 'response_a', 'melody_length_a', 'condition_a', 'response_b', 'melody_length_b', 'condition_b', 'n_subjects', 'mean_a', 'mean_b', 'mean_difference', 'sd_difference', 't_statistic', 'degrees_of_freedom', 'p_value'});
    T = addrow(T, row);
end

% Evaluate planned paired reaction-time contrasts with correction within each contrast family.
function T = rt_comparisons(Y)
    T = table();
    pairs = [1 2; 1 3; 2 3];
    responses = ["Right" "Wrong"];
    families = ["old" "early_change" "late_change"];
    for l = 1:3
        for c = 1:3
            T = add_rt_row(T, "right_vs_wrong_within_cell", 1, 2, l, l, c, c, Y(:, 1, c, l), Y(:, 2, c, l), responses, families);
        end
    end
    for r = 1:2
        for l = 1:3
            for p = 1:3
                a = pairs(p, 1);
                b = pairs(p, 2);
                T = add_rt_row(T, "condition_within_melody_and_response", r, r, l, l, a, b, Y(:, r, a, l), Y(:, r, b, l), responses, families);
            end
        end
    end
    for r = 1:2
        for c = 1:3
            for p = 1:3
                a = pairs(p, 1);
                b = pairs(p, 2);
                T = add_rt_row(T, "melody_within_condition_and_response", r, r, a, b, c, c, Y(:, r, c, a), Y(:, r, c, b), responses, families);
            end
        end
    end
    T.p_value_fdr_family = nan(height(T), 1);
    for family = unique(T.comparison_family)'
        mask = T.comparison_family == family;
        T.p_value_fdr_family(mask) = bh_fdr(T.p_value(mask));
    end
    T.p_value_fdr_45way = bh_fdr(T.p_value);
    T.significant_fdr_family = T.p_value_fdr_family < .05;
    T.significant_fdr_45way = T.p_value_fdr_45way < .05;
    T.significance_fdr_45way = stars(T.p_value_fdr_45way);
    T = movevars(T, {'p_value_fdr_family', 'p_value_fdr_45way', 'significant_fdr_family', 'significant_fdr_45way', 'significance_fdr_45way'}, 'After', 'p_value');
end

function T = add_rt_row(T, family, ra, rb, la, lb, ca, cb, x, y, responses, families)
    lengths = [3 5 7];
    labels = ["M" "Early Change" "Late Change"];
    s = paired_stats(x, y);
    row = table(family, responses(ra), responses(rb), lengths(la), lengths(lb), "M" + lengths(la), "M" + lengths(lb), ca, cb, families(ca), families(cb), labels(ca), labels(cb), s.n, s.mean_a, s.mean_b, s.mean_difference, s.sd_difference, s.t, s.df, s.p, s.ci_low, s.ci_high, s.dz, ...
                'VariableNames', {'comparison_family', 'response_a', 'response_b', 'melody_length_a', 'melody_length_b', 'melody_length_a_label', 'melody_length_b_label', 'condition_a_index', 'condition_b_index', 'condition_a_family', 'condition_b_family', 'condition_a_label', 'condition_b_label', 'n_subjects', 'mean_a', 'mean_b', 'mean_difference', 'sd_difference', 't_statistic', 'degrees_of_freedom', 'p_value', 'ci_low', 'ci_high', 'cohens_dz'});
    T = addrow(T, row);
end

function out = stars(p)
    out = strings(size(p));
    out(p < .05) = "*";
    out(p < .01) = "**";
    out(p < .001) = "***";
end
