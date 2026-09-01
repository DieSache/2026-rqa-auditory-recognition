% Re-run the existing RQA statistics over prespecified recurrence thresholds.
function analyse_thresholds(cfg, raw)
    root = fullfile(cfg.output, 'robustness', 'thresholds');
    if ~exist(root, 'dir')
        mkdir(root);
    end
    anova = table();
    for threshold = cfg.rqaThresholdSensitivity
        selected = raw(raw.threshold == threshold, :);
        a = analyse_rqa(cfg, selected, false);
        a.threshold = repmat(threshold, height(a), 1);
        anova = addrow(anova, movevars(a, 'threshold', 'Before', 1));
    end
    writetable(anova, fullfile(root, 'rqa_threshold_anova.csv'));
end
