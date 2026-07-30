%% AQ_CURVE_PARAMETER_ANOVA.m
% =========================================================================
% SEPARATE ANOVA / MIXED-MODEL ANALYSIS FOR LI-6800 A-Q CURVES
%
% INPUT:
%   AQ_Combined_All_Stages.csv
%
% SCIENTIFIC UNIT:
%   One CurveID = one independent A-Q curve / one leaf sample.
%   PAR points within a curve are repeated observations and are NOT treated
%   as independent biological replicates.
%
% ANALYSES:
%   1. Fit each curve with a nonrectangular hyperbola.
%   2. Extract Amax, Alpha, Theta, Rd, LCP, Q75, R2, RMSE and MAE.
%   3. Run stage mixed-model ANOVA.
%   4. Run within-stage moisture / hybrid models only when supported.
%   5. Run an optional whole-curve repeated-measures model.
%   6. Create publication-quality figures and CSV outputs.
% =========================================================================

clear;
clc;
close all;

fprintf('\n============================================================\n');
fprintf(' LI-6800 A-Q CURVE PARAMETER ANOVA\n');
fprintf('============================================================\n');

%% 1. USER SETTINGS
inputCSV = 'AQ_Combined_All_Stages.csv';
outputFolder = 'AQ_ANOVA_Output';
minimumPARLevelsForFit = 6;
minimumCurvesPerInteractionCell = 2;

AmaxLower = 1;
AmaxUpper = 120;
alphaLower = 0.001;
alphaUpper = 0.20;
thetaLower = 0.20;
thetaUpper = 0.999;
RdLower = 0;
RdUpper = 15;

minimumAcceptableR2 = 0.80;
maximumAcceptableRMSE = 10;
figureResolution = 600;
rng(2026);

if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

%% 2. READ COMBINED A-Q DATA
if ~isfile(inputCSV)
    [fileName,filePath] = uigetfile('*.csv','Select AQ_Combined_All_Stages.csv');
    if isequal(fileName,0)
        error('No combined A-Q CSV selected.');
    end
    inputCSV = fullfile(filePath,fileName);
end

T = readtable(inputCSV,'VariableNamingRule','preserve');

requiredVariables = {'Stage','CurveID','Replication','Moisture','Hybrid', ...
    'PARbin','MeanPAR','MeanA'};
missingVariables = requiredVariables(~ismember(requiredVariables,T.Properties.VariableNames));
if ~isempty(missingVariables)
    error('Missing required variables: %s',strjoin(missingVariables,', '));
end

T.Stage = categorical(string(T.Stage));
T.CurveID = categorical(string(T.CurveID));
T.Replication = categoricalSafe(T.Replication,'R');
T.Moisture = categoricalSafe(T.Moisture,'M');
T.Hybrid = categoricalSafe(T.Hybrid,'H');
T.MeanPAR = double(T.MeanPAR);
T.MeanA = double(T.MeanA);

validRows = isfinite(T.MeanPAR) & isfinite(T.MeanA);
T = T(validRows,:);
T = sortrows(T,{'Stage','CurveID','MeanPAR'});

curveIDs = categories(T.CurveID);

fprintf('Input rows:          %d\n',height(T));
fprintf('Independent curves: %d\n',numel(curveIDs));
fprintf('Growth stages:       %d\n',numel(categories(T.Stage)));

%% 3. FIT EACH A-Q CURVE INDIVIDUALLY
CurveParameters = table();
CurveFitPoints = table();

