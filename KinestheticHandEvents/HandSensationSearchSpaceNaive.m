%% Kinesthetic parameter exploration with Naive user:
% - Filter dataset (waveform type, manual removals, truncation, amplitude range)
% - Classify trials by sensation outcome: noVib, none, sensed
% - Plot Frequency vs Amplitude map with category colors and boundary lines
% - Build Gaussian “hotspot” surface from sensed events
% - Summarize distributions (histograms, daboxplots) and print means
% This code generates all the components of Fig 2B illustration.

clc; clear; close all;

%% -------------------------- Load data & validate -------------------------
dataFile = 'KinestheticData.mat';
load(dataFile, 'HandIllusionsNotesv1');

% Validate expected variables
reqVars = {'WaveformType','Amplitude','Frequency','Sensation'};
missingVars = reqVars(~ismember(reqVars, HandIllusionsNotesv1.Properties.VariableNames));
if ~isempty(missingVars)
    error('Missing required variables: %s', strjoin(missingVars, ', '));
end

% Normalize types for robustness
if ~iscategorical(HandIllusionsNotesv1.WaveformType)
    HandIllusionsNotesv1.WaveformType = categorical(HandIllusionsNotesv1.WaveformType);
end
if ~iscategorical(HandIllusionsNotesv1.Sensation)
    HandIllusionsNotesv1.Sensation = categorical(HandIllusionsNotesv1.Sensation);
end

%% ------------------- Remove one waveform type (verify label) -------------
% NOTE: check your category name. If you meant "SQW" (square waves), use that.
% The original code used "STW". We'll keep it as a parameter for clarity:
waveformToRemove = "STW";   % <-- CHANGE to "SQW" if that is your square label
rmIdx = (HandIllusionsNotesv1.WaveformType == waveformToRemove);
HandIllusionsNotesv1(rmIdx, :) = [];

%% -------------------- Optional manual row removals -----------------------
% Remove hand trials obtained when user non-naive by index
idx2remove = [13 14 15 27 28 30 31 32 35 36 37];   % <- as provided
idx2remove = idx2remove(idx2remove <= height(HandIllusionsNotesv1)); % guard
if ~isempty(idx2remove)
    HandIllusionsNotesv1(idx2remove, :) = [];
end

%% ----------------------------- Truncate (optional) -----------------------
% Keep only the first N rows after filtering; if empty, keep all.
startIdx = 283;  % <-- set [] to keep all rows
if ~isempty(startIdx)
    startIdx = min(startIdx, height(HandIllusionsNotesv1));
    HandIllusionsNotesv1 = HandIllusionsNotesv1(1:startIdx, :);
end

%% ----------------------- Amplitude range filtering -----------------------
HandIllusionsNotesv1 = HandIllusionsNotesv1(HandIllusionsNotesv1.Amplitude < 130, :);

%% ------------------ Build sensation category masks -----------------------
idxNoSense = (HandIllusionsNotesv1.Sensation == "none");
idxNoVib   = (HandIllusionsNotesv1.Sensation == "noVib");
idxSense   = ~(idxNoSense | idxNoVib);   % all other labels imply sensation

AmplitudeData = HandIllusionsNotesv1.Amplitude;
FrequencyData = HandIllusionsNotesv1.Frequency;

%% --------------------------- 2D scatter map ------------------------------
figure('Color','w');
hold on; grid on;
% noVib (blue, small)
scatter(AmplitudeData(idxNoVib), ...
        FrequencyData(idxNoVib), ...
        8, 'filled', 'MarkerFaceColor', 'b', 'DisplayName', 'No vibration');

% none (black, small)
scatter(AmplitudeData(idxNoSense), ...
        FrequencyData(idxNoSense), ...
        8, 'filled', 'MarkerFaceColor', 'k', 'DisplayName', 'No sensation');

% sensed (red, larger)
scatter(AmplitudeData(idxSense), ...
        FrequencyData(idxSense), ...
        20, 'filled', 'MarkerFaceColor', 'r', 'DisplayName', 'Kinesthetic');

% Boundaries at 5 and 130
yline(5,   'k--');
xline(5,   'k--');
yline(130, 'k--');
xline(130, 'k--');

xlabel('Amplitude (\muNm)');
ylabel('Frequency (Hz)');
legend('Location','northwest');
xlim([0 132]); ylim([0 132]);
axis square;  % optional styling
hold off;

%% ---------------------- Gaussian hotspot surface -------------------------
% Parameters for Gaussian accumulation
sigma = 5/3;   % NOTE: interpreted as standard deviation
A     = 5;     % kernel amplitude

% Centers for each class
centerSens   = [AmplitudeData(idxSense)   FrequencyData(idxSense)];
centerNoSens = [AmplitudeData(idxNoSense) FrequencyData(idxNoSense)];
centerNoVib  = [AmplitudeData(idxNoVib)   FrequencyData(idxNoVib)];

% Parameter grid (AA = amplitude axis, FF = frequency axis)
[AA, FF] = meshgrid(1:0.25:122, 1:0.25:132);
a = AA(:);
f = FF(:);

% Accumulate Gaussians for sensed events
mat = zeros(size(a));
for i = 1:numel(a)
    % Sum kernels for all centers reporting sensation
    for j = 1:size(centerSens, 1)
        % IMPORTANT: use sigma^2 in the Gaussian if sigma is std dev
        mat(i) = mat(i) + A * gaussC(a(i), f(i), sigma, centerSens(j, :));
    end

    % If you want to penalize "no sensation" points, uncomment & adjust:
    % for j = 1:size(centerNoSens, 1)
    %     mat(i) = mat(i) - A * gaussC(a(i), f(i), sigma, centerNoSens(j, :));
    % end
end

