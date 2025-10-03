%% FINAL SCRIPT ANALYSIS – Time Thresholds
% Computes minimum perceptible pulse duration thresholds per site from
% staircase/adaptive sequences; visualizes sequences and summarizes samples.
%
% This code generates Fig. 5A,b and fig. S5

clc; clear; close all;
warning off  % Not ideal — prefer fixing root causes or using warning('once',...)

%% ---------------- Figure / Graph Settings ----------------
% External viz toolbox (daboxplot)
addpath(genpath("frank-pk-DataViz-3.2.3.0"));

% Color palettes per site (proximal / distal) as HEX
FCUhex = ["#AF3C60", "#DF483A"];
FPLhex = ["#F3C23A", "#277778"];
EDhex  = ["#265F79", "#82B4BC"];

% Convert HEX -> RGB triplets for plotting robustness
FCUcolor = [hex2rgb(FCUhex(1)); hex2rgb(FCUhex(2))];
FPLcolor = [hex2rgb(FPLhex(1)); hex2rgb(FPLhex(2))];
EDcolor  = [hex2rgb(EDhex(1));  hex2rgb(EDhex(2)) ];

% Row order: FCU-P, FPL-P, ED-P, FCU-D, FPL-D, ED-D
Colors = [FCUcolor(1,:); FPLcolor(1,:); EDcolor(1,:); ...
          FCUcolor(2,:); FPLcolor(2,:); EDcolor(2,:)];

% greys and accents
grey        = [0.3 0.3 0.3];
forestgreen = [0 0.6 0.5];
skyblue     = [0.35 0.7 0.9];
vermilion   = [0.8 0.4 0.0]; %#ok<NASGU>

SiteNames = ["FCU-P"; "FPL-P"; "ED-P"; "FCU-D"; "FPL-D"; "ED-D"];
numSites  = numel(SiteNames);

% Plot axis defaults for sequence panels (tweak as needed)
xlimSeq = [0 60];
ylimSeq = [0 550];

%% ---------------------- Load Data Path -------------------
addpath(genpath("StimulationData"));

%% -------------------- Threshold Analysis -----------------
NumMin     = 3;                    % number of final minima used
samplesPer = 2*NumMin;             % minima and their preceding samples

thArray    = NaN(numSites,1);      % one threshold per site
samplArray = NaN(samplesPer, numSites); % 6×6: rows=samples, cols=sites

% Tiled layout: 6 sequence panels + 1 legend row
figure('Units','normalized','Position',[0.1 0.2 0.7 0.6], 'Color', 'w');
t1 = tiledlayout(7,3);
title(t1, "Pulse Duration Adaptive Sequences");
t1.Title.FontName  = 'times';
t1.Title.FontSize  = 18;
t1.Title.FontWeight= 'bold';

for i = 1:numSites
    fileName = "StimulationTimingsSite" + num2str(i) + ".mat";
    S = load(fileName);                 % expects variable 'StimulationTimings'
    data = S.StimulationTimings(:).';   % ensure row vector

    [th, samplIdx] = ComputeThreshold(data, NumMin);
    thArray(i)     = th;
    samplArray(:,i)= data(samplIdx).';  % store the 2*NumMin sample values

    % Sequence panel
    graph_sequence(data, th, samplIdx, Colors(i,:), SiteNames(i), xlimSeq, ylimSeq);

    % Hide y-axis for columns 2 and 3 (keep column 1)
    if mod(i,3) ~= 1
        ax = gca; ax.YAxis.Visible = 'off';
    end
end

% Legend row
nexttile([1 3]);
plot(nan, 'LineStyle','-','Color', grey, 'LineWidth',0.5, 'Marker','o', ...
    'MarkerFaceColor', grey, 'MarkerEdgeColor', grey, 'DisplayName',"Sequence");
hold on
scatter(nan, nan, 500, 'filled', 'Marker','square', ...
    'MarkerEdgeColor', grey, 'MarkerFaceColor', grey, 'DisplayName',"Samples");
yline(nan, 'Color', [0.6 0.6 0.6], 'LineStyle','--', 'LineWidth',1, 'DisplayName',"Threshold");
hold off
axis off
legend('Orientation','horizontal','Location','north', ...
       'FontSize',14,'FontName','times');

fprintf('Mean of the duration thresholds:   %.2f ms\n', mean(thArray,'omitnan'));
fprintf('Median of the duration thresholds: %.2f ms\n', median(thArray,'omitnan'));

%% -------------------- Summary Boxplots --------------------
% Group index: 6 groups (sites), 6 samples per group
group_inx = reshape(repmat(1:numSites, samplesPer, 1), [], 1);
dataVec   = samplArray(:);

% Colors for the 6 groups (numeric RGB, matching earlier order)
ColorsBox = [ ...
    0.6862745098039216 0.23529411764705882 0.3764705882352941;  % FCU-P
    0.9529411764705882 0.7607843137254902  0.22745098039215686; % FPL-P
    0.14901960784313725 0.37254901960784315 0.4745098039215686; % ED-P
    0.8745098039215686 0.2823529411764706  0.22745098039215686; % FCU-D
    0.15294117647058825 0.4666666666666667 0.47058823529411764; % FPL-D
    0.5098039215686274  0.7058823529411765 0.7372549019607844]; % ED-D

