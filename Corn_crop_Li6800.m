%% AQ_COMBINED_LOW_MEMORY.m
% Reads all A-Q sheets from four LI-6800 workbooks.
% Keeps only essential variables.
%
% OUTPUTS:
%   1. AQ_Combined_All_Stages.csv
%   2. AQ_Combined_All_Stages.png

clear;
clc;
close all;

%% Files and growth stages
files = {
    'Pretasseling.xlsx',   'Pretasseling'
    'Tassel_Data.xlsx',    'Tasseling'
    'Blister.xlsx',        'Blister'
    'Milk_stage_data.xlsx','Milk'
};

%% Settings
PARbinWidth = 25;
minimumPARLevels = 5;

minimumA = -30;
maximumA = 120;

minimumPAR = -10;
maximumPAR = 2500;

%% Compact combined table
CombinedAQ = table();

fprintf('\n=============================================\n');
fprintf('LOW-MEMORY COMBINED A-Q PROCESSING\n');
fprintf('=============================================\n');

%% Process each workbook
for f = 1:size(files,1)

    fileName = files{f,1};
    stageName = string(files{f,2});

    if ~isfile(fileName)
        fprintf('Missing file: %s\n', fileName);
        continue;
    end

    sheets = sheetnames(fileName);

    fprintf('\n%s: %d worksheets\n', ...
        fileName, numel(sheets));

    %% Process one sheet at a time
    for s = 1:numel(sheets)

        sheetName = string(sheets{s});

        try
            %% Read only header rows
            header = readcell(fileName, ...
                'Sheet', sheetName, ...
                'Range', 'A14:KJ15', ...
                'UseExcel', false);

            if size(header,1) < 2
                continue;
            end

            groups = string(header(1,:));
            names = string(header(2,:));

            combinedNames = lower( ...
                strtrim(groups + "_" + names));

            combinedNames = erase(combinedNames, ...
                [" ","-","'","(",")","/","\","[","]"]);

            %% Find A and Qin columns
            Acol = find( ...
                contains(combinedNames,"gasex_a") | ...
                strcmpi(strtrim(names),"A"), ...
                1);

            Qcol = find( ...
                contains(combinedNames,"leafq_qin") | ...
                strcmpi(strtrim(names),"Qin"), ...
                1);

            if isempty(Acol) || isempty(Qcol)
                fprintf('Skipped %-35s: A or Qin missing\n', ...
                    sheetName);
                continue;
            end

            %% Read only required section between A and Qin
            firstColumn = min(Acol,Qcol);
            lastColumn = max(Acol,Qcol);

            rangeText = sprintf('%s17:%s1000', ...
                excelColumn(firstColumn), ...
                excelColumn(lastColumn));

            raw = readcell(fileName, ...
                'Sheet', sheetName, ...
                'Range', rangeText, ...
                'UseExcel', false);

            localAcol = Acol - firstColumn + 1;
            localQcol = Qcol - firstColumn + 1;

            A = cellToNumeric(raw(:,localAcol));
            Qin = cellToNumeric(raw(:,localQcol));

            %% Quality control
            valid = ...
                isfinite(A) & ...
                isfinite(Qin) & ...
                A >= minimumA & ...
                A <= maximumA & ...
                Qin >= minimumPAR & ...
                Qin <= maximumPAR;

            A = A(valid);
            Qin = Qin(valid);

            if isempty(A)
                fprintf('Skipped %-35s: no valid data\n', ...
                    sheetName);
                continue;
            end

            %% Bin PAR values
            PARbin = round(Qin/PARbinWidth)*PARbinWidth;

            if numel(unique(PARbin)) < minimumPARLevels
                fprintf('Skipped %-35s: fewer than %d PAR levels\n', ...
                    sheetName, minimumPARLevels);
                continue;
            end

            %% Average repeated observations within curve and PAR
            uniquePAR = unique(PARbin);
            numberPAR = numel(uniquePAR);

            MeanPAR = nan(numberPAR,1);
            MeanA = nan(numberPAR,1);
            SDA = nan(numberPAR,1);
            N = nan(numberPAR,1);

            for p = 1:numberPAR

                idx = PARbin == uniquePAR(p);

                MeanPAR(p) = mean(Qin(idx),'omitnan');
                MeanA(p) = mean(A(idx),'omitnan');
                SDA(p) = std(A(idx),'omitnan');
                N(p) = sum(idx);
            end

            %% Parse metadata from sheet name
            metadata = parseMetadata(sheetName);

            curveID = string(fileName) + "__" + sheetName;

            Current = table( ...
                repmat(stageName,numberPAR,1), ...
                repmat(string(fileName),numberPAR,1), ...
                repmat(sheetName,numberPAR,1), ...
                repmat(curveID,numberPAR,1), ...
                repmat(metadata.Plot,numberPAR,1), ...
                repmat(metadata.Replication,numberPAR,1), ...
                repmat(metadata.Moisture,numberPAR,1), ...
                repmat(metadata.Hybrid,numberPAR,1), ...
                repmat(metadata.Plant,numberPAR,1), ...
                uniquePAR, ...
                MeanPAR, ...
                MeanA, ...
                SDA, ...
                N, ...
                'VariableNames',{ ...
                'Stage', ...
                'Workbook', ...
                'Sheet', ...
                'CurveID', ...
                'Plot', ...
                'Replication', ...
                'Moisture', ...
                'Hybrid', ...
                'Plant', ...
                'PARbin', ...
                'MeanPAR', ...
                'MeanA', ...
                'SDA', ...
                'NRawRows'});

            CombinedAQ = [CombinedAQ; Current]; %#ok<AGROW>

            fprintf('Accepted %-34s: %d PAR levels\n', ...
                sheetName, numberPAR);

            %% Immediately remove large temporary variables
            clear raw A Qin PARbin Current;

        catch ME
            fprintf('Error %-37s: %s\n', ...
                sheetName, ME.message);
        end
    end
end

%% Stop if no data
if isempty(CombinedAQ)
    error('No valid A-Q curves were imported.');
end

%% Sort combined data
CombinedAQ = sortrows(CombinedAQ, ...
    {'Stage','Workbook','Sheet','MeanPAR'});

%% Save one combined CSV
outputCSV = 'AQ_Combined_All_Stages.csv';
writetable(CombinedAQ,outputCSV);

%% Create one combined figure
figure1 = figure( ...
    'Color','w', ...
    'Position',[100 100 950 620]);

ax = axes(figure1);
hold(ax,'on');

stageNames = ["Pretasseling","Tasseling","Blister","Milk"];

stageColors = [
    0.20 0.45 0.75
    0.85 0.35 0.15
    0.20 0.60 0.35
    0.55 0.30 0.70
];

curveIDs = unique(CombinedAQ.CurveID,'stable');

for c = 1:numel(curveIDs)

    T = CombinedAQ( ...
        CombinedAQ.CurveID == curveIDs(c),:);

    T = sortrows(T,'MeanPAR');

    stageIndex = find( ...
        stageNames == T.Stage(1),1);

    if isempty(stageIndex)
        curveColor = [0.5 0.5 0.5];
    else
        curveColor = stageColors(stageIndex,:);
    end

    plot(ax, ...
        T.MeanPAR, ...
        T.MeanA, ...
        '-o', ...
        'Color',curveColor, ...
        'LineWidth',1.0, ...
        'MarkerSize',3, ...
        'MarkerFaceColor','w', ...
        'HandleVisibility','off');
end

%% Add stage legend
legendHandles = gobjects(numel(stageNames),1);

for i = 1:numel(stageNames)

    legendHandles(i) = plot(ax,NaN,NaN, ...
        '-o', ...
        'Color',stageColors(i,:), ...
        'LineWidth',2.5, ...
        'MarkerSize',6, ...
        'MarkerFaceColor','w', ...
        'DisplayName',stageNames(i));
end

yline(ax,0,':','LineWidth',1);

xlabel(ax, ...
    'Incident PAR, Q_{in} (\mumol m^{-2} s^{-1})');

ylabel(ax, ...
    'Net assimilation, A (\mumol m^{-2} s^{-1})');

title(ax, ...
    'Maize A-Q curves across growth stages');

legend(ax,legendHandles, ...
    'Location','southeast', ...
    'Box','off');

grid(ax,'on');
box(ax,'on');

ax.FontName = 'Arial';
ax.FontSize = 11;
ax.LineWidth = 1;
ax.TickDir = 'out';

xlim(ax,[0 2200]);

%% Save one figure
outputFigure = 'AQ_Combined_All_Stages.png';

exportgraphics(figure1, ...
    outputFigure, ...
    'Resolution',600);

%% Final summary
fprintf('\n=============================================\n');
fprintf('PROCESSING COMPLETED\n');
fprintf('=============================================\n');
fprintf('Independent curves: %d\n', ...
    numel(unique(CombinedAQ.CurveID)));

fprintf('Combined rows:      %d\n', ...
    height(CombinedAQ));

fprintf('\nCreated only:\n');
fprintf('1. %s\n',outputCSV);
fprintf('2. %s\n',outputFigure);
fprintf('=============================================\n');

%% ============================================================
% Local functions
% =============================================================

function x = cellToNumeric(column)

    x = nan(numel(column),1);

    for i = 1:numel(column)

        value = column{i};

        if isnumeric(value) && isscalar(value)

            x(i) = double(value);

        elseif islogical(value) && isscalar(value)

            x(i) = double(value);

        elseif ischar(value) || isstring(value)

            x(i) = str2double(string(value));
        end
    end
end

function letters = excelColumn(columnNumber)

    letters = '';

    while columnNumber > 0

        remainder = mod(columnNumber-1,26);

        letters = ...
            [char(65 + remainder), letters]; %#ok<AGROW>

        columnNumber = ...
            floor((columnNumber-1)/26);
    end
end

function metadata = parseMetadata(sheetName)

    text = char(sheetName);

    metadata.Plot = parseCode(text, ...
        '(?:^|[_-])(?:Pl|Plot|Plt)(\d+)(?:[_-]|$)');

    metadata.Replication = parseCode(text, ...
        '(?:^|[_-])R(\d+)(?:[_-]|$)');

    metadata.Moisture = parseCode(text, ...
        '(?:^|[_-])M(\d+)(?:[_-]|$)');

    metadata.Hybrid = parseCode(text, ...
        '(?:^|[_-])H(\d+)(?:[_-]|$)');

    metadata.Plant = parseCode(text, ...
        '(?:^|[_-])P(\d+)(?:[_-]|$)');
end

function value = parseCode(text,expression)

    token = regexp(text,expression, ...
        'tokens','once','ignorecase');

    if isempty(token)
        value = NaN;
    else
        value = str2double(token{1});
    end
end