for curveNumber = 1:numel(curveIDs)
    currentID = curveIDs{curveNumber};
    C = T(T.CurveID==currentID,:);
    C = sortrows(C,'MeanPAR');

    [groupID,uniquePAR] = findgroups(C.MeanPAR);
    Amean = splitapply(@(x)mean(x,'omitnan'),C.MeanA,groupID);

    Q = uniquePAR;
    A = Amean;
    valid = isfinite(Q) & isfinite(A);
    Q = Q(valid);
    A = A(valid);

    if numel(Q) < minimumPARLevelsForFit
        fprintf('Skipped %-45s: only %d PAR levels\n',currentID,numel(Q));
        continue;
    end

    lowLightIndex = Q <= 400;
    if sum(lowLightIndex) >= 3
        pLow = polyfit(Q(lowLightIndex),A(lowLightIndex),1);
        alpha0 = max(min(pLow(1),0.12),0.005);
        Rd0 = max(min(-pLow(2),8),0.5);
    else
        alpha0 = 0.05;
        Rd0 = max(min(-min(A),8),0.5);
    end

    Amax0 = max(A,[],'omitnan') + Rd0;
    Amax0 = max(min(Amax0,90),10);
    theta0 = 0.85;

    beta0 = [Amax0,alpha0,theta0,Rd0];
    lowerBounds = [AmaxLower,alphaLower,thetaLower,RdLower];
    upperBounds = [AmaxUpper,alphaUpper,thetaUpper,RdUpper];

    try
        [beta,Afit,fitStats,exitFlag] = fitNonrectangularHyperbola( ...
            Q,A,beta0,lowerBounds,upperBounds);

        Amax = beta(1);
        Alpha = beta(2);
        Theta = beta(3);
        Rd = beta(4);
        LCP = Rd/Alpha;

        Qgrid = linspace(0,max(2500,max(Q)),2000)';
        Agrid = nonrectangularHyperbola(beta,Qgrid);
        target75 = 0.75*(Amax-Rd);
        [~,idx75] = min(abs(Agrid-target75));
        Q75 = Qgrid(idx75);

        metadata = C(1,:);

        currentRow = table(metadata.Stage,metadata.CurveID, ...
            metadata.Replication,metadata.Moisture,metadata.Hybrid, ...
            numel(Q),min(Q),max(Q),Amax,Alpha,Theta,Rd,LCP,Q75, ...
            fitStats.R2,fitStats.RMSE,fitStats.MAE,exitFlag, ...
            'VariableNames',{'Stage','CurveID','Replication','Moisture','Hybrid', ...
            'N_PAR','MinimumPAR','MaximumPAR','Amax','Alpha','Theta','Rd','LCP','Q75', ...
            'R2fit','RMSEfit','MAEfit','ExitFlag'});

        currentRow.QC_Acceptable = currentRow.R2fit >= minimumAcceptableR2 & ...
            currentRow.RMSEfit <= maximumAcceptableRMSE & ...
            currentRow.Amax > 0 & currentRow.Alpha > 0 & ...
            currentRow.Theta > 0 & currentRow.Theta <= 1 & currentRow.Rd >= 0;

        CurveParameters = [CurveParameters;currentRow]; %#ok<AGROW>

        pointRows = table(repmat(metadata.Stage,numel(Q),1), ...
            repmat(metadata.CurveID,numel(Q),1),Q,A,Afit,A-Afit, ...
            'VariableNames',{'Stage','CurveID','PAR','ObservedA','FittedA','Residual'});
        CurveFitPoints = [CurveFitPoints;pointRows]; %#ok<AGROW>

        fprintf('Fitted %-46s R2=%.3f RMSE=%.2f\n',currentID,fitStats.R2,fitStats.RMSE);

    catch ME
        fprintf('Fit failed %-42s: %s\n',currentID,ME.message);
    end
end

if isempty(CurveParameters)
    error('No A-Q curves were successfully fitted.');
end

CurveParameters = sortrows(CurveParameters,{'Stage','CurveID'});
writetable(CurveParameters,fullfile(outputFolder,'AQ_Curve_Parameters.csv'));
writetable(CurveFitPoints,fullfile(outputFolder,'AQ_Curve_Fit_QC.csv'));