figure('Units','normalized','Position',[0.2 0.2 0.25 0.5], 'Color','w');

% Right y-axis: cycles at baseHz (default 90 Hz)
% baseHz = 90;              % adjust if needed
% yyaxis right
% ylabel('# cycles','FontSize',12)
% ax = gca; ax.FontName = 'times';
% % Show 0..5 cycles mapped into ms (1 cycle = 1000/baseHz ms)
% msTicks = (0:5) * (1000/baseHz);
% ylim([0 62]); yticks(msTicks); yticklabels(string(0:5));

% Left y-axis: durations
% yyaxis left
daboxplot(dataVec, 'groups', group_inx, 'colors', ColorsBox, ...
          'whiskers', 0, 'scatter', 1, 'jitter', 0, ...
          'scattersize', 13, 'scatteralpha', 0.5, 'mean', 1, 'boxwidth', 1.5);
ylabel('Duration (ms)','FontSize',12)
ylim([0 62]); yticks(0:10:60);
ax = gca; ax.FontName = 'times';
title('Samples around last minima (per site)');

%% ----------------------- Helper functions ------------------------

function [th, samplIdx] = ComputeThreshold(data, NumMin)
% Compute threshold from the last NumMin local minima and their preceding samples.
% RETURNS:
%   th        = median of the 2*NumMin samples (ms)
%   samplIdx  = 1×(2*NumMin) indices used to compute threshold

    if nargin < 2, NumMin = 3; end
    data = data(:).';  % row vector

    % Local minima indices
    mins = find(islocalmin(data));

    % Guard: need at least NumMin minima
    if numel(mins) < NumMin
        % Fallback: use last 2*NumMin points if not enough minima
        lastN = min(2*NumMin, numel(data));
        samplIdx = numel(data)-lastN+1 : numel(data);
        th = median(data(samplIdx));
        return;
    end

    % Take the last NumMin minima
    mins = mins(end-NumMin+1:end);

    % Preceding samples (guard against index 1)
    prev = max(mins - 1, 1);

    % Combine and sort unique indices
    samplIdx = sort(unique([prev, mins]));

    % If we somehow got fewer than 2*NumMin (e.g., duplicate at index 1), pad forwards
    while numel(samplIdx) < 2*NumMin && samplIdx(end) < numel(data)
        samplIdx(end+1) = samplIdx(end) + 1; %#ok<AGROW>
    end

    th = median(data(samplIdx));
end

function graph_sequence(data, th, samplIdx, color, titlestr, xlimSeq, ylimSeq)
% Plot a single sequence panel in the tiled layout.
    t = nexttile([3,1]);
    plot(data, 'LineStyle','-', 'Color',color, 'LineWidth',0.5, ...
         'Marker','o', 'MarkerSize',3, ...
         'MarkerFaceColor', color, 'MarkerEdgeColor', color, ...
         'DisplayName',"Sequence"); hold on
    scatter(samplIdx, data(samplIdx), 60, 'filled', ...
        'Marker','square', 'MarkerEdgeColor', color, ...
        'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.5, ...
        'DisplayName',"Samples");
    yline(th, 'Color', color, 'Linestyle','--', 'LineWidth',1, ...
        'DisplayName',"Threshold");
    hold off

    xlabel('Stimulus number','FontSize',12)
    ylabel('Duration (ms)','FontSize',12)
    title(titlestr)

    % Safe label positions (handle short sequences gracefully)
    tailN = min(30, numel(data));
    tailMax = max(data(max(1, end-tailN+1):end));
    text(numel(data), tailMax + 0.22*range(ylimSeq), ...
        "Median = " + num2str(th,'%.1f'), ...
        "HorizontalAlignment","right","FontSize",8,"Color",[0.6 0.6 0.6]);
    text(numel(data), tailMax + 0.08*range(ylimSeq), ...
        "Deviation = " + num2str(max(data(samplIdx)) - min(data(samplIdx)),'%.1f'), ...
        "HorizontalAlignment","right","FontSize",8,"Color",[0.6 0.6 0.6]);

    ylim(ylimSeq); xlim(xlimSeq);
    % t.YGrid = 'on';
    ax = gca; ax.FontName = 'times';
end

function rgb = hex2rgb(hex)
% Convert "#RRGGBB" (or "RRGGBB") to [r g b] in 0..1
    hex = char(hex);
    if hex(1) == '#', hex = hex(2:end); end
    if numel(hex) ~= 6, error('hex2rgb: bad hex color "%s"', hex); end
    r = hex(1:2); g = hex(3:4); b = hex(5:6);
    rgb = [hexpair2num(r), hexpair2num(g), hexpair2num(b)] / 255;
end

function out = hexpair2num(p)
    out = hex2dec(p);
end
