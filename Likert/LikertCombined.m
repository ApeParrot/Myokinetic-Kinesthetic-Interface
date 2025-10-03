%% Likert diverging stacked chart + nonparametric tests
% This script:
%  1) Arranges a 7x repeated 4-question Likert dataset (values in -2..+2)
%  2) Computes percentage breakdown per category and builds a
%     diverging stacked barh (with symmetric 0 bin split)
%  3) Runs Wilcoxon signed-rank tests (median vs 0)
%  4) Shows a grouped bar+scatter using dabarplot (external toolbox)
%
% This code generates fig. S4B

clc; clear; close all;

%% -------------------------- Raw data (Qs) -------------------------------
% Qs is an N x 4 array of Likert scores in {-2,-1,0,1,2} for questions Q1..Q4.
% Rows correspond to repeated "cases" interleaved every 'numCases' rows.
load LikertAnswers.mat

numCases      = 7;                % number of interleaved cases
numQuestions  = size(Qs,2);       % 4 questions
likertScores  = -2:2;             % allowed responses
numLikert     = numel(likertScores);

% x-axis (each row in y corresponds to a "case-question" pair)
x = 1:(numQuestions * numCases);

%% -------------------- Reorder rows by case and question ------------------
% We build y as [Q1 rows for all cases; Q2 rows ...; Q3 ...; Q4 ...],
% so that each block of 'numCases' rows belongs to a question.
y = [];
for i = 1:numCases
    % each line concatenates Q1..Q4 slices for case i
    y = [y; Qs(i:numCases:end,1)'; Qs(i:numCases:end,2)'; Qs(i:numCases:end,3)'; Qs(i:numCases:end,4)'];
end
% After the loop, y is (numQuestions*numCases) x (#repetitions for each cell).
% 'timesAsked' = number of repeated measures for each "cell".
timesAsked = size(y,2);

%% ------------------------- Percent breakdown -----------------------------
% y2: percentage distribution across Likert categories for each cell in y
y2 = zeros(numQuestions*numCases, numLikert);
for i = 1:(numQuestions*numCases)
    for j = 1:numLikert
        y2(i,j) = 100 * sum(y(i,:) == likertScores(j)) / timesAsked;
    end
end

%% ------------------ Build diverging 6-bin layout around 0 -----------------
% We want stacked order: [-2, -1, 0L, 0R, +1, +2]
% Start from columns y2 = [-2 -1 0 +1 +2]
y3        = y2;
y3(:,1)   = -y3(:,1);   % place -2 on the negative side
y3(:,2)   = -y3(:,2);   % place -1 on the negative side

% split the 0 bin into half negative (0L) and half positive (0R)
temp0     = y3(:,3);
y3(:,3)   = -temp0/2;   % 0L (negative half)
y3(:,4)   =  temp0/2;   % 0R (positive half)

% shift +1 and +2 into the 5th and 6th columns
y3(:,6)   = y3(:,5);    % move +2 to column 6
y3(:,5)   = y2(:,4);    % put +1 into column 5

% final diverging array y4: [-2, -1, 0L, 0R, +1, +2]
% (The original code swapped columns for plotting convenience; we keep it explicit)
y4 = y3;

% Optional flip for aesthetics
y5 = flipud(y4);

%% ---------------------- Diverging stacked barh ----------------------------
figure('Units','normalized','Position',[0.3 0.05 0.35 0.8],'Color','w');
BH = barh(x, y5, 'stacked');

% Likert colors for 6 bins: [-2, -1, 0L, 0R, +1, +2]
LikertColors = [ ...
    0.808, 0.804, 0.804;  % -2 (light gray)
    0.486, 0.604, 0.569;  % -1 (green-gray)
    0.329, 0.584, 0.647;  %  0L (teal)
    0.808, 0.804, 0.804;  %  0R (light gray)
    0.937, 0.792, 0.561;  % +1 (tan)
    0.941, 0.580, 0.518]; % +2 (salmon)

for k = 1:numel(BH)
    BH(k).FaceColor = LikertColors(k,:);
end

% Legend aligned to the 6 bins in the stack
leg = legend({'0','-1','-2','0','+1','+2'}, 'Orientation','horizontal', ...
    'Location','southoutside');
leg.AutoUpdate = 'off';

% Y ticks: label each block center with Q4..Q1 (to match the flipped order)
yt = 1:(numQuestions*numCases);
set(gca,'YTick', (numCases/2)+numCases*(0:numQuestions-1));
set(gca,'YTickLabel', fliplr({'Q1','Q2','Q3','Q4'}));  % because of flipud

% dashed separators between question blocks
hold on;
for q = 1:numQuestions-1
    yline(q*numCases + 0.5, 'k--');  % line between blocks
end
hold off;

xlabel('Proportion of total responses (%)','Interpreter','latex');
xline(0,'k','LineWidth',1);
xlim([-120 120]);  % symmetric range for clarity
box off;

% OPTIONAL: add value labels (small) inside the bars
labelOffset = 5.5;  % adjust to taste / screen
for i = 1:numel(BH)
    yi = BH(i).YData;
    for j = 1:numel(yi)
        if yi(j) ~= 0
            % Compute a mid-segment position for label
            yMid = BH(i).YEndPoints(j) - yi(j)/2;
            txt  = sprintf('%.1f', abs(yi(j)));
            text(yMid - labelOffset, BH(i).XData(j), txt, 'FontSize', 7);
        end
    end
end

%% ------------------------- Wilcoxon sign-rank ----------------------------
% Test each row of y (all repeated measures for that cell) against median 0
% Requires Statistics and Machine Learning Toolbox.
y6 = y;
Parray = NaN(size(y6,1),1);
Harray = NaN(size(y6,1),1);
for i = 1:size(y6,1)
    [P,H]   = signrank(y6(i,:), 0);  % median vs 0
    Parray(i) = P;
    Harray(i) = H;
end
disp('Wilcoxon p-values per row (y6):');
disp(Parray.');

%% ---------------------- Grouped bar + scatter panel ----------------------
addpath(genpath('frank-pk-DataViz-3.2.3.0'));  % external viz toolbox

data1           = Qs;
group_inx       = repmat((1:numCases), 1, numQuestions).';  % 7 cases repeated over 4 questions
group_names     = arrayfun(@(k)sprintf('g%d',k), 1:numCases, 'UniformOutput', false);
condition_names = {'Q1','Q2','Q3','Q4'};

figure('Units','normalized','Position',[0.2 0.2 0.7 0.4],'Color','w');
h = dabarplot(data1, 'groups', group_inx, ...
    'xtlabels', condition_names, 'errorbars', 0, ...
    'scatter', 1, 'scattersize', 15, 'scatteralpha', 0.7, ...
    'barspacing', 0.8, 'legend', group_names);
ylim([-2.5 2.5]); yticks(-2:2);
ylabel('Answers (Likert)');
title('Grouped responses by case and question');