fprintf('\nSuccessfully fitted curves: %d\n',height(CurveParameters));
fprintf('QC-acceptable curves:       %d\n',sum(CurveParameters.QC_Acceptable));

%% 4. TREATMENT CELL COUNTS
TreatmentCounts = groupsummary(CurveParameters,{'Stage','Moisture','Hybrid'});
TreatmentCounts.Properties.VariableNames{strcmp(TreatmentCounts.Properties.VariableNames,'GroupCount')} = 'NumberCurves';
writetable(TreatmentCounts,fullfile(outputFolder,'AQ_Treatment_Cell_Counts.csv'));

%% 5. DESCRIPTIVE STATISTICS
parameterNames = {'Amax','Alpha','Theta','Rd','LCP','Q75'};
DescriptiveStatistics = table();

for parameterNumber = 1:numel(parameterNames)
    responseName = parameterNames{parameterNumber};
    valid = CurveParameters.QC_Acceptable & isfinite(CurveParameters.(responseName));
    D = CurveParameters(valid,:);
    if isempty(D), continue; end

    groupID = findgroups(D.Stage);
    Stage = splitapply(@(x)x(1),D.Stage,groupID);
    N = splitapply(@numel,D.(responseName),groupID);
    Mean = splitapply(@(x)mean(x,'omitnan'),D.(responseName),groupID);
    SD = splitapply(@(x)std(x,0,'omitnan'),D.(responseName),groupID);
    SE = SD./sqrt(N);
    Median = splitapply(@(x)median(x,'omitnan'),D.(responseName),groupID);
    Minimum = splitapply(@(x)min(x,[],'omitnan'),D.(responseName),groupID);
    Maximum = splitapply(@(x)max(x,[],'omitnan'),D.(responseName),groupID);

    Current = table(repmat(string(responseName),numel(Stage),1),Stage,N,Mean,SD,SE, ...
        Median,Minimum,Maximum,'VariableNames',{'Parameter','Stage','N','Mean','SD','SE', ...
        'Median','Minimum','Maximum'});
    DescriptiveStatistics = [DescriptiveStatistics;Current]; %#ok<AGROW>
end

writetable(DescriptiveStatistics,fullfile(outputFolder,'AQ_Descriptive_Statistics.csv'));

%% 6. STAGE EFFECT ACROSS ALL CURVES
ANOVA_Stage = table();

for parameterNumber = 1:numel(parameterNames)
    responseName = parameterNames{parameterNumber};
    valid = CurveParameters.QC_Acceptable & isfinite(CurveParameters.(responseName));
    D = CurveParameters(valid,:);

    if height(D) < 8 || numel(categories(removecats(D.Stage))) < 2
        continue;
    end

    try
        if numberValidCategories(D.Replication) >= 2
            formula = sprintf('%s ~ Stage + (1|Replication)',responseName);
        else
            formula = sprintf('%s ~ Stage',responseName);
        end

        model = fitlme(D,formula,'FitMethod','REML','DummyVarCoding','effects');
        A = anova(model,'DFMethod','satterthwaite');
        Current = anovaTableToLong(A,responseName,"All stages",formula);
        ANOVA_Stage = [ANOVA_Stage;Current]; %#ok<AGROW>
    catch ME
        fprintf('Stage model failed for %s: %s\n',responseName,ME.message);
    end
end

writetable(ANOVA_Stage,fullfile(outputFolder,'AQ_ANOVA_Stage.csv'));

%% 7. WITHIN-STAGE MOISTURE / HYBRID MODELS
ANOVA_WithinStage = table();
ModelSelectionLog = table();
stageLevels = categories(CurveParameters.Stage);

