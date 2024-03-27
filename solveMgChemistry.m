% Sub-program: d26Mg-Time(Phanerozoic)
% Programmer: xiaoW
% Co-operator: Youzi
% Calculating fluxes, and solving this problem
% Key programme in this project

%['Case #' num2str(kase) ' Solving!!']


%% Initializing fluxes, by sea-level, Sr isotopic composition, and ocean crust production
% Initialize Fcw, which is derived from continental exposure
% So do Ccw and Scw
% Calculate land area in geological time
% Rn = 6; % Polygon, S = Rn / 2 * r * r * sin(2pi / n)
% Rm = 500; % Numbers of polygons (23 Cratons)
% Rland_modern = sqrt(landArea_modern / Rm / Rn * 2 / sin(2 * mathPi / Rn));
% slopeAngle = 0.3 / 180 * mathPi; % 0~1 degree
% Rland = Rland_modern - seaLevel / tan(slopeAngle) * 1e-3;
% Sland = Rm * Rn / 2 * Rland .* Rland * sin(2 * mathPi / Rn);


% Different carboante-weathering patterns:
% 1) exposed land area
% 2) flooded land area
% 3) result from calcium isotopes
% 4) by runoff
% 5) by rain water (from MOR/RW ratios)
% 6) by rain water (by climate model)
if mod(patternKase, 6) == 1
    Fcw = Fcw_modern / landArea(1) * landArea;
elseif mod(patternKase, 6) == 2
    Fcw = Fcw_modern / landAreaB(1) * landAreaB;
elseif mod(patternKase, 6) == 3
    Fcw = Fcw_modern / FCa_wc(1) * FCa_wc;
elseif mod(patternKase, 6) == 4
    Fcw = Fcw_modern / runoff(1) * runoff;
elseif mod(patternKase, 6) == 5
    Fcw = Fcw_modern / RW(1) * RW;
elseif mod(patternKase, 6) == 0
    Fcw = Fcw_modern / rainWater(1) * rainWater;
end


Ccw = Ccw_modern / Fcw_modern * Fcw;

% Derive Fhy from ocean crust production
Fhy = Fhy_modern / oceanCrust_modern * oceanCrust;

% In direct proportion to production of ocean crust
% Calculate Ca/Sr-fluxes via high-T hydrothermal events
Chy = Chy_modern / Fhy_modern * Fhy;
Shy = Shy_modern / Fhy_modern * Fhy;

