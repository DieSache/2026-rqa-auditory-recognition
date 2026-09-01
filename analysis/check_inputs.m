function check_inputs(cfg)
    paths = splitlines(string(strtrim(fileread(fullfile(cfg.root, 'required-inputs.txt')))));
    missing = strings(0);
    for i = 1:numel(paths)
        path = fullfile(cfg.root, char(paths(i)));
        if (contains(path, '*') && isempty(dir(path))) || ...
                (~contains(path, '*') && exist(path, 'file') == 0 && exist(path, 'dir') == 0)
            missing(end + 1) = paths(i);
        end
    end
    if ~isempty(missing)
        error('Missing required input:\n%s', join(missing, newline));
    end
end