for stageNumber = 1:numel(stageLevels)
    stageName = stageLevels{stageNumber};
    S = CurveParameters(CurveParameters.Stage==stageName & CurveParameters.QC_Acceptable,:);
    if isempty(S), continue; end

    for parameterNumber = 1:numel(parameterNames)
        responseName = parameterNames{parameterNumber};
        D = S(isfinite(S.(responseName)),:);
        if height(D) < 5, continue; end

        moistureLevels = numberValidCategories(D.Moisture);
        hybridLevels = numberValidCategories(D.Hybrid);
        replicationLevels = numberValidCategories(D.Replication);

        cellCounts = groupsummary(D,{'Moisture','Hybrid'});
        minimumCellCount = min(cellCounts.GroupCount);

        formula = "";
        modelType = "";

        if moistureLevels >= 2 && hybridLevels >= 2 && ...
                minimumCellCount >= minimumCurvesPerInteractionCell && height(D) >= 10
            if replicationLevels >= 2
                formula = sprintf('%s ~ Moisture*Hybrid + (1|Replication) + (1|Replication:Moisture)',responseName);
            else
                formula = sprintf('%s ~ Moisture*Hybrid',responseName);
            end
            modelType = "Moisture x Hybrid";

        elseif moistureLevels >= 2 && hybridLevels >= 2
            if replicationLevels >= 2
                formula = sprintf('%s ~ Moisture + Hybrid + (1|Replication)',responseName);
            else
                formula = sprintf('%s ~ Moisture + Hybrid',responseName);
            end
            modelType = "Additive moisture + hybrid";

        elseif moistureLevels >= 2
            if replicationLevels >= 2
                formula = sprintf('%s ~ Moisture + (1|Replication)',responseName);
            else
                formula = sprintf('%s ~ Moisture',responseName);
            end
            modelType = "Moisture only";

        elseif hybridLevels >= 2
            if replicationLevels >= 2
                formula = sprintf('%s ~ Hybrid + (1|Replication)',responseName);
            else
                formula = sprintf('%s ~ Hybrid',responseName);
            end
            modelType = "Hybrid only";
        end

        if strlength(formula)==0, continue; end

        % Build the one-row log table by explicit variable assignment.
        % This avoids MATLAB interpreting a character formula as multiple
        % table arguments.
        logRow = table();
        logRow.Stage = string(stageName);
        logRow.Parameter = string(responseName);
        logRow.NumberCurves = height(D);
        logRow.MoistureLevels = moistureLevels;
        logRow.HybridLevels = hybridLevels;
        logRow.MinimumCellCount = minimumCellCount;
        logRow.ModelType = string(modelType);
        logRow.Formula = string(formula);

        ModelSelectionLog = [ModelSelectionLog;logRow]; %#ok<AGROW>

        try
            model = fitlme(D,char(formula),'FitMethod','REML','DummyVarCoding','effects');
            A = anova(model,'DFMethod','satterthwaite');
            Current = anovaTableToLong(A,responseName,string(stageName),formula);
            ANOVA_WithinStage = [ANOVA_WithinStage;Current]; %#ok<AGROW>
        catch ME
            fprintf('Within-stage model failed: %s, %s: %s\n',stageName,responseName,ME.message);
        end
    end
end

writetable(ANOVA_WithinStage,fullfile(outputFolder,'AQ_ANOVA_Within_Stage.csv'));
writetable(ModelSelectionLog,fullfile(outputFolder,'AQ_Model_Selection_Log.csv'));

%% 8. WHOLE-CURVE REPEATED-MEASURES MODEL
WholeCurveANOVA = table();
try
    Dcurve = T;
    Dcurve.PARfactor = categorical(Dcurve.PARbin);
    formulaWhole = 'MeanA ~ Stage*PARfactor + (1|CurveID)';
    wholeModel = fitlme(Dcurve,formulaWhole,'FitMethod','REML','DummyVarCoding','effects');
    Awhole = anova(wholeModel,'DFMethod','satterthwaite');
    WholeCurveANOVA = anovaTableToLong(Awhole,"MeanA","Whole curve",formulaWhole);
catch ME
    fprintf('Whole-curve model failed: %s\n',ME.message);
