% Sub-program: d26Mg-Time(Phanerozoic)
% Programmer: xiaoW
% Co-operator: Youzi
% Basic datasets input

%% Input from Excel, with general initialization
['General Input Processing']
global inputExl
if Mg_Ca_pattern == 1
    inputExl = xlsread('Datasets\fluxesAndConcentration.xlsx');
else
    inputExl = xlsread('Datasets\fluxesAndConcentration_2.xlsx');
end
VSW = 1.37e21; % volumn of seawater, 137e7 km3 = 1.37e21 dm3 = 1.37e21 L = 1.37e21 kg


% Input [Mg]_sw and [Ca]_sw, with linear interpolation
% (Hardie et al., 1996)
if Mg_Ca_pattern == 1
    MgSW = interpolation(1, 2, 42); % mmol/L
else
    MgSW = interpolation(1, 2, 16); % mmol/L
end
dMgSW_modern = (MgSW(1) - MgSW(2)) * 1e-3 * 1.37e21 / dt * 1e-18; % Tmol/yr
M_Mg = MgSW * 1e-3 * VSW * 1e-12; % Tmol
dMg = [(M_Mg(1)-M_Mg(2))*2, M_Mg(1:N-2)-M_Mg(3:N), (M_Mg(N-1)-M_Mg(N))*2] / dt / 2 * 1e-6; % Tmol/yr
% Just use Ca (less affected by dolomitization)
% MgSW_modern = 53; % mmol/L

if Mg_Ca_pattern == 1
    CaSW = interpolation(27, 28, 47); % mmol/L
else
    CaSW = interpolation(27, 28, 17); % mmol/L
end
dCaSW_modern = (CaSW(1) - CaSW(2)) * 1e-3 * 1.37e21 / dt * 1e-18; % Tmol/yr
M_Ca = CaSW * 1e-3 * VSW * 1e-12; % Tmol
dCa = [(M_Ca(1)-M_Ca(2))*2, M_Ca(1:N-2)-M_Ca(3:N), (M_Ca(N-1)-M_Ca(N))*2] / dt / 2 * 1e-6; % Tmol/yr

MgCaSW = MgSW ./ CaSW;


% Input the production rate of ocean crust, with linear interpolation
% Calculate the fluxes related to MOR
oceanCrust = interpolation(12, 11, 56); % km2/year
oceanCrust_modern = oceanCrust(1);


% Input 87Sr/86Sr, with linear interpolation
% Elderfield et al., 1996
SrSW = 90; % umol/L, seawater
% Jones et al., 2001
uDSrSW = interpolation(24, 25, 113);
lambda_87Rb = 1.42e-5; % 1/myr
Sr_87_86 = 7.00 / 9.86; % Lange's Handbook
Rb_87_85 =  27.83 / 72.17;
RbSW = 1; % umol/L, seawater, Johnson, 1992
% R0 = R - RP/D * lambda * t
R_P_D = (RbSW * 0.2783) / (SrSW * 0.0986); % 87Rb/86Sr
DSrSW = uDSrSW - R_P_D * (exp(lambda_87Rb * (camT - tt)) - 1);
%DSrSW = uDSrSW;
dDSr = [(DSrSW(1)-DSrSW(2))*2, DSrSW(1:N-2)-DSrSW(3:N), (DSrSW(N-1)-DSrSW(N))*2] / dt / 2 * 1e-6; % 1/yr


% Input Eustacy
seaLevel = interpolation(38, 39, 145);
% earthR = 6371; % km, average
% mathPi = 3.1416;
% earthArea = 4 * mathPi * earthR * earthR;
% landArea_modern = earthArea * 0.292;
% Sland = -1.273e5 * seaLevel + landArea_modern;


% Input atmospheric pCO2
pCO2 = interpolation(45, 46, 56);
pCO22 = interpolation(72, 73, 58);

% % Input d44Ca_seawater
% DCaSW = interpolation(48, 49, 99);
% dDCa = [(DCaSW(1)-DCaSW(2))*2, DCaSW(1:N-2)-DCaSW(3:N), (DCaSW(N-1)-DCaSW(N))*2] / dt / 2 * 1e-6; % per mil/yr


% Input MOR/RW
MOR_RW = interpolation(51, 52, 103);
RW = oceanCrust ./ MOR_RW;

% Input rain water
rainWater = interpolation(57, 58, 58);

% Input land area
landArea = interpolation(63, 64, 73);

% Input land area B
landAreaB = interpolation(60, 61, 25);

% Input surface temperature
surfT = interpolation(66, 67, 25);

% Input cooling Cenozoic
coolingLowT = interpolation(69, 70, 6);

% Input Runoff
runoff = interpolation(54, 55, 25);

% Input Weathered Carbonate by d44Ca
FCa_wc = interpolation(7, 8, 92);


%% Input dolomite abundance from outcrops
% Dolomite abundance (Li et al., 2021)
% carbCnt(i, j, k)
% i = Series
% j = a single sample
% k = 1 for dolomite, 2 for limestone
% carbCnt(i, 100, 1) = number of samples from the Series(i), max = 87, min = 50
% carbCnt(i, 99, 1) = starting age of Series(i)
% carbCnt(i, 99, 2) = ending age of Series(i)
carbCnt = zeros(36, 100, 2);
% Get the exact thickness of dolostone and limestone from each sample
for i = 1:36
    input = xlsread('Datasets\dolomiteAbundance\dolomiteDataset.xlsx', Series(i));
    len = length(input);
    if ~len
        continue;
    end
    carbCnt(i, 100, 1) = len;
    carbCnt(i, 1:len, 1) = input(1:len, 1);
    carbCnt(i, 1:len, 2) = input(1:len, 2);
end
dolomiteAbundance
% Get the lasting period of each Series, and their abundance
input = xlsread('Datasets\dolomiteAbundance\dolomiteDataset.xlsx', 'total ratio');
carbCnt(:, 99, 1) = input(1:36, 1);
carbCnt(:, 99, 2) = input(1:36, 2);
doloTimeSeries = (carbCnt(:, 99, 1) + carbCnt(:, 99, 2))' / 2;


%% Linear interpolation
function ret=interpolation(Raw1, Raw2, Line)
global tt inputExl dt
ret = interp1(inputExl(3:Line, Raw1), inputExl(3:Line, Raw2), tt);
end