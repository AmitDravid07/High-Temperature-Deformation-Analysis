clear all;
clc;
%% KOcks_Meacking (KM) analysis 
% C = {'[0 0.4470 0.7410]','','[0.4660 0.6740 0.1880]','','[0.8500 0.3250 0.0980]'};
C = {'[0 0 1]','','[0 1 0]','','[1 0 0]'};
linT = {'-','','-','','-'};
 j =5; % sheet number
 for k = 1:2:5
KMdata = readtable('Strain hardeing_final_for thesis.xlsx', 'sheet',j,'Range','A3:F674');
KMdata= KMdata{:,:};
TruePlastic_Stress = KMdata(:,k);
Theta = KMdata(:,k+1)./1000;
plot(TruePlastic_Stress,Theta,'color',C{k},'linestyle',linT{k},'LineWidth',3);
xlim([0 25]);ylim([-0.1 0.3]);% axes limit for KM plot
% xlim([-2 6]);ylim([-2 10])% axes limit for CJ plot
ax = gca;
ax.FontWeight = 'bold';% for axes to make bold
set(gca,'FontSize',16)
ax.LineWidth = 2.5;% for axes line thick
% title('\textbf{Kocks-Mecking plot}','Interpreter','latex','fontsize',14)
xlabel('\textbf{\boldmath{$\sigma-\sigma_{0.2\%}$} \boldmath{$(MPa)$}}','Interpreter','latex','fontsize',18)
ylabel('\textbf{d\boldmath{$\sigma$}/d\boldmath{$\varepsilon_{p}$} \boldmath{$\times 10^{3}$} \boldmath{$(MPa)$}}','interpreter', 'latex','Fontsize',18)
% title('\textbf{Crussard-Jaoul plot plot of D1}','Interpreter','latex','fontsize',14)
% xlabel('\textbf{ln ${\mathbf{\sigma}}  $($MPa)$}','Interpreter','latex','fontsize',16)
% ylabel('\textbf{ln (d${\mathbf{\sigma}}$/d${\mathbf{\varepsilon_{p}}})  $($MPa)$}','interpreter', 'latex','Fontsize',16)
hold on
 end
% xline(18,'k--','LineWidth',2);
% xline(40,'k--','LineWidth',2);
yline(0,'k--','LineWidth',2);
hLg = legend ('\textbf{D1 (Regime A, m = 0.25)}',...
    '\textbf{D2 (Regime A, m = 0.23)}',...
    '\textbf{D3 (Regime A, m = 0.35)}',...
    'interpreter', 'latex','Fontsize',14);
hLg.LineWidth =1; % to make thin line of legend box line
legend('Location','north'); legend('boxoff'),legend show
hold off