end
writetable(WholeCurveANOVA,fullfile(outputFolder,'AQ_ANOVA_Whole_Curve.csv'));

%% 9. FIGURE 1 - CURVE PARAMETERS BY STAGE
stageOrder = ["Pretasseling","Tasseling","Blister","Milk"];
stageOrder = stageOrder(ismember(stageOrder,string(stageLevels)));
stageColors = [0.20 0.45 0.75;0.85 0.35 0.15;0.20 0.60 0.35;0.55 0.30 0.70];

fig1 = figure('Color','w','Units','inches','Position',[0.3 0.3 12.0 7.5],'Renderer','painters');
tl1 = tiledlayout(fig1,2,3,'TileSpacing','compact','Padding','compact');
title(tl1,'Curve-derived maize photosynthetic parameters across growth stages', ...
    'FontName','Arial','FontSize',14,'FontWeight','bold');

displayParameters = {'Amax','Alpha','Rd','LCP','Theta','Q75'};
displayLabels = {'A_{max} (\mumol CO_2 m^{-2} s^{-1})', ...
    '\alpha (mol CO_2 mol^{-1} photons)','R_d (\mumol CO_2 m^{-2} s^{-1})', ...
    'Light compensation point','\theta','PAR at 75% modeled capacity'};

for parameterNumber = 1:numel(displayParameters)
    responseName = displayParameters{parameterNumber};
    ax = nexttile(tl1,parameterNumber);
    hold(ax,'on'); box(ax,'on');

    for stageNumber = 1:numel(stageOrder)
        stageName = stageOrder(stageNumber);
        values = CurveParameters.(responseName)(string(CurveParameters.Stage)==stageName & ...
            CurveParameters.QC_Acceptable);
        values = values(isfinite(values));
        if isempty(values), continue; end

        xJitter = stageNumber + 0.08*randn(size(values));
        scatter(ax,xJitter,values,28,stageColors(stageNumber,:),'filled', ...
            'MarkerFaceAlpha',0.55,'MarkerEdgeColor','none');

        meanValue = mean(values,'omitnan');
        seValue = std(values,0,'omitnan')/sqrt(numel(values));
        errorbar(ax,stageNumber,meanValue,seValue,'o','Color','k','MarkerFaceColor','w', ...
            'MarkerSize',7,'LineWidth',1.5,'CapSize',6);
    end

    set(ax,'XTick',1:numel(stageOrder),'XTickLabel',cellstr(stageOrder),'XTickLabelRotation',20);
    ylabel(ax,displayLabels{parameterNumber});
    title(ax,char('A'+parameterNumber-1),'HorizontalAlignment','left','FontWeight','bold');
    formatAxes(ax);
end

exportFigureSet(fig1,outputFolder,'Figure1_AQ_Parameter_Stage_Comparison',figureResolution);

%% 10. FIGURE 2 - STAGE MEAN A-Q CURVES +/- BIOLOGICAL SE
StageCurveSummary = summarizeStageCurves(T);

fig2 = figure('Color','w','Units','inches','Position',[0.4 0.4 9.4 6.5],'Renderer','painters');
ax2 = axes(fig2); hold(ax2,'on'); box(ax2,'on');

for stageNumber = 1:numel(stageOrder)
    stageName = stageOrder(stageNumber);
    S = StageCurveSummary(string(StageCurveSummary.Stage)==stageName,:);
    if isempty(S), continue; end

    errorbar(ax2,S.MeanPAR,S.MeanA,S.SEA,'-o','Color',stageColors(stageNumber,:), ...
        'MarkerFaceColor','w','MarkerSize',5.5,'LineWidth',2.0,'CapSize',4, ...
        'DisplayName',sprintf('%s (n=%d curves)',stageName,max(S.NCurves)));
end

