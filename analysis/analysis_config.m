function cfg = analysis_config
    cfg.root = fileparts(fileparts(mfilename('fullpath')));
    cfg.input = fullfile(cfg.root, 'input');
    cfg.output = fullfile(cfg.root, 'output');
    cfg.broadness = fullfile(cfg.root, 'BROADNESS');
    cfg.metrics = ["RR" "L" "DET" "ENTR" "TT" "LAM" "V_max" "DIV"];
    cfg.rqaThreshold = .1;
    cfg.rqaThresholdSensitivity = [.05 .075 .1 .125 .15];
    cfg.families = ["old" "early_change" "late_change"];
    cfg.familyLabels = ["M" "Early change" "Late change"];
    cfg.blocks = struct( ...
                        'name', {"m3", "m5", "m7"}, ...
                        'length', {3, 5, 7}, ...
                        'tones', {[2 3], [3 5], [5 7]}, ...
                        'events', {(0:2) * .350, (0:4) * .350, (0:6) * .350});
    cfg.clusterPermutations = 2000;
    cfg.workbench = getenv('WB_COMMAND');
    if strlength(cfg.workbench) == 0
        cfg.workbench = 'wb_command';
    end
end
