% Sub-program: d26Mg-Time(Phanerozoic)
% Programmer: xiaoW
% Co-operator: Youzi
% MonteCarlo drive
% Details see in d26MgThroughTime.m
% Actually a sub-programme for d26MgThroughTime.m
% A model drive however
close all; clc;
% clearvars -EXCEPT patternKase patternName

patternName(patternKase)

%% =1: single case, >1: MonteCarlo
totalKase = 1000;
smoothWindow = 1; % Ma, smoothWindow | 550
smoothN = (camT - modernT) / smoothWindow + 1;
% Prepare for record
rDSr_r = zeros(totalKase, smoothN);
rSr = zeros(totalKase, smoothN);
rShy = zeros(totalKase, smoothN);
rScw = zeros(totalKase, smoothN);
rSsw = zeros(totalKase, smoothN);
rFhy = zeros(totalKase, smoothN);
rFcf = zeros(totalKase, smoothN);
rFdm = zeros(totalKase, smoothN);
rFcp = zeros(totalKase, smoothN);
rFcw = zeros(totalKase, smoothN);
rFsw = zeros(totalKase, smoothN);
rChy = zeros(totalKase, smoothN);
rCcf = zeros(totalKase, smoothN);
rCdm = zeros(totalKase, smoothN);
rCcp = zeros(totalKase, smoothN);
rCcw = zeros(totalKase, smoothN);
rCsw = zeros(totalKase, smoothN);
rDMgSW = zeros(totalKase, smoothN);
rTDA = zeros(totalKase, smoothN);
rMg_Sr_sw = zeros(totalKase, smoothN);
rTDAbyStage = zeros(totalKase, 36);


% MonteCarlo
for kase = 1:totalKase
    ['Case #' num2str(patternKase) '-' num2str(kase) ' Running!!!'] % A little efficiency loss to avoid being bored...
    close all;
    FILE = 'output\';
    sFILE = ['output_smoothed\' num2str(kase, '%05d') '\'];
    % Higgins et al., 2015, dolomitization = 1.7 Tmol/yr (Holland, 2005)
    % Constraining modern dolomitization and carbonate precipitation modern
    Fdm_modern_min = 1.65;
    Fdm_modern_max = 1.75;
    Ccp_modern_min = 14.5;
    Ccp_modern_max = 17.0;
    Fdm_modern = -1;
    while Fdm_modern_max < Fdm_modern || Fdm_modern_min > Fdm_modern || Ccp_modern_max < Ccp_modern || Ccp_modern_min > Ccp_modern
        [Fcw_modern, Fsw_modern, Fhy_modern, Fcf_modern] = Frand();
        [Ccw_modern, Csw_modern, Chy_modern, Ccf_modern] = Crand();
        Chy_modern = Fhy_modern;
        Ccf_modern = Fcf_modern; % Assuming 1:1 exchange
%         % -Cdm + Ccp = A
%         % Fdm + Fcp + dMg/dt = B
%         % (Fdm + a*Cdm) / (Fcp + Ccp) * 2 = C
%         % Cdm = Fdm
%         % Fcp = a*Ccp
%         % (Cdm + a*Cdm) / (a*Ccp + Ccp) * 2 = C
%         % (Cdm) / (Ccp) * 2 = C
%         A = Ccw_modern + Csw_modern + Chy_modern + Ccf_modern - dCaSW_modern;
%         B = Fcw_modern + Fsw_modern - Fhy_modern - Fcf_modern;
%         C = doloAbun_modern;
%         Ccp_modern = A / (1 - C / 2);
%         Cdm_modern = Ccp_modern * C / 2;
%         Fdm_modern = Cdm_modern;
%         Fcp_modern = Ccp_modern * MgCa_limestone;
        % Fdm + Fcp = A
        % -Cdm + Ccp = B
        % Fcp = a*Ccp = a*(B+Fdm)
        % (1+a)Fdm = A-aB
        A = Fcw_modern + Fsw_modern - Fhy_modern - Fcf_modern - dMgSW_modern;
        B = Ccw_modern + Csw_modern + Chy_modern + Ccf_modern - dCaSW_modern;
        Fdm_modern = (A - MgCa_limestone(1) * B) / (1 + MgCa_limestone(1));
        Ccp_modern = B + Fdm_modern;
    end
    % Solving
    d26MgThroughTime
    if totalKase == 1
        drawFigures
    else
        smoothCurves
        close all;
        % Record MonteCarlo
        rDSr_r(kase, :) = sDSr_r;
        rSr(kase, :) = sScw + sSsw;
        rShy(kase, :) = sShy;
        rScw(kase, :) = sScw;
        rSsw(kase, :) = sSsw;
        rFhy(kase, :) = sFhy;
        rFcf(kase, :) = sFcf;
        rFdm(kase, :) = sFdm;
        rFcp(kase, :) = sFcp;
        rFcw(kase, :) = sFcw;
        rFsw(kase, :) = sFsw;
        rChy(kase, :) = sChy;
        rCcf(kase, :) = sCcf;
        rCdm(kase, :) = sCdm;
        rCcp(kase, :) = sCcp;
        rCcw(kase, :) = sCcw;
        rCsw(kase, :) = sCsw;
        rDMgSW(kase, :) = sDMgSW;
        rTDA(kase, :) = sTDA;
        rMg_Sr_sw(kase, :) = sMg_Sr_sw;
        rTDAbyStage(kase, :) = TDAbyStage;
    end
    % ['Case #' num2str(kase) ' Completed!! ^-^']
end

if totalKase > 1
    conclu
    mean(rDMgSW(:, 1))
    xlswrite(strcat('output_smoothed_', patternName(patternKase), '\0\Results.xlsx'), mean(rDMgSW(:, 1)), 'modern');
end

'Programme Completed!!! ^-^'


%% Random fluxes
% Mg-fluxes
function [f1, f2, f3, f4] = Frand()
f1 = 2.0 + rand() * 0.2; % 2~2.2, Tmol/yr, cw
f2 = 2.0 + rand() * 0.5; % 2~2.5, Tmol/yr, sw
f3 = 1.4 + rand() * 0.2; % 1.4~1.6, Tmol/yr, hy
f4 = 0.6 + rand() * 0.9; % 0.6~1.5, Tmol/yr, cf
end

% Ca-fluxes
function [c1, c2, c3, c4] = Crand()
c1 = 9.0 + rand() * 1.8; % 9.0~10.8 Tmol/yr, cw
c2 = 2.3 + rand() * 0.2; % 2.3~2.5 Tmol/yr, sw
c3 = 1.4 + rand() * 0.2; % 1.4~1.6 Tmol/yr, hy
c4 = 0.6 + rand() * 0.9; % 0.6~1.5 Tmol/yr, cf
end