yline(ax2,0,':','Color',[0.3 0.3 0.3]);
xlabel(ax2,'Incident PAR, Q_{in} (\mumol photons m^{-2} s^{-1})');
ylabel(ax2,'Net assimilation, A (\mumol CO_2 m^{-2} s^{-1})');
title(ax2,'Mean maize A-Q responses across growth stages');
legend(ax2,'Location','southeast','Box','off');
xlim(ax2,[0 2250]);
formatAxes(ax2);

writetable(StageCurveSummary,fullfile(outputFolder,'AQ_Stage_Curve_Summary.csv'));
exportFigureSet(fig2,outputFolder,'Figure2_AQ_Stage_Mean_Curves',figureResolution);

%% 11. FIGURE 3 - EXPLORATORY MOISTURE x HYBRID INTERACTION
fig3 = figure('Color','w','Units','inches','Position',[0.4 0.4 11.5 8.0],'Renderer','painters');
tl3 = tiledlayout(fig3,2,2,'TileSpacing','compact','Padding','compact');
title(tl3,'Exploratory A_{max} response by moisture and hybrid within stage', ...
    'FontName','Arial','FontSize',14,'FontWeight','bold');

for stageNumber = 1:min(4,numel(stageOrder))
    stageName = stageOrder(stageNumber);
    ax = nexttile(tl3,stageNumber); hold(ax,'on'); box(ax,'on');

    D = CurveParameters(string(CurveParameters.Stage)==stageName & ...
        CurveParameters.QC_Acceptable & isfinite(CurveParameters.Amax),:);

    moistureLevels = categories(removecats(D.Moisture));
    hybridLevels = categories(removecats(D.Hybrid));
    lineColors = lines(max(1,numel(moistureLevels)));

    for moistureNumber = 1:numel(moistureLevels)
        moistureName = moistureLevels{moistureNumber};
        meanValues = nan(numel(hybridLevels),1);
        seValues = nan(numel(hybridLevels),1);

        for hybridNumber = 1:numel(hybridLevels)
            hybridName = hybridLevels{hybridNumber};
            values = D.Amax(D.Moisture==moistureName & D.Hybrid==hybridName);
            values = values(isfinite(values));
            if isempty(values), continue; end
            meanValues(hybridNumber) = mean(values,'omitnan');
            if numel(values)>1
                seValues(hybridNumber) = std(values,0,'omitnan')/sqrt(numel(values));
            else
                seValues(hybridNumber) = 0;
            end
        end

        errorbar(ax,1:numel(hybridLevels),meanValues,seValues,'-o', ...
            'Color',lineColors(moistureNumber,:),'MarkerFaceColor','w', ...
            'LineWidth',1.7,'CapSize',4,'DisplayName',moistureName);
    end

    set(ax,'XTick',1:numel(hybridLevels),'XTickLabel',hybridLevels);
    xlabel(ax,'Hybrid'); ylabel(ax,'A_{max}');
    title(ax,stageName,'FontWeight','bold');
    if stageNumber==1, legend(ax,'Location','best','Box','off'); end
    formatAxes(ax);
end

exportFigureSet(fig3,outputFolder,'Figure3_AQ_Interaction_Exploratory',figureResolution);

%% 12. SAVE WORKSPACE AND SUMMARY
save(fullfile(outputFolder,'AQ_ANOVA_Workspace.mat'));

fprintf('\n============================================================\n');
fprintf(' A-Q ANOVA ANALYSIS COMPLETED\n');
fprintf('============================================================\n');
fprintf('Successfully fitted curves: %d\n',height(CurveParameters));
fprintf('QC-acceptable curves:       %d\n',sum(CurveParameters.QC_Acceptable));
fprintf('\nOutput folder:\n%s\n',fullfile(pwd,outputFolder));
fprintf('============================================================\n');

