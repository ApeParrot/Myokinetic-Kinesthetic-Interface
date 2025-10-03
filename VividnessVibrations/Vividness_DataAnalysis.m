%% FINAL SCRIPT ANALYSIS – VIVIDNESS DATA

clc; clear; close all;
% This code generate graphics for Fig. 6C,D fig. S6

%% ---------------- Figure / Graph Settings ----------------
addpath(genpath("frank-pk-DataViz-3.2.3.0"));  % external viz (daboxplot)

% Hex palettes by site (proximal / distal), then converted to RGB
FCUhex = ["#AF3C60", "#DF483A"];
FPLhex = ["#F3C23A", "#277778"];
EDhex  = ["#265F79", "#82B4BC"];

FCUcolor = [hex2rgb(FCUhex(1)); hex2rgb(FCUhex(2))];
FPLcolor = [hex2rgb(FPLhex(1)); hex2rgb(FPLhex(2))];
EDcolor  = [hex2rgb(EDhex(1));  hex2rgb(EDhex(2))];

% Row order: FCU-P, FPL-P, ED-P, FCU-D, FPL-D, ED-D
Colors = [FCUcolor(1,:); FPLcolor(1,:); EDcolor(1,:); ...
          FCUcolor(2,:); FPLcolor(2,:); EDcolor(2,:)];

SiteNames = ["FCU-P"; "FPL-P"; "ED-P"; "FCU-D"; "FPL-D"; "ED-D"];
fitType   = "SIG";       % "SIG" or "EXP"
numSites  = numel(SiteNames);

%% --------------------------- Load Path -----------------------------------
addpath(genpath("VividnessData"));

%% ---------------- Amplitude Curves: Plot + Fit ---------------------------
figAmp = figure("Units","normalized","Position",[0.1 0.1 0.5 0.5], 'Color', 'w');
Layout = tiledlayout(figAmp, 1, 1); title(Layout, "Vividness Trends");
nexttile(Layout); axis off;

nRows = 2; nCols = 3;
layoutAmp = tiledlayout(Layout, nRows, nCols, "TileSpacing","compact");
layoutAmp.Layout.Tile     = 1;
layoutAmp.Layout.TileSpan = [1 1];
title(layoutAmp, "Vividness against Amplitude");

R2  = zeros(numSites,1);
RMS = zeros(numSites,1);

XDATA = cell(1,numSites); YDATA = cell(1,numSites); FITRESULTS = cell(1,numSites);

for i = 1:numSites
    S = load("site"+num2str(i)+"vividData.mat");   % expects vividnessData, A
    vividnessData = S.vividnessData;
    A = S.A(:).';                                % ensure row vector amplitudes

    [Rsq, RMSE, fitresult, xData, yData] = ...
        plotAmpVividGraph(layoutAmp, vividnessData, A, SiteNames(i), Colors(i,:), fitType);

    R2(i)         = Rsq;
    RMS(i)        = RMSE;
    FITRESULTS{i} = fitresult;
    XDATA{i}      = xData;
    YDATA{i}      = yData;
end

