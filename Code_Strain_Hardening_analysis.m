clear;
clc;
%%% Work hardening and softening analysis from True Stess-strain data %%%
%% 1st [Ploting of True -stress strain data]
True_Stress_strain = readtable('D3_adiabatic_corrected_stress_strain_data1.xlsx', 'sheet',4,'Range','C3:D684');
True_Stress_strain = True_Stress_strain{:,:};
TrueStrain = True_Stress_strain(:,1);
TrueStress = True_Stress_strain(:,2);
plot (TrueStrain,TrueStress)    
hold on
%% 2nd [Elastic stress-strain data]
% 2.0 (To find out Elastic Stress-Strain Data)
LowerLinearStress = input('Guess minimum stress value of linear portion from Stress Strain plot:');
UpperLinearStress = input('Guess maximum stress value of linear portion from Stress Strain plot:');
LowerIndex = find(abs(TrueStress-LowerLinearStress)<1);
UpperIndex = find(abs(TrueStress-UpperLinearStress)<1);
ElasticStrain = TrueStrain(LowerIndex:UpperIndex);
ElasticStress = TrueStress(LowerIndex:UpperIndex);
% 2.1 (To check Linear fit of Elastic Stress Strain by regressions)
L = polyfit(ElasticStrain,ElasticStress,1); % L =Linear fit
ElasticStressfit = polyval(L,ElasticStrain); % It is similar to {ElasticStressfit = L(1)*ElasticStrain+L(2)}
ElasticStressresid = ElasticStress - ElasticStressfit; % ---------
SSresid = sum(ElasticStressresid.^2); % ------------residual sum of squares
SStotal = (length(ElasticStress)-1)*var(ElasticStress); %--------,,-------
Rsquare = 1-SSresid/SStotal % The regessions coefficient
% 2.2 ( To Find out E = Elastic Modulus)
E = L(1)
% 2.3 (To extrapolate Elastic Strain Values)
Increment_Strain = ElasticStrain(2,1)-ElasticStrain(1,1);% The frequency of data acqisition
Upper_extrapolatedStrain = max(ElasticStrain)+Increment_Strain:Increment_Strain:TrueStrain(end);
Lower_extrapolatedStrain = 0:Increment_Strain:min(ElasticStrain)-Increment_Strain;
Final_ElasticStrain = [Lower_extrapolatedStrain';ElasticStrain;Upper_extrapolatedStrain'];
% 2.4 (To extrapolate Elastic Stress Values)
     %## It is important to note that the increment in stress should be in a
     % similar fashion as in strain. we know that in tensile test the
     % strain increment is always linear with time. Hence The stress
     % increment should be consider in a strain_incement form##%
    % [in the case of smoothed data we have to always make an unique number]
[~, indx] = unique(ElasticStrain);% Its doesn't matter whether here are you taking x or y values
Upper_extrapolateStress = interp1(ElasticStrain(indx),ElasticStressfit(indx),Upper_extrapolatedStrain','linear','extrap');
Lower_extrapolateStress = interp1(ElasticStrain(indx),ElasticStressfit(indx),Lower_extrapolatedStrain,'linear','extrap');
Final_ElasticStress = [Lower_extrapolateStress';ElasticStressfit;Upper_extrapolateStress];
%2.5 (To get Offset = 0.2% == 0.002 strain)
FinalElasticStrain_Offset = 0.002+Final_ElasticStrain;
%2.6 (To calculate Yield Point)
[YieldStrain,YieldStress,IdxYStrain,IdxYstress] = intersections(TrueStrain,TrueStress,FinalElasticStrain_Offset,Final_ElasticStress);
YieldStrength = YieldStress(end)% This "end" is used bcoz to overcome proper elastic region, specially for hot deformation
plot(FinalElasticStrain_Offset,Final_ElasticStress,'-r')
ylim([0 max(TrueStress)+50]);
hold off
figure()
%% 3rd [Data points between YS to UTS]
% 3.1 (Selecting out indexpoint of Yield Strain)
[~,Idx] = min(abs(TrueStrain-YieldStrain));
IndexYieldStrainLower = find(TrueStrain == TrueStrain(Idx));
IndexYieldStrainUpper = find(TrueStrain == TrueStrain(end));
% 3.2 (Selecting out indexpoint of Yield Stress)
% [~,Idx] = min(abs(TrueStress-YieldStrength));% Since, Yield point is
% having same index in stress-strain. so "Idx will be same for True strain
% and strain"
IndexYieldStressLower = find(TrueStress == TrueStress(Idx));
IndexYieldStressUpper = find(TrueStress == TrueStress(end));
IndexYieldStressUpper = IndexYieldStressUpper(end);
% 3.3 (True Stress-Strain data between Yield Strain to Final Strain)
TrueStrain_Plastic = TrueStrain(IndexYieldStrainLower:IndexYieldStrainUpper);
TrueStress_Plastic = TrueStress(IndexYieldStressLower:IndexYieldStressUpper);
% % 3.4 (The 8th order polyfit of YS to UTS data)
% p = polyfit(TrueStrain_Plastic,TrueStress_Plastic,8);
% TrueStress_Plastic = polyval(p,TrueStrain_Plastic);
% plot(TrueStrain_Plastic,TrueStress_Plastic)
% figure()
%% 4th [Strain Hardening analysis by "Kocks-Mecking"]
% 4.1 (To calculate true plastic strain)
TruePlasticStrain = (TrueStrain_Plastic-(TrueStress_Plastic./E));
% 4.2 (To calculate True plastic stress == Sigma-Sigma(0.2%))
TruePlasticStress = TrueStress_Plastic-YieldStrength;
% 4.3 (The Kocks-Mecking Plot)
Theta = gradient(TrueStress_Plastic)./gradient(TruePlasticStrain);
plot(TruePlasticStress,Theta,'LineWidth',2.5)
% xlim([0 inf]); ylim([-50 inf]);
ax = gca;
ax.FontWeight = 'bold';% for axes to make bold
ax.LineWidth = 2;% for axes line thick
% title('\textbf{Kocks-Mecking plot}','Interpreter','latex','fontsize',14)
xlabel('\textbf{${\mathbf{\sigma-\sigma_{0.2\%}}}  $($MPa)$}','Interpreter','latex','fontsize',16)
ylabel('\textbf{d${\mathbf{\sigma}}$/d${\mathbf{\varepsilon_{p}}}  $($MPa)$}','interpreter', 'latex','Fontsize',16)
figure()
% 4.4 Exporting Strain_hardening data
KM_data = [TruePlasticStress,Theta,TruePlasticStrain];
filename = 'D3_KManalysis_matlab_T1050_SR1.xlsx';
xlswrite(filename,KM_data,1,'A3:C684');