clear all;
clc;
%%% The code to correcet "Adiabtaic" correction from Stress-Strain data%%%
%% 1st [to define Material and testing parameters]%%
% 1.1 {Density of the sample}# as input
density = 7777.08; % Asummed constant not changing significatly btw 900-1100, unit is kg/m^3.
% 1.2 {Testing temperatures}# as input
T = [1173;1223;1273;1323;1373];
TT = [1/1373;1/1323;1/1273;1/1223;1/1173];
% 1.3 {Heat capacities of tested metals at defferent temperatures}# as input
cp = [615.90;623.68;631.48;639.29;647.14]; % In row, the cp(J/kgK) is increasing with prosessing temp. & calculated from Thermocalc 
% 1.4 {strainrates(SR) used in testing}
SR = [0.001;0.01;0.1;1;10];
% 1.5 {Heat retention efficiency "n(eta)", a function of strain rate}# as input
n1 = 0; % for SR <=0.001
n2 = 0.316*log10(SR(2,:))+0.95;% for 0.001<SR<1, i.e. SR at 0.01
n3 = 0.316*log10(SR(3,:))+0.95;% for 0.001<SR<1, i.e. SR at 0.1
n4 = 0.95;% for SR>=1, i.e. SR at 1
n5 = 0.95;% for SR>=1, i.e. SR at 10
n = [n1;n2;n3;n4;n5];
%% 2nd [the toughness and apparent-Q calculation of tested samples]%%
% 2.1 {increment of strain periodic assumed} 
AS = [0:0.01:0.67];% AS = assumed strain increment
% 2.2 {importing true stress-strain data}
i = 1;
TrueStrain_1 =[];
TrueStress_1 = [];
Tough = [];
for j = 1:5
    k = 1:2:9;
True_Stress_Strain = readtable('D3_smoothed data.xlsx', 'Sheet',j, 'Range','A3:J739');
True_Stress_Strain = True_Stress_Strain {:,:}; % to make matrix from table
True_Stress_Strain(isnan(True_Stress_Strain))=0; % to repalce NAN =0
TrueStrain_1 = True_Stress_Strain (:,k);
TrueStress_1 = True_Stress_Strain (:,k+1);
for a = 1:5
    TrueStrain = TrueStrain_1(:,a);
    TrueStress = TrueStress_1(:,a);
% 2.3 {to calculate toughness}
    Tough(a,j) = trapz(TrueStrain,TrueStress); % this Tough(a,j) is equivalent Tough(variation in SR, Variation in temp.)
% 2.3 {to get TSS(true stress strain) data at assumed incremented strain}
    [TrueStrain, index]= unique(TrueStrain); % to make unique strain,whcih might be repating
    TSS(:,a) = interp1(TrueStrain,TrueStress(index),AS(:)); 
end
i = i+1;
TSS_total(:,:,j) = TSS; % The TSS_total data at assumed incremented strain
end
TSS_total(isnan(TSS_total))=0;
% 2.4 {to arrange TSS according to constant strain and strain rates}
TSS_arranged = [];
for k = 1:68 % to strain 
    for j = 1:5 % to change strain rates
        for i = 1:5 % to change temp
            TSS_arranged(i,j,k) = TSS_total(k,j,i);
        end
    end
end
% 2.5 {to calculate Q (apperant activation energy) i.e. True_Stress vs 1/T}
Q = [];
for k = 1:5 % to increment in SR
    TSSA = TSS_arranged(:,k,:); % TSSA = True Stress Strain arranged finally
    for j = 1:68 % to increment in assumed strain
%     q = polyfit(TT,TSSA(:,:,j),1);
%     Q(j,k) = q(1); % it is a slope of True_Stress vs 1/T plot
    Q1(j,:) = gradient(TSSA(:,:,j)./gradient(TT)); % This is based on 1st order differentiation 
    end
end
%% 3rd [to calculate Change in temperature(i.e delta_T)]%%
for j = 1:5 % for change in temp.
   for i = 1:5 % for change in SR
    deltaT(i,j) = (0.95*n(i,:)*Tough(i,j)*10^6)./(density*cp(j,:));
   end
