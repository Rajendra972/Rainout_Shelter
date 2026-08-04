%% PHOTOSYNTHETICA_02_FIGURES.m
% PART 2: Load saved analysis and create only two final figures.
% Run PHOTOSYNTHETICA_01_ANALYZE.m first.

clear; clc; close all;

outDir=fullfile(pwd,'Photosynthetica_Output');
dataFile=fullfile(outDir,'Analysis_Data.mat');
if ~isfile(dataFile)
    error('Run PHOTOSYNTHETICA_01_ANALYZE first.');
end
load(dataFile);

colors=lines(height(M));
rep=[1 2 4];

set(groot,'defaultFigureColor','w','defaultAxesFontName','Arial', ...
    'defaultAxesFontSize',9,'defaultAxesLineWidth',1, ...
    'defaultAxesTickDir','out','defaultAxesBox','off');

%% FIGURE 1: REPRESENTATIVE RESPONSES
f1=figure('Color','w','Units','centimeters','Position',[2 2 22 10], ...
    'Renderer','painters');
t=tiledlayout(f1,1,2,'TileSpacing','compact','Padding','compact');

ax=nexttile; hold on;
for j=1:numel(rep)
    i=rep(j); B8=R(i).Phi6800Bin; B6=R(i).Phi600Bin;
    errorbar(B8.PAR,B8.Mean,B8.SE,'-o','Color',colors(i,:), ...
        'LineWidth',1.8,'MarkerFaceColor','w','DisplayName',M.Barcode(i)+" LI-6800");
    errorbar(B6.PAR,B6.Mean,B6.SE,'--s','Color',colors(i,:), ...
        'LineWidth',1.3,'MarkerFaceColor',colors(i,:), ...
        'DisplayName',M.Barcode(i)+" LI-600");
end
xlabel('PAR (\mumol photons m^{-2} s^{-1})'); ylabel('\Phi_{PSII}');
title('A. Same-plant \Phi_{PSII}'); xlim([0 2100]); ylim([0 1]); formatAx(ax);
legend('Location','southwest','Interpreter','none','FontSize',6,'Box','off');

ax=nexttile; hold on;
for j=1:numel(rep)
    i=rep(j); B8=R(i).A6800Bin; B6=R(i).A600Bin;
    errorbar(B8.PAR,B8.Mean,B8.SE,'-o','Color',colors(i,:), ...
        'LineWidth',1.8,'MarkerFaceColor','w','DisplayName',M.Barcode(i)+" measured");
    errorbar(B6.PAR,B6.Mean,B6.SE,'--s','Color',colors(i,:), ...
        'LineWidth',1.3,'MarkerFaceColor',colors(i,:), ...
        'DisplayName',M.Barcode(i)+" estimated");
end
yline(0,':'); xlabel('PAR (\mumol photons m^{-2} s^{-1})');
ylabel('A (\mumol CO_2 m^{-2} s^{-1})');
title('B. Measured and LI-600-estimated A'); xlim([0 2100]); ylim([-5 55]); formatAx(ax);
text(.04,.96,sprintf('\\hat{A}=%.3f+%.3fETR_{600}\nETR range %.1f–%.1f', ...
    beta0,beta1,ETRmin,ETRmax),'Units','normalized','VerticalAlignment','top', ...
    'BackgroundColor','w','EdgeColor',[.8 .8 .8],'Margin',3,'FontSize',7);
legend('Location','southeast','Interpreter','none','FontSize',6,'Box','off');

title(t,'Representative same-plant responses in common PAR bins', ...
    'FontWeight','bold','FontSize',12);
saveFigure(f1,outDir,'Figure_1_Representative_Responses');

%% FIGURE 2: CALIBRATION AND VALIDATION
f2=figure('Color','w','Units','centimeters','Position',[2 2 21 17], ...
    'Renderer','painters');
t=tiledlayout(f2,2,2,'TileSpacing','compact','Padding','compact');

