%% ============================================================
% ET-BASED IRRIGATION SCHEDULE ONLY
% Per irrigation zone + per plant
% Treatments: 100%, 75%, 50% ETc
%% ============================================================

clear; clc; close all;

%% Output folder
outFolder = fullfile(pwd,'Output_ET_Schedule_Only');
if ~exist(outFolder,'dir')
    mkdir(outFolder);
end

%% Basic setup
zoneArea_m2 = 33.25;     % irrigation zone area
plantsPerZone = 36;      % 3 hybrid plots x 12 plants

%% ET data
Stage = ["Emergence (VE)"
         "V4 leaf stage"
         "V8 stage"
         "V12"
         "VT tasseling"
         "Silking (R1)"
         "Blister kernel (R2)"
         "Beginning dent (R4.7)"
         "Full dent (R5.5)"
         "Maturity (R6)"];

StageCode = ["VE","V4","V8","V12","VT","R1","R2","R4.7","R5.5","R6"];

ET_inch_day = [0.08 0.10 0.18 0.26 0.32 0.35 0.32 0.24 0.20 0.10]';
ET_mm_day = ET_inch_day * 25.4;

%% Water per irrigation zone
L_zone_100 = ET_mm_day * zoneArea_m2;
L_zone_75  = L_zone_100 * 0.75;
L_zone_50  = L_zone_100 * 0.50;

%% Water per plant
L_plant_100 = L_zone_100 / plantsPerZone;
L_plant_75  = L_zone_75  / plantsPerZone;
L_plant_50  = L_zone_50  / plantsPerZone;

%% Final table
T = table(Stage, StageCode', ET_inch_day, ET_mm_day, ...
    L_zone_100, L_zone_75, L_zone_50, ...
    L_plant_100, L_plant_75, L_plant_50, ...
    'VariableNames', {'Stage','StageCode','ET_inch_day','ET_mm_day', ...
    'Zone_L_day_100_ETc','Zone_L_day_75_ETc','Zone_L_day_50_ETc', ...
    'Plant_L_day_100_ETc','Plant_L_day_75_ETc','Plant_L_day_50_ETc'});

disp(T)

writetable(T, fullfile(outFolder,'ET_Schedule_Per_Zone_Per_Plant.csv'));

%% Figure: per irrigation zone
fig1 = figure('Color','w','Position',[100 100 1300 650]);
x = 1:numel(StageCode);
bw = 0.25;

bar(x-bw,L_zone_100,bw,'FaceColor',[0.20 0.55 0.20],'EdgeColor','none'); hold on;
bar(x,L_zone_75,bw,'FaceColor',[0.20 0.45 0.85],'EdgeColor','none');
bar(x+bw,L_zone_50,bw,'FaceColor',[0.85 0.25 0.25],'EdgeColor','none');

set(gca,'XTick',x,'XTickLabel',StageCode,'FontSize',13,'LineWidth',1.2,...
    'Box','off','TickDir','out');

ylabel('Water per irrigation zone (L day^{-1})','FontWeight','bold','FontSize',14);
xlabel('Corn growth stage','FontWeight','bold','FontSize',14);
title('Daily Irrigation Water Requirement per Zone','FontWeight','bold','FontSize',16);

legend({'100% ETc','75% ETc','50% ETc'},'Location','northwest','Box','off');
grid on; ax = gca; ax.GridAlpha = 0.18;

exportgraphics(fig1, fullfile(outFolder,'Figure_Zone_Water_Requirement.png'),'Resolution',450);

%% Figure: per plant
fig2 = figure('Color','w','Position',[120 120 1300 650]);

bar(x-bw,L_plant_100,bw,'FaceColor',[0.20 0.55 0.20],'EdgeColor','none'); hold on;
bar(x,L_plant_75,bw,'FaceColor',[0.20 0.45 0.85],'EdgeColor','none');
bar(x+bw,L_plant_50,bw,'FaceColor',[0.85 0.25 0.25],'EdgeColor','none');

set(gca,'XTick',x,'XTickLabel',StageCode,'FontSize',13,'LineWidth',1.2,...
    'Box','off','TickDir','out');

ylabel('Water per plant (L plant^{-1} day^{-1})','FontWeight','bold','FontSize',14);
xlabel('Corn growth stage','FontWeight','bold','FontSize',14);
title('Daily Irrigation Water Requirement per Plant','FontWeight','bold','FontSize',16);

legend({'100% ETc','75% ETc','50% ETc'},'Location','northwest','Box','off');
grid on; ax = gca; ax.GridAlpha = 0.18;

exportgraphics(fig2, fullfile(outFolder,'Figure_Per_Plant_Water_Requirement.png'),'Resolution',450);

%% Figure: combined clean table
fig3 = figure('Color','w','Position',[100 100 1500 520]);

uitable(fig3, ...
    'Data',[ET_inch_day ET_mm_day L_zone_100 L_zone_75 L_zone_50 ...
            L_plant_100 L_plant_75 L_plant_50], ...
    'ColumnName',{'ET inch/day','ET mm/day','Zone 100% L/day','Zone 75% L/day', ...
                  'Zone 50% L/day','Plant 100% L/day','Plant 75% L/day','Plant 50% L/day'}, ...
    'RowName',cellstr(Stage), ...
    'Units','normalized', ...
    'Position',[0.02 0.02 0.96 0.96], ...
    'FontSize',11);

exportgraphics(fig3, fullfile(outFolder,'Figure_ET_Table_Zone_Plant.png'),'Resolution',300);

%% Print key message
fprintf('\n====================================================\n');
fprintf('ET IRRIGATION SCHEDULE COMPLETED\n');
fprintf('====================================================\n');
fprintf('Zone area used       = %.2f m2\n', zoneArea_m2);
fprintf('Plants per zone      = %d plants\n', plantsPerZone);
fprintf('Peak stage           = R1 silking\n');
fprintf('Peak 100%% ETc zone   = %.2f L/day\n', max(L_zone_100));
fprintf('Peak 100%% ETc plant  = %.2f L/plant/day\n', max(L_plant_100));
fprintf('Peak 75%% ETc zone    = %.2f L/day\n', max(L_zone_75));
fprintf('Peak 75%% ETc plant   = %.2f L/plant/day\n', max(L_plant_75));
fprintf('Peak 50%% ETc zone    = %.2f L/day\n', max(L_zone_50));
fprintf('Peak 50%% ETc plant   = %.2f L/plant/day\n', max(L_plant_50));
fprintf('Saved folder         = %s\n', outFolder);
fprintf('====================================================\n');