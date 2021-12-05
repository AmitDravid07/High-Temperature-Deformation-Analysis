clear;
clc;
%% 1. Experimental used testing parameters
% 1.1  The strain rate 
e = [0.001;0.01;0.1;1;10]; % Strain rates used during the test
ee = log10(e);
xx = -3:0.1:1; % logrithmic strain interpolation
w = xx';
% 1.2 The temperature
t = 1173:50:1373; % experimental used temperature
T = 1173:5:1373; % Interpolation of temperatures
%% 2. Importing adiabatic corrected stress strain data
i= 1;
x = [];
y = [];
for j= 1:5
    k = 1:2:9;
    SR = readtable('D3_adiabatic_corrected_stress_strain_data1.xlsx', 'Sheet',j, 'Range','A3:J683');
    SR = SR{:,:};% used to convert table in to matrix
    x = SR(:,k); 
    y = SR(:,k+1);
    for a =1:5
    g = x(:,a);
    h = y(:,a);
    desiredY(a,i) = interp1(g,h,0.6); % This 0.6 strain, can be changeable 
    end
    i=i+1;
end
%% 3. Interpolation of imported data
% 3.1 logarithimc of stress valuues at desires strain
logST = log10(desiredY);
% 3.2 Interplotation of selected stress data with respect to exp. tested strain rate
p = [];
for i=1:5
    p(:,i) = spline(ee,logST(:,i),w);
end
% 3.3 Interpolation of selected stress with respect to exp. tested temperature
q = [];
for k = 1:41
    q(k,:) = spline(t,p(k,:),T);
end
%% 4. The strain rate sensitivity calculation and plot
m = [];
for k = 1:41
    m (:,k) = gradient(q(:,k))./gradient(w);
end
% Now, m-map plotting
[T,w] = meshgrid(T,w);
contourf(T,w,m,20);
caxis ([0 0.35]); 
set(gca,'XTick',1173:50:1373,'XTickLabel',1173:50:1373)% to manually change the axis level
set(gca,'yTick',-3:1:1,'YTickLabel',-3:1:1)% to manually change the axis level
yline(-1,'k--','LineWidth',2);
ax = gca;
set(gca,'FontSize',16)
ax.FontWeight = 'bold';% for axes to make bold
% ax.LineWidth = 2.5;% for axes line thick
colormap('jet')
% title('\textbf{Strainrate sensitivity plot for D1}','interpreter', 'latex','Fontsize',14)
xlabel('\textbf{Temperature (K)}','interpreter', 'latex','Fontsize',18)
ylabel('\textbf{log\boldmath{$\dot{\varepsilon}$} \boldmath{$(s^{-1})$}}','Interpreter','latex','fontsize',18)
figure()

%% 5. The script to plot ln(stress) vs ln(strain rates) asked from Reviewer#2
mark = {'o', 's', 'd', '^','h'}; % marker type
rang = {'[0 0.4470 0.7410]','[0.8500 0.3250 0.0980]', '[0.4940 0.1840 0.5560]','[0.4660 0.6740 0.1880]', '[0.3010 0.7450 0.9330]'};
strs = [];
for i = 1:5
    strs = desiredY(:,i);
    sc(i) = plot(log10(e), log10(strs), 'marker', mark{i},'markerfacecolor', rang{i}, 'markeredgecolor',rang{i},'MarkerSize', 10, 'linestyle', 'none');
    hold on
 end
hold off
ax = gca;
% set(gca, 'XScale', 'log')
% set(gca, 'YScale', 'log')
xlim([-4 2]); ylim([1.4 2.6]);% axes limit
%xlim([0.0001 100]); ylim([1.4 2.6]);% axes limit
%XTick = [0.0001,0.001,0.01,0.1,1,10,100];% to manually change the axis level
%XTickLabels = num2str(round('$10^{-4}, 10^{-3},10^{-2},10^{-1},1,10,100$'),'Interpreter','latex');
ax.FontWeight = 'bold';% for axes to make bold
ax.LineWidth = 2.5;% for axes line thick
xlabel('\textbf{\boldmath{ln$\dot{\varepsilon}$} \boldmath{$(s^{-1})$}}','Interpreter','latex','fontsize',18)
ylabel('\textbf{\boldmath{ln$\sigma$} \boldmath{$(MPa)$}}','Interpreter','latex','fontsize',18)
hLg = legend([sc(1) sc(2) sc(3) sc(4) sc(5)],{'\boldmath{$Temp. = 1173$ $K$}','\boldmath{$Temp. = 1223$ $K$}',...
    '\boldmath{$Temp. = 1273$ $K$}','\boldmath{$Temp. = 1323$ $K$}','\boldmath{$Temp. = 1373$ $K$}'},'Interpreter','latex');
legend('boxoff'),legend show
legend('Location','best'); 
