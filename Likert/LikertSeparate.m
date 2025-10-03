%% Likert diverging stacked chart + nonparametric tests
% This script:
%  1) Arranges a 7x repeated 4-question Likert dataset (values in -2..+2)
%  2) Computes percentage breakdown per category and builds a
%     diverging stacked barh (with symmetric 0 bin split)
%  3) Shows a grouped likert for Pair 1 and Pair 2
%
% This code generates Fig. 4A and B of the Manuscript

clc; clear; close all;

%% --------------------------- Raw data -----------------------------------
load LikertAnswers.mat

%% ---------------------- Basic sizes / checks -----------------------------
numQuestions = size(Qs, 2);        % Expect 4
numCases     = 7;                   % Given in your notes
nTotal       = size(Qs, 1);
assert(mod(nTotal,2) == 0, 'Total rows must split evenly into two phases.');
halfN        = nTotal/2;

% Helpful constants
likertScores = -2:2;
numLikert    = numel(likertScores);

%% ---------------------- FIRST LIKERT PLOT (plot 1) ----------------------
% Select the first half of rows for phase A
blockA = Qs(1:halfN, :);
yA     = build_phase_matrix(blockA, numCases);        % arrange by question/case
y2A    = likert_percentages(yA, likertScores);        % % by category
y6A    = to_diverging6(y2A);                          % 6-stack diverging
plot_diverging_barh(y6A, numCases, numQuestions, 'Plot 1');

% (Original line renamed to reflect it computes a median)
overallMedianA = median(yA(:));
disp(['Phase A overall median answer = ', num2str(overallMedianA)]);

%% --------------------- SECOND LIKERT PLOT (plot 2) ----------------------
% Select the second half of rows for phase B
blockB = Qs(halfN+1:end, :);
yB     = build_phase_matrix(blockB, numCases);
y2B    = likert_percentages(yB, likertScores);
y6B    = to_diverging6(y2B);
plot_diverging_barh(y6B, numCases, numQuestions, 'Plot 2');

%% ========================= Helper functions ==============================

function Y = build_phase_matrix(blockQs, numCases)
% Arrange an interleaved-by-case matrix of size (R*numCases) x 4
% into rows grouped by question, in the order Q1..Q4, each with 'numCases' rows.
    numQuestions = size(blockQs,2);
    rowsThisBlock = size(blockQs,1);
    assert(mod(rowsThisBlock, numCases) == 0, 'Rows not divisible by numCases.');
    reps = rowsThisBlock / numCases;  % e.g., 3 blocks per case here

    % Build Y by stacking case slices for Q1..Q4
    Y = [];
    for i = 1:numCases
        % For each case i, take rows i, i+numCases, ..., i+(reps-1)*numCases
        sel = i:numCases:(i + (reps-1)*numCases);
        % Append as Q1; Q2; Q3; Q4 rows for this case
        Y = [Y;
             blockQs(sel,1)';   % Q1 for this case across reps (row vector)
             blockQs(sel,2)';   % Q2
             blockQs(sel,3)';   % Q3
             blockQs(sel,4)'];  % Q4
    end
    % Final size: (numQuestions * numCases) x reps
end

function Y2 = likert_percentages(Y, likertScores)
% Compute percent distribution across likertScores per row of Y
    [nRows, nReps] = size(Y);
    numLikert      = numel(likertScores);
    Y2 = zeros(nRows, numLikert);
    for i = 1:nRows
        for j = 1:numLikert
            Y2(i,j) = 100 * sum(Y(i,:) == likertScores(j)) / nReps;
        end
    end
end

function Y6 = to_diverging6(Y2)
% Convert 5-bin percentages [-2 -1 0 +1 +2]
% into a 6-bin diverging layout: [-2, -1, 0L, 0R, +1, +2]
    Y3 = Y2;
    % put -2, -1 on negative side
    Y3(:,1) = -Y3(:,1);
    Y3(:,2) = -Y3(:,2);
    % split 0 into half negative (0L) / half positive (0R)
    tmp0    = Y3(:,3);
    Y3(:,3) = -tmp0/2;       % 0L
    Y3(:,4) =  tmp0/2;       % 0R
    % +1 (col 4 in original Y2) should sit at bin 5; +2 (col 5) at bin 6
    Y3(:,5) = Y2(:,4);       % +1
    Y3(:,6) = Y2(:,5);       % +2

    % Flip order top-to-bottom for plotting aesthetics
    Y6 = flipud(Y3);
end

function plot_diverging_barh(Y6, numCases, numQuestions, titleStr)
% Draw diverging stacked horizontal bar chart for a 6-bin layout.
    x = 1:(numQuestions * numCases);
    idxOrder = [3 2 1 4 5 6];

    figure('Units','normalized','Position',[0.3 0.05 0.35 0.8], 'Color', 'w');
    BH = barh(x, Y6(:,idxOrder), 'stacked');

    % Colors for: [-2, -1, 0L, 0R, +1, +2]
    LikertColors = [ ...
        0.329, 0.584, 0.647;  % -2
        0.486, 0.604, 0.569;  % -1
        0.808, 0.804, 0.804;  %  0L
        0.808, 0.804, 0.804;  %  0R
        0.937, 0.792, 0.561;  % +1
        0.941, 0.580, 0.518]; % +2

    for k = 1:numel(BH)
        BH(k).FaceColor = LikertColors(idxOrder(k),:);
    end

    leg = legend({'0','-1','-2','0','+1','+2'}, ...
        'Orientation','horizontal','Location','southoutside');
    leg.String
    leg.AutoUpdate = 'off';

    % Y ticks centered in each question block
    set(gca,'YTick', (numCases/2) + numCases*(0:numQuestions-1));
    set(gca,'YTickLabel', fliplr({'Q1','Q2','Q3','Q4'})); % flipped to match flipud

    % Dashed separators between blocks
    hold on;
    for q = 1:numQuestions-1
        yline(q*numCases + 0.5, 'k--');
    end
    xline(0, 'k', 'LineWidth', 1);
    hold off;

    xlabel('Proportion of total responses (%)', 'Interpreter', 'latex');
    xlim([-120 120]);
    box off;
    % camroll(90)
    title(titleStr);
end