ax=nexttile; groupScatter(ax,allPhi6,allPhi8,phiPlant,M,colors);
lims=eqLim(allPhi6,allPhi8); plot(lims,lims,'--k');
x=linspace(lims(1),lims(2),100); plot(x,phiStats.Intercept+phiStats.Slope*x,'r-','LineWidth',2);
axis equal; xlim(lims); ylim(lims); xlabel('LI-600 \Phi_{PSII}'); ylabel('LI-6800 \Phi_{PSII}');
title(sprintf('A. Fluorescence agreement: R^2 = %.2f',phiStats.R2));
boxText(ax,sprintf('y=%.3f+%.3fx\nn=%d\nRMSE=%.3f\nBias=%.3f', ...
    phiStats.Intercept,phiStats.Slope,phiStats.N,phiStats.RMSE,phiStats.Bias)); formatAx(ax);

ax=nexttile; groupScatter(ax,All6800.ETR,All6800.A,All6800.Plant,M,colors);
x=linspace(ETRmin,ETRmax,100); plot(x,beta0+beta1*x,'r-','LineWidth',2);
xlabel('LI-6800 ETR'); ylabel('Measured A');
title(sprintf('B. ETR calibration: R^2 = %.2f',calibrationStats.R2));
boxText(ax,sprintf('A=%.3f+%.3fETR\nn=%d\nRMSE=%.2f', ...
    beta0,beta1,calibrationStats.N,calibrationStats.RMSE)); formatAx(ax);

ax=nexttile; groupScatter(ax,All6800.A,cvA,All6800.Plant,M,colors);
lims=eqLim(All6800.A,cvA); plot(lims,lims,'--k');
x=linspace(lims(1),lims(2),100); plot(x,cvStats.Intercept+cvStats.Slope*x,'r-','LineWidth',2);
axis equal; xlim(lims); ylim(lims); xlabel('Observed A'); ylabel('Cross-validated predicted A');
title(sprintf('C. Leave-one-plant-out: R^2 = %.2f',cvStats.R2));
boxText(ax,sprintf('y=%.3f+%.3fx\nRMSE=%.2f\nBias=%.2f', ...
    cvStats.Intercept,cvStats.Slope,cvStats.RMSE,cvStats.Bias)); formatAx(ax);

ax=nexttile; groupScatter(ax,allA8,allA6,aPlant,M,colors);
lims=eqLim(allA8,allA6); plot(lims,lims,'--k');
x=linspace(lims(1),lims(2),100); plot(x,aStats.Intercept+aStats.Slope*x,'r-','LineWidth',2);
axis equal; xlim(lims); ylim(lims); xlabel('LI-6800 measured A'); ylabel('LI-600 estimated A');
title(sprintf('D. Common-bin assimilation: R^2 = %.2f',aStats.R2));
boxText(ax,sprintf('y=%.3f+%.3fx\nn=%d\nRMSE=%.2f\nBias=%.2f', ...
    aStats.Intercept,aStats.Slope,aStats.N,aStats.RMSE,aStats.Bias)); formatAx(ax);

title(t,'LI-600 to LI-6800 calibration and validation', ...
    'FontWeight','bold','FontSize',12);
saveFigure(f2,outDir,'Figure_2_Calibration_Validation');

fprintf('\nFigures saved in:\n%s\n',outDir);

%% FUNCTIONS
function groupScatter(ax,x,y,g,M,c)
hold(ax,'on');
for i=1:height(M)
    k=g==i; scatter(ax,x(k),y(k),38,c(i,:),'filled', ...
        'MarkerEdgeColor','w','DisplayName',M.Barcode(i));
end
end

function boxText(ax,s)
text(ax,.04,.96,s,'Units','normalized','VerticalAlignment','top', ...
    'BackgroundColor','w','EdgeColor',[.8 .8 .8],'Margin',3,'FontSize',7);
end

function lim=eqLim(x,y)
v=[x(:);y(:)]; v=v(isfinite(v)); lim=[min(v) max(v)];
if diff(lim)==0, lim=lim+[-1 1]; end
lim=lim+[-1 1]*.05*diff(lim);
end

function formatAx(ax)
grid(ax,'on'); ax.GridAlpha=.1; ax.TickDir='out'; ax.Layer='top';
end

function saveFigure(f,outDir,name)
exportgraphics(f,fullfile(outDir,[name '.png']),'Resolution',600,'BackgroundColor','white');
exportgraphics(f,fullfile(outDir,[name '.pdf']),'ContentType','vector','BackgroundColor','white');
savefig(f,fullfile(outDir,[name '.fig']));
end
