close all; clc;
% clear all;

global patternName
patternName = ["landArea"; "landAreaB"; "d44Ca"; "runoff"; "RW"; "rainWater"; ...
    "landArea_2"; 'landAreaB_2'; "d44Ca_2"; "runoff_2"; "RW_2"; "rainWater_2"];


patternKase = 1;
filePath = 'output_smoothed_'+ patternName(patternKase);

set(gcf, 'unit', 'centimeters', 'position', [0 0 25 10]);
%%
subplot(1, 1, 1);
d26Mg = xlsread('2021XubinWang\picts\reported_d26Mg_data.xlsx', 'Sheet1');
tt = d26Mg(:, 1); data = d26Mg(:, 2);
tt(isnan(tt)) = []; data(isnan(data)) = [];
N = length(tt);
cnt = zeros(551, 1);
tot = zeros(551, 1);
for i = 1:N
    dt = round(tt(i)) + 1;
    cnt(dt) = cnt(dt) + 1;
    tot(dt) = tot(dt) + data(i);
end
scatter(tt, data + 1.1, 15, 'markerFaceColor', [1 1 0], 'markerEdgeColor', 'k'); hold on;
DMgSW = read('DMgSW', 3);
plot(DMgSW(:, 1), DMgSW(:, 2), 'color', 'r', 'lineWidth', 1.5); hold on; % Mg isotopes
xlim([0 550]); ylim([-2.5 1.5]);
ylabel('dolostones');
% scatter(d26Mg(:, 4), d26Mg(:, 5), 15, 'markerFaceColor', [0 1 1], 'markerEdgeColor', 'k'); hold on;
% xlim([0 550]); ylim([-6 2]);
% ylabel('Limestones');
set(gca, 'xDir', 'reverse', 'xTick', 0:50:550);
set(gca, 'yGrid', 'on', 'lineWidth', 0.75);
box on;


% %%
% subplot(3, 1, 2);
% beta = read('MgSr-sw', 3);
% semilogy(beta(:, 1), beta(:, 2), 'color', 'b', 'lineWidth', 1.5); hold on;
% xlim([0 550]); ylim([0 4]);
% ylabel('beta');
% set(gca, 'xDir', 'reverse', 'xTick', 0:100:500, 'xTickLabel', {});
% set(gca, 'yGrid', 'on', 'lineWidth', 0.75);
% 
% 
% %%
% subplot(3, 1, 3);
% colororder({'k', 'k'});
% yyaxis left;
% fill([170 155 155 170], [0 0 15 15], 'w', 'faceColor', '#00FFFF', 'edgeColor', 'none'); hold on;
% fill([298.9 251.902 251.902 298.9], [0 0 15 15], 'w', 'faceColor', '#FFFF8D', 'edgeColor', 'none'); hold on;
% LIP = xlsread('Datasets\LIPs.xlsx', 'Sheet1');
% for i = 1:24
%     l = LIP(i, 3);
%     r = LIP(i, 1);
%     v = LIP(i, 2);
%     fill([l r r l], [0 0 v v], 'r', 'edgeColor', 'none'); hold on;
% end
% xlim([0 550]); ylim([0 15]);
% ylabel('LIPs');
% yyaxis right;
% arc = xlsread('Datasets\continental_arc.xlsx', 'Sheet1');
% plot(arc(:, 1), arc(:, 2), 'color', '#A2142F', 'lineWidth', 1.5); hold on;
% xlim([0 550]); ylim([0 40000]);
% ylabel('arc');
% set(gca, 'xDir', 'reverse', 'xTick', 0:100:500);
% set(gca, 'yGrid', 'on', 'lineWidth', 0.75);


%%
saveas(gcf, 'fractionation.png');


%%
function stat = read(sheetName, k)
global patternName
stat = [];
for i = 1:6
    filePath = 'output_smoothed_'+ patternName(i);
    data = xlsread(filePath + '\0\Results.xlsx',sheetName);
    stat = [stat data(:, k)];
    tt = data(:, 1);
end
stat = [tt mean(stat, 2)];
end