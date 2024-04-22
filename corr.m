global patternName
patternName = ["landArea"; "landAreaB"; "d44Ca"; "runoff"; "RW"; "rainWater"; ...
    "landArea_2"; 'landAreaB_2'; "d44Ca_2"; "runoff_2"; "RW_2"; "rainWater_2"];

% Get the lasting period of each Series, and their abundance
input = xlsread('Datasets\dolomiteAbundance\dolomiteDataset.xlsx', 'total ratio');
carbCnt = input(1:36, 1:2);

Fsw = read('Fsw', 3);
Fdm = read('Fdm', 3);
Fcp = read('Fcp', 3);
DMgSW = read('DMgSW', 3);

X = zeros(36, 3);
for i = 1:36
    Tmax = floor(carbCnt(i, 1)) + 1;
    Tmin = ceil(carbCnt(i, 2)) + 1;
    X(i, 1) = mean(Fsw(Tmin:Tmax, 2));
    X(i, 2) = mean(Fdm(Tmin:Tmax, 2));
    X(i, 3) = mean(Fcp(Tmin:Tmax, 2));
    X(i, 4) = mean(DMgSW(Tmin:Tmax, 2));
end

xlswrite('corr.xlsx', X);


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