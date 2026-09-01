% Render spatial network patterns on a common cortical template for the manuscript figures.
function export_network_maps(cfg, block, B)
    target = fullfile(cfg.output, '3_timeseries');
    work = tempname;
    mkdir(work);
    cleanup = onCleanup(@() rmdir(work, 's'));
    coords = load(fullfile(cfg.broadness, 'BROADNESS_External', 'MNI152_8mm_coord_dyi.mat'), 'MNI8');
    options = struct('WhichPlots', [0 0 0 0 1], 'name_nii', work, 'MNI_coords', coords.MNI8, 'ncomps', 1:3);
    BROADNESS_Visualizer(B, options);
    source = fullfile(work, 'BROADNESS_Output', 'BROADNESS_nifti');
    for network = 1:3
        nii = fullfile(source, sprintf('PCA_ActivationPattern_BrainNetwork_#%d.nii', network));
        left = fullfile(work, sprintf('activation_%d_left.func.gii', network));
        right = fullfile(work, sprintf('activation_%d_right.func.gii', network));
        run_command(sprintf('"%s" -volume-to-surface-mapping "%s" "%s" "%s" -trilinear', cfg.workbench, nii, fullfile(cfg.input, 'neural', 'masks', 'ParcellationPilot.L.midthickness.32k_fs_LR.surf.gii'), left));
        run_command(sprintf('"%s" -volume-to-surface-mapping "%s" "%s" "%s" -trilinear', cfg.workbench, nii, fullfile(cfg.input, 'neural', 'masks', 'ParcellationPilot.R.midthickness.32k_fs_LR.surf.gii'), right));
        png = fullfile(target, sprintf('activation_pattern_%s_bn_%d.png', block.name, network));
        capture_scene(cfg, left, right, png);
    end
end

% Capture comparable transparent cortical views for every network and melody length.
function capture_scene(cfg, left, right, png)
    scene = fileread(fullfile(cfg.input, 'neural', 'template.scene'));
    surfaces = dir(fullfile(cfg.input, 'neural', 'masks', '*.surf.gii'));
    for i = 1:numel(surfaces)
        scene = strrep(scene, ['masks/' surfaces(i).name], fullfile(surfaces(i).folder, surfaces(i).name));
    end
    oldLeft = regexp(scene, '<Object Type="pathName" Name="dataFileName_V2">([^<]*_left\.func\.gii)</Object>', 'tokens', 'once');
    oldRight = regexp(scene, '<Object Type="pathName" Name="dataFileName_V2">([^<]*_right\.func\.gii)</Object>', 'tokens', 'once');
    scene = strrep(scene, oldLeft{1}, left);
    scene = strrep(scene, oldRight{1}, right);
    scene = strrep(scene, file_name(oldLeft{1}), file_name(left));
    scene = strrep(scene, file_name(oldRight{1}), file_name(right));
    path = [tempname(fileparts(png)) '.scene'];
    fid = fopen(path, 'w');
    fwrite(fid, scene);
    fclose(fid);
    cleanup = onCleanup(@() delete(path));
    run_command(sprintf('"%s" -scene-capture-image "%s" 1 "%s" -size-width-height 1600 1200', cfg.workbench, path, png));
    [rgb, ~, alpha] = imread(png);
    mask = rgb(:, :, 1) == 0 & rgb(:, :, 2) == 255 & rgb(:, :, 3) == 0;
    if isempty(alpha)
        alpha = uint8(255 * ones(size(mask)));
    end
    alpha(mask) = 0;
    imwrite(rgb, png, 'Alpha', alpha);
end

function run_command(command)
    [status, message] = system(command);
    if status ~= 0
        error('%s', strtrim(message));
    end
end

function name = file_name(path)
    [~, stem, extension] = fileparts(path);
    name = [stem extension];
end
