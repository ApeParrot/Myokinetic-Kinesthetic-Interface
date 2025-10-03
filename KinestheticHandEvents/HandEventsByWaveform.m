%% Kinesthetic Parameter Map: Frequency vs. Amplitude by Waveform
% This script loads experimental stimulation notes, and visualizes 
% Frequency (Hz) vs. Amplitude (µNm) for Sine vs Square waves.
%
% INPUT:
%   KinestheticData.mat
%     -> HandIllusionsNotesv1 (table) with columns:
%           WaveformType : string/categorical (e.g., "SIN" or "SQW")
%           Amplitude    : numeric, µNm
%           Frequency    : numeric, Hz
%
% OUTPUT:
%   Scatter plot of Frequency vs Amplitude, grouped by waveform type.
%
% This Script generates fig. S2B of the Paper.

clc; clear; close all;

%% ---------------------- Load & basic validation -------------------------
dataFile = 'KinestheticData.mat';
load(dataFile, 'HandIllusionsNotesv1');

% Validate expected variables
reqVars = {'WaveformType','Amplitude','Frequency'};
missingVars = reqVars(~ismember(reqVars, HandIllusionsNotesv1.Properties.VariableNames));
if ~isempty(missingVars)
    error('Missing required variables in table: %s', strjoin(missingVars, ', '));
end

% Normalize types
if ~iscategorical(HandIllusionsNotesv1.WaveformType)
    HandIllusionsNotesv1.WaveformType = categorical(HandIllusionsNotesv1.WaveformType);
end

%% -------------------------- Optional row removal ------------------------
% If you need to remove specific rows by index, list them here:
idx2remove = [];  % e.g., [5, 13]
if ~isempty(idx2remove)
    HandIllusionsNotesv1(idx2remove, :) = [];
end

%% -------------------------- Optional truncation -------------------------
% If you want to limit to the first N rows, set N here. Otherwise leave [].
N = [];  % e.g., N = 200;
if ~isempty(N)
    N = min(N, height(HandIllusionsNotesv1));
    HandIllusionsNotesv1 = HandIllusionsNotesv1(1:N, :);
end

%% ---------------------------- Filter by range ---------------------------
% Remove out-of-range amplitudes (>= 130 µNm), consistent with paper figures
HandIllusionsNotesv1 = HandIllusionsNotesv1(HandIllusionsNotesv1.Amplitude < 130, :);

% OPTIONAL: also filter frequency range if desired, e.g.:
% HandIllusionsNotesv1 = HandIllusionsNotesv1(HandIllusionsNotesv1.Frequency <= 130, :);

%% -------------------- Recompute waveform masks (important!) -------------
% Compute after all filtering so indices align with current table
isSquare = (HandIllusionsNotesv1.WaveformType == "SQW");
isSine   = ~isSquare;  % assuming only SIN and SQW present

%% ------------------------------- Plot -----------------------------------
figure('Color','w'); hold on; grid on;

% Plot Sine first (black squares)
h1 = scatter(HandIllusionsNotesv1.Amplitude(isSine), ...
             HandIllusionsNotesv1.Frequency(isSine), ...
             35, 'k', 'filled', 'Marker', 's', 'DisplayName', 'Sine');

% Plot Square second (blue diamonds)
h2 = scatter(HandIllusionsNotesv1.Amplitude(isSquare), ...
             HandIllusionsNotesv1.Frequency(isSquare), ...
             35, 'b', 'filled', 'Marker', 'd', 'DisplayName', 'Square');

xlabel('Amplitude (\muNm)');
ylabel('Frequency (Hz)');
legend([h1 h2], 'Location', 'bestoutside');

% Axes formatting
xlim([0 130]);
ylim([0 130]);
% axis equal; % Enable only if you want 1:1 scaling
title('Stimulation Parameter Map by Waveform');

hold off;
