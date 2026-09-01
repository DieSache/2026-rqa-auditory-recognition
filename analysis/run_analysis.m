% Run the minimal pipeline that generates every manuscript output from the withheld inputs.
function run_analysis
    cfg = analysis_config;
    check_inputs(cfg);
    cfg.map = readtable(fullfile(cfg.input, 'neural_subjects.csv'), 'TextType', 'string');
    cfg.map.subject_id = pad(strtrim(cfg.map.subject_id), 4, 'left', '0');
    addpath(cfg.broadness);
    BROADNESS_Startup(cfg.broadness);
    if ~exist(cfg.output, 'dir')
        mkdir(cfg.output);
    end

    behaviour = analyse_behaviour(cfg);
    [rqa, activation, amplitude, thresholdRqa] = analyse_neural(cfg, behaviour);
    analyse_rqa(cfg, rqa);
    analyse_associations(cfg, rqa, behaviour, activation);
    analyse_thresholds(cfg, thresholdRqa);
    analyse_matched(cfg, rqa, behaviour.summary, amplitude);
    analyse_ridge(cfg, rqa, behaviour.summary, amplitude);
    write_sample_counts(cfg, rqa);
    write_participant_summary(cfg);
end

% Record blockwise and complete-case sample sizes needed by the manuscript.
function write_sample_counts(cfg, rqa)
    subjects = unique(cfg.map.subject_id);
    excluded = unique(rqa.subject_id(rqa.RR == 0));
    rows = table("initial", 0, numel(subjects), 'VariableNames', {'analysis', 'melody_length', 'n'});
    for b = 1:3
        blockSubjects = unique(cfg.map.subject_id(cfg.map.melody_length == cfg.blocks(b).length));
        rows = addrow(rows, table("retained", cfg.blocks(b).length, numel(blockSubjects), 'VariableNames', {'analysis', 'melody_length', 'n'}));
        rows = addrow(rows, table("rqa", cfg.blocks(b).length, sum(~ismember(blockSubjects, excluded)), 'VariableNames', {'analysis', 'melody_length', 'n'}));
    end
    counts = groupsummary(cfg.map, 'subject_id');
    rows = addrow(rows, table("complete", 0, sum(counts.GroupCount == 3), 'VariableNames', {'analysis', 'melody_length', 'n'}));
    rows = addrow(rows, table("rqa_complete", 0, sum(counts.GroupCount == 3 & ~ismember(counts.subject_id, excluded)), 'VariableNames', {'analysis', 'melody_length', 'n'}));
    rows = addrow(rows, table("rqa_excluded", 0, numel(excluded), 'VariableNames', {'analysis', 'melody_length', 'n'}));
    writetable(rows, fullfile(cfg.output, 'statistics', 'sample_counts.csv'));
end

% Validate the participant metadata against the analysis mapping and summarize it for Table 1.
function write_participant_summary(cfg)
    data = readtable(fullfile(cfg.input, 'participant_demographics.csv'), 'TextType', 'string');
    data.subject_id = pad(strtrim(string(data.subject_id)), 4, 'left', '0');
    subjects = sort(unique(cfg.map.subject_id));
    if height(data) ~= numel(subjects) || numel(unique(data.subject_id)) ~= height(data) || ...
            ~isequal(data.subject_id, sort(data.subject_id)) || ~isequal(data.subject_id, subjects)
        error('participant_demographics.csv must contain each mapped subject exactly once, sorted by subject_id.');
    end
    labels = ["Overall"; "Danish"; "Chinese"];
    rows = table('Size', [numel(labels), 10], ...
        'VariableTypes', ["string", repmat("double", 1, 9)], ...
        'VariableNames', {'group', 'n', 'age_n', 'age_mean', 'age_sd', 'age_min', 'age_max', 'female_n', 'male_n', 'compensation_dkk'});
    for i = 1:numel(labels)
        selected = labels(i) == "Overall" | data.group == labels(i);
        ages = data.age(selected & ~isnan(data.age));
        rows(i, :) = {labels(i), sum(selected), numel(ages), mean(ages), std(ages), min(ages), max(ages), ...
                      sum(selected & data.sex == "F"), sum(selected & data.sex == "M"), unique(data.compensation_dkk(selected))};
    end
    writetable(rows, fullfile(cfg.output, 'statistics', 'participant_summary.csv'));
end
