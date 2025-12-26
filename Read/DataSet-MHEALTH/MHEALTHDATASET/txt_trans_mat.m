%% Robust batch convert (OLD MATLAB compatible)
clc; clear;

inputDir  = pwd;
outputDir = fullfile(pwd, 'MAT');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

% Get all files in current folder
allFiles = dir(inputDir);
allFiles = allFiles(~[allFiles.isdir]);

% Keep files whose name contains "mHealth_subject"
names = {allFiles.name};
idx = false(size(names));
for k = 1:numel(names)
    idx(k) = ~isempty(strfind(lower(names{k}), 'mhealth_subject'));
end
files = allFiles(idx);

fprintf('Current folder: %s\n', inputDir);
fprintf('Found %d subject files\n\n', numel(files));

if isempty(files)
    error('No mHealth_subject files found.');
end

for i = 1:numel(files)
    infile = fullfile(inputDir, files(i).name);

    % Read file (robust)
    D = importdata(infile);
    if isstruct(D) && isfield(D, 'data')
        X = D.data;
    else
        X = D;
    end

    % Remove all-NaN rows
    X = X(~all(isnan(X),2), :);

    % Output .mat name
    [~, name, ~] = fileparts(files(i).name);
    outfile = fullfile(outputDir, [name '.mat']);   % char

    % Save (old MATLAB style)
    save(outfile, 'X');

    fprintf('[%02d/%02d] %s -> %s | %dx%d\n', ...
        i, numel(files), files(i).name, [name '.mat'], size(X,1), size(X,2));
end

fprintf('\n✅ Done! MAT files saved in: %s\n', outputDir);