end
%% 4th [to calculate change in true stress(i.e.delta_sigma)by adiabtic correction]%%
for i = 1:5 % it is for change in temp
    for j = 1:5 % it is for change in delta_T and SR
        for k= 1:68 % it is for change in incremented_strain
            delta_sigma(k,j,i) = Q1(k,j)*((1/(T(i,:)+deltaT(j,i)))-(1/T(i,:)));
        end
    end
end
%% 5th [to claculate correct_True stress after adiabtic correction] It is basically to comparision b/w Exp.data and adiabaic_corrected data%%
Corrected_TrueStress = TSS_total+delta_sigma;
% 5.1 {to plot the adiabtaic corrected True tress strain data)
for i= 1:5 % it is for change in temp
    for j = 1:5 % it is for change SR
            plot(AS,TSS_total(:,j,i),AS,Corrected_TrueStress(:,j,i),'--')
        hold on
    end
    hold off
    figure()
end
% %% 6th Interpolation of adiabatic corrected stress Strain data
% e = 0:0.001:0.68; % strain increment
% for i = 1:5 % increment for Temperature
%     for j = 1:5 % increment for SR
%         Adiabatic_corrected_truestress(:,j,i) = spline(AS,Corrected_TrueStress(:,j,i),e');
%     end
% end
% %% 7th Exporting Adiabtaic Corrected Stress Strain Data
% table1 = table(e');
% filename = 'D3_adiabatic_corrected_stress_strain_data1.xlsx';
% for i = 1:5
%      writetable(table1,filename,'sheet',i,'range','A1');
%      table2 =table(Adiabatic_corrected_truestress(:,:,i));
%      writetable(table2,filename,'sheet',i,'range','B1');
% end
%% 8th Plots between Stress vs 1/T, i.e. the 1st term of adiabatic corrected equation
mark = {'o', 's', 'd', '^','h'}; % marker type
rang = {'[0 0.4470 0.7410]','[0.8500 0.3250 0.0980]', '[0.4940 0.1840 0.5560]','[0.4660 0.6740 0.1880]', '[0.3010 0.7450 0.9330]'};
% 1st to index value out the strain corresponding to which analysis is done
idx = find(abs(AS-0.6000)<0.001); % this id for 0.6 strain
temp = (1./T)*10000;
stress = [];
for i = 1:5
    stress = TSS_arranged(:,i,idx);
    sc(i) = plot(temp, stress, 'marker', mark{i},'markerfacecolor', rang{i}, 'markeredgecolor',rang{i},'MarkerSize', 10, 'linestyle', 'none');
    hold on
    Lf = polyfit(temp,stress,1); % Lf linear fit
    stress_ft = polyval(Lf,temp);
    lnf(i) = plot(temp, stress_ft,'-k', 'LineWidth',2.5); % it is a slope of True_Stress vs 1/T plot
end
hold off
xlim([7 9]); ylim([0 300]);% axes limit
ax = gca;
ax.FontWeight = 'bold';% for axes to make bold
ax.LineWidth = 2.5;% for axes line thick
xlabel('\textbf{\boldmath{$10^{4}/T$} \boldmath{$(K)$}}','Interpreter','latex','fontsize',18)
ylabel('\textbf{\boldmath{$\sigma$} \boldmath{$(MPa)$}}','Interpreter','latex','fontsize',18)
hLg = legend([sc(1) sc(2) sc(3) sc(4) sc(5) lnf(1)],{'\boldmath{$\dot{\varepsilon}$ = $10^{-3}$}','\boldmath{$\dot{\varepsilon}$ = $10^{-2}$}',...
    '\boldmath{$\dot{\varepsilon}$ = $10^{-1}$}','\boldmath{$\dot{\varepsilon}$ = $1$}','\boldmath{$\dot{\varepsilon}$ = $10$}','\textbf{Linear fit}'},'AutoUpdate','off', 'Interpreter','latex');
legend('Location','northwest'); legend('boxoff'),legend show