%% LOCAL FUNCTIONS
function C = categoricalSafe(x,prefix)
    if iscategorical(x), C = x; return; end
    if isnumeric(x)
        labels = strings(size(x));
        for i = 1:numel(x)
            if isfinite(x(i)), labels(i) = prefix + string(x(i)); else, labels(i) = "Missing"; end
        end
        C = categorical(labels);
    else
        labels = string(x);
        labels(ismissing(labels) | strlength(labels)==0) = "Missing";
        alreadyPrefixed = startsWith(labels,prefix);
        labels(~alreadyPrefixed & labels~="Missing") = prefix + labels(~alreadyPrefixed & labels~="Missing");
        C = categorical(labels);
    end
end

function n = numberValidCategories(C)
    if ~iscategorical(C), C = categorical(C); end
    cats = categories(removecats(C));
    cats = cats(~strcmp(cats,'Missing'));
    n = numel(cats);
end

function [beta,Afit,stats,exitFlag] = fitNonrectangularHyperbola(Q,A,beta0,lowerBounds,upperBounds)
    modelFunction = @(b,q) (((b(2).*q + b(1)) - ...
        sqrt(max((b(2).*q + b(1)).^2 - 4.*b(3).*b(2).*q.*b(1),0))) ./ ...
        (2.*b(3))) - b(4);

    transform = @(z,lower,upper) lower + (upper-lower)./(1+exp(-z));
    inverseTransform = @(b,lower,upper) log((b-lower)./(upper-b));

    safeBeta0 = min(max(beta0,lowerBounds+1e-6),upperBounds-1e-6);
    z0 = inverseTransform(safeBeta0,lowerBounds,upperBounds);
    objective = @(z) sum((A-modelFunction(transform(z,lowerBounds,upperBounds),Q)).^2);

    options = optimset('Display','off','MaxIter',30000,'MaxFunEvals',60000, ...
        'TolX',1e-10,'TolFun',1e-10);
    [z,~,exitFlag] = fminsearch(objective,z0,options);

    beta = transform(z,lowerBounds,upperBounds);
    Afit = modelFunction(beta,Q);
    residual = A-Afit;
    SSE = sum(residual.^2);
    SST = sum((A-mean(A)).^2);
    if SST>0, R2 = 1-SSE/SST; else, R2 = NaN; end
    stats.R2 = R2;
    stats.RMSE = sqrt(mean(residual.^2));
    stats.MAE = mean(abs(residual));
end

function A = nonrectangularHyperbola(beta,Q)
    Amax = beta(1); alpha = beta(2); theta = beta(3); Rd = beta(4);
    discriminant = (alpha.*Q + Amax).^2 - 4.*theta.*alpha.*Q.*Amax;
    discriminant = max(discriminant,0);
    A = ((alpha.*Q + Amax) - sqrt(discriminant)) ./ (2.*theta) - Rd;
end

