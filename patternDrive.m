clear all; clc;
% Different cw patterns
global patternName patternKase
patternName = ["landArea"; "landAreaB"; "d44Ca"; "runoff"; "RW"; "rainWater"; ...
    "landArea_2"; 'landAreaB_2'; "d44Ca_2"; "runoff_2"; "RW_2"; "rainWater_2"];

%% Choronology
% Phanerozoic - System - Series
% Paleozoic: Cambrian Ordovician Silurian Devonian Carboniferous Permian
% Mesozoic: Triassic Jurassic Cretaceous
% Cenozoic: Paleogene Neogene
Series = [["Ediacaran"], ...
    ["Terreneuvian", "Series2", "Series3", "Furongian"], ...
    ["Early Ordovician", "Middle Ordovician", "Late Ordovician"], ...
    ["Llandovery", "Wenlock", "Ludlow-Pridoli"], ...
    ["Early Devonian", "Middle Devonian", "Late Devonian"], ...
    ["Tournaisian-Visean", "Serpukhovian", "Bashkirian", "Moscovian-Gzhelian"], ...
    ["Cisuralian", "Guadalupian", "Lopingian"], ...
    ["Early Triassic", "Middle Triassic", "Late Triassic"], ...
    ["Early Jurassic", "Middle Jurassic", "Late Jurassic"], ...
    ["Berriasian-Barremian", "Aptian-Albian", "Cenomanian-Coniacian", "Santonian-Maastrichtian"], ...
    ["Paleocene", "Eocene", "Oligocene"], ...
    ["Miocene", "Pliocene-Pleistocene-Holocene"]];


%% Numerical settings
global dt N modernT camT tt
dt = 0.01; N = 55001;
modernT = 0;
camT = 550; % Ma
tt = modernT:dt:camT;
doloWindow = 10; % Ma
MgCa_calcite = 0.03;
MgCa_aragonite = 0.05;
Mg_Ca_pattern = 1; % 1 for (Hardie, 1996), 2 for (Horita et al., 2002)
inputFromExcel
MgCa_limestone = MgCa_calcite * (MgCaSW<2) + MgCa_aragonite * (MgCaSW >= 2);

%% Run each pattern
for patternKase = 5:6
    modelDrive
    combineFigs
    combineFigsAffect
    set(gcf, 'unit', 'centimeters', 'position', [0 0 12 5]);
    DMgSW = xlsread('output_smoothed_' + patternName(patternKase) + '\0\Results.xlsx', 'DMgSW');
    plot(DMgSW(:, 1), DMgSW(:, 3), 'color', '#0072BD', 'linewidth', 1.25); hold on;
    xlim([0 550]); ylim([-1.6 -0.4]);
    set(gca, 'xDir', 'reverse');
    set(gca, 'yGrid', 'on', 'yTick', -1.6:0.4:-0.4, 'lineWidth', 0.75);
    saveas(gcf, 'output_smoothed_' + patternName(patternKase) + '\Mg isotopes.png');
    close all;
end