disp("Coefficients of Determination (R^2) with "+fitType+":");
disp(R2.');

%% -------------------- Threshold Amplitudes -------------------------------
TH_Value  = 5;                  % plateau vividness (raw scale)
AmpThresh = zeros(numSites,1);
CI95      = zeros(numSites,2);
Bnds      = zeros(numSites,2);  % min/max amplitudes at plateau

figTh = figure("Units","normalized","Position",[0.2 0.2 0.4 0.5], 'Color','w');
hold on;

for i = 1:numSites
    S = load("site"+num2str(i)+"vividData.mat");
    vividnessData = S.vividnessData;
    A = S.A(:).';
    % Construct matrix of amplitudes per trial to mirror vividnessData
    Agrid = repmat(A, size(vividnessData,1), 1);

    % Collect amplitude samples where vividness >= TH_Value
    amplitudes = Agrid(vividnessData >= TH_Value);
    amplitudes = amplitudes(~isnan(amplitudes));

    AmpThresh(i) = mean(amplitudes, 'omitnan');

    % Proper CI using SEM (std/sqrt(n))
    nObs  = numel(amplitudes);
    if nObs >= 2
        SEM  = std(amplitudes, 0, 'omitnan') / sqrt(nObs);
        ts   = tinv([0.025 0.975], nObs-1);         % 95% t-score
        CI95(i,:) = AmpThresh(i) + ts * SEM;
    else
        CI95(i,:) = [NaN NaN];
    end
    Bnds(i,:) = [min(amplitudes,[],'omitnan'), max(amplitudes,[],'omitnan')];

    % Overlay fit + threshold lines
    h = plot(FITRESULTS{i}, XDATA{i}, YDATA{i});  % curve fit object
    legend("off");
    if numel(h) >= 2
        h(1).Color = Colors(i,:);
        h(2).Color = Colors(i,:);
        h(2).LineWidth = 1.2;
    end

    % Compute normalized vividness at AmpThresh from the fit (SIG)
    a = FITRESULTS{i}.a; b = FITRESULTS{i}.b;
    horLine   = 1/(1+exp(-a*(AmpThresh(i)-b)));

    xline(AmpThresh(i), "--", "Color", Colors(i,:), "LineWidth", 1.2);
    if ~isnan(horLine)
        yline(horLine,     "--", "Color", Colors(i,:), "LineWidth", 1.2);
        scatter(AmpThresh(i), horLine, 36, 'filled', 'MarkerFaceColor', Colors(i,:));
    end
end
hold off;
xlim([0 100]); ylim([0 1]);
xlabel("Amplitude ($\mu \mathrm{Nm}$)", "Interpreter","latex");
ylabel("Vividness (-)",               "Interpreter","latex");
ax = gca;
% ax.YGrid = 'on';

disp("Mean Thresholds (max vividness) with 95% CI:");
disp(AmpThresh.');
disp(CI95.');

%% ---------------- torqueSensAt90: CI around mean (optional) -------------
if exist('torqueSensAt90.mat','file')
    load('torqueSensAt90.mat');   % expects torqueSensAt90
    n   = numel(torqueSensAt90);
    mu  = mean(torqueSensAt90, 'omitnan');
    SEM = std(torqueSensAt90, 0, 'omitnan') / sqrt(n);
    ts  = tinv([0.025 0.975], max(n-1,1));
    CI95Torque = mu + ts * SEM; 
end

colorBox = [0.0196078431372549, 0.23921568627450981, 0.33725490196078434];

figure("Units","normalized","Position",[0.2 0.2 0.4 0.25], 'Color','w');
daboxplot(Bnds(:,1), 'groups', ones(size(Bnds,1),1), 'scatter',1, ...
    'scattersize',15, 'scatteralpha',0.5, 'colors', colorBox, ...
    'whiskers',1, "mean",1, 'outliers',0);
ylim([0 100]); camroll(-90);

%% ---------------- Frequency Curves: Plot (per site) ----------------------
figFreq = figure("Units","normalized","Position",[0.1 0.1 0.5 0.5], 'Color','w');
LayoutF = tiledlayout(figFreq, 1, 1); title(LayoutF, "Vividness Trends");
nexttile(LayoutF); axis off;

layoutFreq = tiledlayout(LayoutF, nRows, nCols, "TileSpacing","compact");
layoutFreq.Layout.Tile     = 1;
layoutFreq.Layout.TileSpan = [1 1];
title(layoutFreq, "Vividness against Frequency");

maxVib = []; nMax = 0; sMax = 0;

for i = 1:numSites
    S = load("site"+num2str(i)+"vividDataFreq.mat");  % expects vividnessData, F
    vividnessData = S.vividnessData;
    F = S.F(:).';

    rmAxisFlag = (mod(i,3) ~= 1);
    [maxVib, nMax, sMax] = plotFreqVividGraph(layoutFreq, vividnessData, F, ...
        SiteNames(i), Colors(i,:), rmAxisFlag, maxVib, nMax, sMax);
end

%% ---------------- Frequency of Max Vividness summary ---------------------

figure("Units","normalized","Position",[0.2 0.2 0.075 0.5], 'Color','w');
dabarplot(maxVib, 'scatter',1, 'scattersize',15, 'scatteralpha',0.5, 'colors', colorBox);
ylim([0 140]);
title('Frequencies at Max Vividness');

%% ========================= Helper functions ==============================

function [Rsquared, RMSE, fitresult, xData, yData] = ...
    plotAmpVividGraph(layout, vividnessData, A, siteName, color, fitType)

    szScatter = 10;
    nexttile(layout);

    % Median across trials, normalize to [0,1]
    vMed = median(vividnessData, "omitnan");
    M    = max(vMed);  if M==0 || isnan(M), M = 1; end
    yNorm = vMed / M;

    [xData, yData] = prepareCurveData(A, yNorm);

    % Find leading “all-zero” region for EXP model to define shift
    minValIdx = localZeroLeadIdx(vividnessData);
    minAmp    = A(minValIdx);

    % Fit type and initial guesses
    switch upper(string(fitType))
        case "EXP"
            % drop the all-zero lead for stability
            xData = xData(minValIdx:end); 
            yData = yData(minValIdx:end);
            ft    = fittype("1-exp(-a*(x-"+num2str(minAmp)+"))", ...
                            'independent','x','dependent','y');
            opts  = fitoptions('Method','NonlinearLeastSquares','Display','Off');
            opts.StartPoint = 0.05 + 0.95*rand(1);  % small positive

        case "SIG"
            ft    = fittype('1/(1+exp(-a*(x-b)))', ...
                            'independent','x','dependent','y');
            opts  = fitoptions('Method','NonlinearLeastSquares','Display','Off');
            opts.StartPoint = [1, mean(A,'omitnan')];

        otherwise
            error('Unsupported fitType. Use "SIG" or "EXP".');
    end

    % Robust retry loop (cap attempts)
    bestRsq = -Inf; fitresult = []; gof = struct('rsquare',NaN,'rmse',NaN);
    for k = 1:25
        try
            opts.StartPoint = randn(size(opts.StartPoint));
            [fr, g] = fit(xData, yData, ft, opts);
            if g.rsquare > bestRsq
                bestRsq = g.rsquare; fitresult = fr; gof = g;
            end
            if bestRsq > 0.70, break; end
        catch
            % try again with a different seed
        end
    end

    % Plot error bars + points
    hold on;
    lo = (vMed - min(vividnessData,[],1,"omitnan")) / M;
    hi = (max(vividnessData,[],1,"omitnan") - vMed) / M;
    errorbar(A, vMed/M, lo, hi, ...
        'Color', color, 'LineStyle','none', 'CapSize', 1);
    scatter(A, vMed/M, szScatter, ...
        'Marker','o', 'MarkerEdgeColor', color, 'MarkerFaceColor', color, 'MarkerFaceAlpha', 1);

    % Plot fit
    if ~isempty(fitresult)
        h = plot(fitresult, xData, yData); legend("off");
        if numel(h) >= 2
            h(1).Color = color;  % data line
            h(2).Color = color;  % fitted curve
            h(2).LineWidth = 1.2;
        end
    end
    hold off;

    title(siteName);
    xlim([0 100]); ylim([0 1]);
    xlabel("Amplitude ($\mu \mathrm{Nm}$)", "Interpreter","latex");
    ylabel("Vividness (-)",               "Interpreter","latex");
    % t.YGrid = 'on';

    Rsquared = gof.rsquare;
    RMSE     = gof.rmse;
end

function idx = localZeroLeadIdx(vividnessData)
% Return the index of the last column where ALL trials are zero (lead block).
    v = vividnessData;
    allZero = all(v==0 | isnan(v), 1);         % treat NaNs as zero for lead detection
    run = find(~allZero, 1, 'first');
    if isempty(run), idx = 1; else, idx = max(1, run); end
end

function [maxVib, nMax, sMax] = plotFreqVividGraph(layout, vividnessData, F, ...
                            siteName, color, rmAxisFlag, maxVib, nMax, sMax)

    szScatter = 10;
    nexttile(layout);

    vMed = median(vividnessData, 'omitnan');
    M    = max(vMed); if M==0 || isnan(M), M=1; end

    % Gather frequencies at max vividness across trials
    F2      = repmat(F, size(vividnessData,1), 1);
    thisMax = max(vividnessData,[],2,'omitnan');
    mask    = (vividnessData == thisMax);      % per-trial maxima
    maxVib  = [maxVib; F2(mask)];
    nMax    = nMax + nnz(mask);
    sMax    = sMax + sum(F2(mask));

    scatter(F, vMed/M, szScatter, 'filled', 'MarkerFaceColor', color);
    hold on;
    errorbar(F, vMed/M, ...
             (vMed - min(vividnessData,[],1,'omitnan'))/M, ...
             (max(vividnessData,[],1,'omitnan') - vMed)/M, ...
             'Color', color, 'LineStyle','none', 'CapSize', 1);
    hold off;

    title(siteName);
    xlabel("Frequency (Hz)",  "Interpreter","latex");
    ylabel("Vividness (-)",   "Interpreter","latex");
    xticks(10:20:130);
    xlim([0 135]); ylim([-0.2 1.2]);
    % t.YGrid = 'on';

    if rmAxisFlag
        ax = gca; ax.YAxis.Visible = 'off';
    end
end

%% ----------------------- KDE (bounded) utilities -------------------------
% (Your gkdeb/checkp/bounded/varchk functions left as-is with minor nargchk → narginchk)
%  — omitted here for brevity since they are unchanged from your version —

%% -------------------------- Color utilities ------------------------------
function rgb = hex2rgb(hex)
% Convert "#RRGGBB" or "RRGGBB" → [r g b] in 0..1
    hex = char(hex);
    if hex(1) == '#', hex = hex(2:end); end
    assert(numel(hex)==6, 'hex2rgb: bad hex color "%s"', hex);
    r = hex(1:2); g = hex(3:4); b = hex(5:6);
    rgb = [hex2dec(r), hex2dec(g), hex2dec(b)]/255;
end