function Long = anovaTableToLong(A,responseName,scopeName,formula)
    % ANOVA output from FITLME can be a table in some MATLAB releases and
    % a dataset array in others. This function supports both formats.

    variableNames = string(A.Properties.VariableNames);

    % Obtain model terms. Newer releases commonly store them in a Term
    % variable; older outputs may use observation/row names.
    if any(variableNames == "Term")
        terms = string(A.Term);
    elseif isprop(A.Properties,'RowNames') && ~isempty(A.Properties.RowNames)
        terms = string(A.Properties.RowNames);
    elseif isprop(A.Properties,'ObsNames') && ~isempty(A.Properties.ObsNames)
        terms = string(A.Properties.ObsNames);
    else
        terms = "Term_" + string((1:size(A,1))');
    end

    terms = terms(:);
    numberRows = numel(terms);

    denominatorDF = extractAnovaVariable(A, ...
        {'DF2','DenDF','DenominatorDF'},numberRows);

    numeratorDF = extractAnovaVariable(A, ...
        {'DF1','NumDF','NumeratorDF','DF'},numberRows);

    Fstat = extractAnovaVariable(A, ...
        {'FStat','F','FStatistic'},numberRows);

    pValue = extractAnovaVariable(A, ...
        {'pValue','p','ProbF'},numberRows);

    Long = table();
    Long.Response = repmat(string(responseName),numberRows,1);
    Long.Scope = repmat(string(scopeName),numberRows,1);
    Long.Formula = repmat(string(formula),numberRows,1);
    Long.Term = terms;
    Long.NumeratorDF = numeratorDF;
    Long.DenominatorDF = denominatorDF;
    Long.FStatistic = Fstat;
    Long.pValue = pValue;
end

function value = extractAnovaVariable(T,candidates,numberRows)
    % Extract a numeric variable from table or dataset ANOVA output.

    value = nan(numberRows,1);
    variableNames = string(T.Properties.VariableNames);

    for i = 1:numel(candidates)
        index = find(strcmpi(variableNames,candidates{i}),1);

        if ~isempty(index)
            variableName = char(variableNames(index));
            currentValue = T.(variableName);

            if iscell(currentValue)
                currentValue = cellfun(@double,currentValue);
            end

            currentValue = double(currentValue);
            currentValue = currentValue(:);

            if numel(currentValue) == numberRows
                value = currentValue;
            else
                value(1:min(numberRows,numel(currentValue))) = ...
                    currentValue(1:min(numberRows,numel(currentValue)));
            end
            return;
        end
    end
end

function S = summarizeStageCurves(T)
    groupCurve = findgroups(T.Stage,T.CurveID,T.PARbin);
    StageCurve = splitapply(@(x)x(1),T.Stage,groupCurve);
    CurveID = splitapply(@(x)x(1),T.CurveID,groupCurve);
    PARbin = splitapply(@(x)x(1),T.PARbin,groupCurve);
    MeanPARcurve = splitapply(@(x)mean(x,'omitnan'),T.MeanPAR,groupCurve);
    MeanAcurve = splitapply(@(x)mean(x,'omitnan'),T.MeanA,groupCurve);

    CurveLevel = table(StageCurve,CurveID,PARbin,MeanPARcurve,MeanAcurve, ...
        'VariableNames',{'Stage','CurveID','PARbin','MeanPAR','MeanA'});

    groupStage = findgroups(CurveLevel.Stage,CurveLevel.PARbin);
    Stage = splitapply(@(x)x(1),CurveLevel.Stage,groupStage);
    PARbin = splitapply(@(x)x(1),CurveLevel.PARbin,groupStage);
    MeanPAR = splitapply(@(x)mean(x,'omitnan'),CurveLevel.MeanPAR,groupStage);
    MeanA = splitapply(@(x)mean(x,'omitnan'),CurveLevel.MeanA,groupStage);
    SDA = splitapply(@(x)std(x,0,'omitnan'),CurveLevel.MeanA,groupStage);
    NCurves = splitapply(@numel,CurveLevel.MeanA,groupStage);
    SEA = SDA./sqrt(NCurves);

    S = table(Stage,PARbin,MeanPAR,MeanA,SDA,SEA,NCurves);
    S = sortrows(S,{'Stage','MeanPAR'});
end

function formatAxes(ax)
    grid(ax,'on');
    ax.GridAlpha = 0.10;
    ax.MinorGridAlpha = 0.05;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    set(ax,'FontName','Arial','FontSize',9.5,'LineWidth',1.0,'TickDir','out','Layer','top');
end

function exportFigureSet(fig,folder,baseName,resolution)
    exportgraphics(fig,fullfile(folder,[baseName '.png']),'Resolution',resolution,'BackgroundColor','white');
    exportgraphics(fig,fullfile(folder,[baseName '.tif']),'Resolution',resolution,'BackgroundColor','white');
    exportgraphics(fig,fullfile(folder,[baseName '.pdf']),'ContentType','vector','BackgroundColor','white');
    savefig(fig,fullfile(folder,[baseName '.fig']));
end