% Estimate low-T hydrothermal by temperature and ocean-crust production
[b, bint, r, rint, stats] = regress(coolingLowT(1:2901)', [ones(2901, 1), surfT(1:2901)', oceanCrust(1:2901)']);
Fcf = b' * [ones(1, N); surfT; oceanCrust];
Fcf = Fcf / Fcf(1) * Fcf_modern;
Ccf = Ccf_modern / Fcf_modern * Fcf;

% Constraining silicate weathering from Sr isotopes
% Modern values
Scw_modern = Srv_modern * (DSr_rv_modern - DSr_sw_modern) / (DSr_cw_modern - DSr_sw_modern);
Ssw_modern = Srv_modern * (DSr_rv_modern - DSr_cw_modern) / (DSr_sw_modern - DSr_cw_modern);
Scw = Scw_modern / Fcw_modern * Fcw;
% ATTENTION: the time axis has been reversed!!!
% Thus, when we try to recover the paleo-fluxes
% Remove the inputs from seawater and return the outputs to seawater, thus
% Msr * d(dSr)/dt = -Fr*dr - Fhy*dhy + (Fr+Fhy)*dSr
%                 = Fhy * (dSr-dhy) + Fr * (dSr-dr)
% Fr = (Msr * d(dSr)/dt - Fhy * (dSr - dhy)) / (dSr - dr)
% Msr * d(dSr)/dt = -Fcw*dcw -Fsw*dsw - Fhy*dhy + (Fcw+Fsw+Fhy)*dSr
%                 = Fhy * (dSr-dhy) + Fcw * (dSr-dcw) + Fsw * (dSr-dsw)
% Fsw = (Msr * d(dSr)/dt - Fhy * (dSr - dhy) - Fcw * (dSr-dcw)) / (dSr - dsw)
Ssw = (M_Sr * dDSr - Scw .* (DSr_cw - DSrSW) - Shy .* (DSr_hy - DSrSW)) ./ (DSr_sw - DSrSW);
DSr_r = (Scw .* DSr_cw + Ssw .* DSr_sw) ./ (Scw + Ssw);

% Assuming that in silicate weathering, Ca/Sr is fixed, while Mg/Sr is not
% Mg flux is corrected later on
Fsw_init = Fsw_modern * Ssw / Ssw_modern;
Csw = Csw_modern * Ssw / Ssw_modern;

% Fdm + Fcp = A
% -Cdm + Ccp = B
% Fcp = a*Ccp = a*(B+Fdm)
% (1+a)Fdm = A-aB
Fsw = Fsw_init;
A = Fcw + Fsw - Fhy - Fcf - dMg;
B = Ccw + Csw + Chy + Ccf - dCa;
Fdm = (A - MgCa_limestone .* B) ./ (1 + MgCa_limestone);
Mg_Sr_sw = 1 + 0 * tt;
while min(Fdm) < 0
    Rratio = smooth(rand(1, N).*(Fdm<0), 2001);
    Rratio = Rratio' / max(Rratio) * 0.1;
    Mg_Sr_sw = Mg_Sr_sw + Rratio;
    Fsw = Fsw_init .* Mg_Sr_sw;
    A = Fcw + Fsw - Fhy - Fcf - dMg;
    B = Ccw + Csw + Chy + Ccf - dCa;
    Fdm = (A - MgCa_limestone .* B) ./ (1 + MgCa_limestone);
end

Fsw = Fsw_init .* Mg_Sr_sw;
A = Fcw + Fsw - Fhy - Fcf - dMg;
B = Ccw + Csw + Chy + Ccf - dCa;
Fdm = (A - MgCa_limestone .* B) ./ (1 + MgCa_limestone);

Fcp = A - Fdm;
Cdm = Fdm;
Ccp = B + Cdm;



%% Numerical method to calculate d26Mg_seawater
% Calculate from 550 Ma, integrate from 550 Ma to 0 Ma
% MMg*dDMg/dt = Fcw*(Dcw-DMg) + Fsw*(Dsw-DMg) - Fdm*(Ddm-DMg) - Fcp(Dcp-DMg) - Fhy*(Dhy-DMg) - Fcf*(Dcf-DMg)
% MMg*dDMg/dt = Fcw*(Dcw-DMg) + Fsw*(Dsw-DMg) - Fdm*(1000*lnAdm) - Fcp*(1000*lnAcp) - Fhy*(1000*lnAhy) - Fcf*(1000*lnAhy)
% MMg*dDMg/dt + (Fcw+Fsw)*DMg = Fcw*Dcw+Fsw*Dsw - 1000*(Fdm*lnAdm+Fcp*lnAcp+Fhy*lnAhy+Fcf*lnAcf)
% dy/dx + P(x)y = Q(x)
% P(t) = (dMMg/dt+Fcw+Fsw) / MMg
% Q(t) = (Fcw*Dcw+Fsw*Dsw - Fdm*1000*lnAdm-Fcp*1000*lnAcp-Fhy*1000*lnAhy-Fcf*1000*lnAcf) / MMg
% y = C*exp(-int_Pdx) + exp(-int_Pdx)*int_(Q*exp(int_Pdx))dx
% y = exp(-int_Pdx) * (C + int_(Q*exp(int_Pdx))dx)
% R = Q * exp(int_Pdx)

% Integrate from 550 Ma to 0 Ma
partialP = (Fcw + Fsw) ./ M_Mg;
partialQ = (Fcw .* DMg_cw + Fsw .* DMg_sw - Fdm .* DFMg_dm - Fcp .* DFMg_cp - Fhy .* DFMg_hy - Fcf .* DFMg_cf) ./ M_Mg;
intP = 0 * tt;
intR = 0 * tt;
for i = N-1:-1:1
    intP(i) = intP(i + 1) + (partialP(i + 1) + partialP(i)) / 2 * dt * 1e6;
    intR(i) = intR(i + 1) + (partialQ(i + 1) * exp(intP(i + 1)) + partialQ(i) * exp(intP(i))) / 2 * dt * 1e6;
end
DMgSW = exp(-intP) .* (intR + DMg_init);


% Integrate from 0 Ma to 550 Ma
% Useless, cause the DMg_modern shows a great impact on DMg_init
% intP = 0 * tt;
% intR = 0 * tt;
% for i = 2:N
%     intP(i) = intP(i - 1) - (partialP(i - 1) + partialP(i)) / 2 * dt;
%     intR(i) = intR(i - 1) - (partialQ(i - 1) * exp(intP(i - 1)) + partialQ(i) * exp(intP(i))) / 2 * dt;
% end
% DMg = exp(-intP) .* (intR + DMg_modern);
% DMg_init = DMg(N);

% Quantify the input and output fluxes
% inputD = (Fcw * DMg_cw + Fsw * DMg_sw) ./ M_mg;
% outputD = (Fdm .* (DMg + 1e3 * log(Adm)) + Fhy .* (DMg + 1e3 * log(Ahy)) + Fcf .* (DMg + 1e3 * log(Acf))) ./ M_mg;

% Camparison, analytical vs. numerical
% DMg = 0 * tt;
% DMg(N) = DMg_init;
% for i = N-1:-1:1
%     swD = M_mg(i + 1) * DMg(i + 1);
%     inputD = (Fcw(i) + Fcw(i + 1)) / 2 * dt * DMg_cw + (Fsw(i) + Fsw(i + 1)) / 2 * dt * DMg_sw;
%     outputD = (Fdm(i) + Fdm(i + 1)) / 2 * dt * (DMg(i + 1) + 1e3 * log(Adm)) + ...
%         (Fhy(i) + Fhy(i + 1)) / 2 * dt * (DMg(i + 1) + 1e3 * log(Ahy)) + ...
%         (Fcf(i) + Fcf(i + 1)) / 2 * dt * (DMg(i + 1) + 1e3 * log(Acf));
%     DMg(i) = (swD + inputD - outputD) / M_mg(i);
% end


%% Dolomite abundance
% Theoretical Dolomite Abundance
% (Fdm + aCdm) / (Fcp + Ccp) = Cdm / Ccp
TDA = Cdm ./ Ccp * 2; % CaMg(CO3)2 vs. CaCO3
TDAbyWindow = 0 * tt;
halfWindow = doloWindow * 50; % Ma * 100 / 2
for i = 1:N
    Tmax = min(N, i + halfWindow);
    Tmin = max(1, i - halfWindow);
    TDAbyWindow(i) = sum(Fdm(Tmin:Tmax)) / sum(Ccp(Tmin:Tmax)) * 2;
end
TDAbyStage = zeros(1, 36);
for i = 1:36
    Tmax = floor(carbCnt(i, 99, 1) / dt) + 1;
    Tmin = ceil(carbCnt(i, 99, 2) / dt) + 1;
    TDAbyStage(i) = sum(Fdm(Tmin:Tmax)) / sum(Ccp(Tmin:Tmax)) * 2;
end