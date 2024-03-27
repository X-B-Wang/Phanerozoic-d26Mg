% d26Mg-Time(Phanerozoic)
% Programmer: xiaoW
% Co-operator: Youzi
% Calculate the d26Mg_sw through time by limiting the input and output fluxes
% Input fluxes: continental weathering
% CW = carbonate weathering, SW = silicate weathering
% Output fluxes: carbonate precipitation, low-temperature hydrothermal events (clay formation), high-temperature hydrothermal events (basalt alteration)
% DM = dolomitization, CF = clay formation, HY = hydrothermal events (high-temperature)
% Carbonate precipitation: mainly dolomite, due to less Mg in limestone
% Calculation based on mass-balance
%
% PAY ATTENTION: connectors for further modification or promotion
% For logs: there is no log, for this is just a primary version
% For modification: discussion before modification, and annotations are favored
% Sub-programs: inputDoloFromExcel.m, dolomiteAbundance.m inputFromExcel.m
%           solveFluxAndDelta.m drawFigures.m Function_smooth.m
%           modelDrive.m




%% Parameter setting
% F refers to Flux_Mg, C refers to Flux_Ca, S refers to Flux_Sr
% Abbr. :
% cw = carbonate weathering, sw = silicate weathering
% dm = dolomitization, cf = clay formation, hy = hydrothermal
% rv = riverine
% SW = seawater
% M = amount, mostly in mol
% D = \delta^{}E
% DF = fractionation, \Delta
% d = E(i) - E(i+1), perhaps devided by dt
DMg_init = -0.60;
DMg_modern = -0.843; % Teng et al., 2015
% Higgins et al., 2015
DMg_cw = -2.25 + 0 * tt;
DMg_sw = -0.3 + 0 * tt;
DFMg_dm = -1.1 + 0 * tt;
DFMg_cp = -3.5 * (MgCaSW<2) + -3.3 * (MgCaSW>=2);
DFMg_cf = log(1.0016) * 1e3 + 0 * tt;
DFMg_hy = log(1.0000) * 1e3 + 0 * tt;
% Farkas et al., 2007
DCaSW_modern = 1.88;
DCa_cw = 0.3 + 0 * tt;
DCa_sw = 0.9 + 0 * tt;
DCa_hy = 0.7 + 0 * tt;
DFCa_cp = log(0.9991) * 1e3 * (MgCaSW<2) + log(0.9985) * 1e3 * (MgCaSW>=2);
DFCa_dm = DFCa_cp + log(0.9982) * 1e3;
% Elderfield et al., 1996
DSr_hy = 0.7035; % (87Sr/86Sr)_hy
Srv_modern = 33.3 * 1e9; % mol/yr, Sr flux from riverine input
Shy_modern = 15.7 * 1e9; % mol/yr
DSr_rv_modern = 0.7119; % (87Sr/86Sr)_riverine
M_Sr = VSW * SrSW * 1e-6; % mol, [Sr]_seawater
DSr_sw_modern = 0.716;
DSr_cw_modern = 0.708;
DSr_sw = DSr_sw_modern - 4.5e-6 * tt;
DSr_cw = DSr_cw_modern + 0 * tt;
% However, (87Sr/86Sr)seawater slightly changed by radiogenic 87Sr?
Sr_Ca_ratio = 1; % mmol/mol, umol/mmol, 1e-3, (Ando et al, 2005; Zhang et al., 2020a, 2020b)

%% Main programme
solveMgChemistry