% Mask small values for display
mat(mat < 0.25) = NaN;

% 3D surface plot
cmap = turbo(32);
figure('Units','normalized','Position',[0.2 0.2 0.7 0.6],'Color','w');
hold on;
surf(AA, FF, reshape(mat, size(AA)), 'EdgeColor','none');
colormap(cmap);
chb = colorbar;
clim([0 20]);                         % adjust to taste
chb.Ticks = 0:4:20;                   % 0,5,10,15,20
chb.TickLabels = string(0:1:5);       % default labels to match ticks

% Mark centers
scatter3(centerSens(:,1), centerSens(:,2), (max(mat)+5)*ones(size(centerSens,1)), ...
    35, 'filled', 'MarkerFaceColor','r', 'MarkerEdgeColor','r');
plot3(centerNoSens(:,1), centerNoSens(:,2), (max(mat)+1)*ones(size(centerNoSens,1)), 'kx', 'LineWidth', 1.5);
plot3(centerNoVib(:,1),  centerNoVib(:,2),  (max(mat)+1)*ones(size(centerNoVib,1)),  'bo', 'LineWidth', 1.5);

% Vertical “stems” for reference
Npt = 2;
for j = 1:size(centerNoSens,1)
    line(ones(Npt,1)*centerNoSens(j,1), ones(Npt,1)*centerNoSens(j,2), [0 max(mat)+1], ...
        'Color','k','LineStyle','--');
end
for j = 1:size(centerNoVib,1)
    line(ones(Npt,1)*centerNoVib(j,1), ones(Npt,1)*centerNoVib(j,2), [0 max(mat)+1], ...
        'Color','b','LineStyle','--');
end
for j = 1:size(centerSens,1)
    line(ones(Npt,1)*centerSens(j,1), ones(Npt,1)*centerSens(j,2), [0 max(mat)+5], ...
        'Color','r','LineStyle','--');
end

% Bounds rectangle over data extents (needs width & height, not max values)
aMin = min(AmplitudeData); aMax = max(AmplitudeData);
fMin = min(FrequencyData); fMax = max(FrequencyData);
rectangle('Position', [aMin, fMin, (aMax-aMin), (fMax-fMin)], ...
          'FaceColor', [cmap(1,:) 0.7], 'EdgeColor', cmap(1,:));

xlim([0 132]); ylim([0 132]); zlim([0 32]);
view(-40, 70);
axis off;    % presentation style; turn on if you want axes
hold off;

%% ---------------------- Distribution summaries ---------------------------
% External toolbox for data viz
addpath(genpath('frank-pk-DataViz-3.2.3.0'));

handSens    = FrequencyData(idxSense);
torqueSens  = AmplitudeData(idxSense);
torqueAt90  = torqueSens(handSens == 90);

disp('Average frequency for hand sensation during naive exploration is:');
disp(mean(handSens));

disp('Average torque delivered to experience movement illusion (all sensed trials):');
disp(mean(torqueSens));

% Aesthetic color
colorBox = [0.0196078431372549, 0.23921568627450981, 0.33725490196078434];

% Histogram of amplitudes (3D-styled view)
figure('Units','normalized','Position',[0.2 0.2 0.7 0.6],'Color','w');
hold on;
histogram(torqueSens, 'BinWidth', 5, 'FaceColor', colorBox);
set(gca, 'YDir','reverse');  % stylistic
plot3([mean(torqueSens) mean(torqueSens)], [0 30], [0 0], 'k--');  % guide line
xlim([0 132]); ylim([0 132]); zlim([0 28]);
view(-40, 70);
hold off;

% Histogram of frequencies (3D-styled view)
figure('Units','normalized','Position',[0.2 0.2 0.7 0.6],'Color','w');
hold on;
histogram(handSens, 'BinWidth', 5, 'FaceColor', colorBox);
plot3([mean(handSens) mean(handSens)], [0 30], [0 0], 'k--');
xlim([0 132]); ylim([0 132]); zlim([0 28]);
view(230, 70);  % 50+180
hold off;

% Box+scatter panels with mirrored histograms
figure('Units','normalized','Position',[0.2 0.2 0.3 0.7],'Color','w');

subplot(2,2,1);
daboxplot(handSens, 'groups', ones(size(handSens)), 'scatter',1, ...
    'scattersize',15, 'scatteralpha',0.5, 'colors', colorBox, ...
    'whiskers',1, 'mean',1, 'outliers',0);
ylim([5 130]);
title('Frequency (sensed)');

subplot(2,2,2);
hold on;
histogram(handSens, 'Normalization','pdf', 'BinWidth',5, 'FaceColor', colorBox);
set(gca, 'XDir','reverse');
xlim([5 130]); axis off; camroll(-90);
title('Freq. density');

subplot(2,2,3);
daboxplot(torqueSens, 'groups', ones(size(torqueSens)), 'scatter',1, ...
    'scattersize',15, 'scatteralpha',0.5, 'colors', colorBox, ...
    'whiskers',1, 'mean',1, 'outliers',0);
ylim([5 95]);
title('Amplitude (sensed)');

subplot(2,2,4);
hold on;
histogram(torqueSens, 'Normalization','pdf', 'BinWidth',5, 'FaceColor', colorBox);
set(gca, 'XDir','reverse');
xlim([5 122]); axis off; camroll(-90);
title('Amp. density');

%% --------------------- Helper: 2D Gaussian (centered) --------------------
% Standard isotropic Gaussian in (x,y). IMPORTANT: use sigma^2 in denom.
function val = gaussC(x, y, sigma, center)
    xc = center(1); yc = center(2);
    r2 = (x - xc).^2 + (y - yc).^2;
    val = exp(- r2 ./ (2 * sigma^2));  % corrected formula
end
