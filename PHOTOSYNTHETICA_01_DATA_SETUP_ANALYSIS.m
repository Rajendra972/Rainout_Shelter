%% PHOTOSYNTHETICA_01_ANALYZE.m
% PART 1: Read, match, calibrate, validate, and save results.
% Run this first. Then run PHOTOSYNTHETICA_02_FIGURES.m
%
% Science preserved:
% - LI-600 and LI-6800 are cleaned separately.
% - Same plant + same date are used.
% - Only observed common PAR bins are compared.
% - No interpolation and no extrapolation.
% - LI-6800 measured A is the reference.
% - Assimilation is estimated from LI-600 ETR.
% - Validation leaves out one complete plant at a time.

clear; clc; close all;

%% SETTINGS
parEdges = [0 75 150 250 350 450 550 700 900 1100 1350 1600 1850 2200];
maxPAR = 3000;
outDir = fullfile(pwd,'Photosynthetica_Output');
if ~isfolder(outDir), mkdir(outDir); end

% Four matched plants
M = table( ...
    datetime([2026 7 21; 2026 7 21; 2026 7 20; 2026 7 22]), ...
    ["Pl15-R2-M2-H1-P05";"Pl16-R2-M1-H2-P08"; ...
     "Pl17-R2-M1-H1-P04";"Pl27-R3-M3-H3-P02"], ...
    ["7_21_Plt15_R2_M2_H1_P5_Blister"; ...
     "7_21_Plt16_R2_M1_H2_P8_Blister"; ...
     "7_20_Plt17_R2_M1_H1_P4_Blister"; ...
     "7_22_Plt27_R3_M3_H3_P02_Blister"], ...
    (1:4)', ...
    'VariableNames',{'Date','Barcode','Sheet','PlantID'});

%% SELECT FILES
[f600,p600] = uigetfile({'*.csv;*.xlsx','LI-600 file'},'Select LI-600 file');
if isequal(f600,0), error('No LI-600 file selected.'); end
file600 = fullfile(p600,f600);

[f6800,p6800] = uigetfile('*.xlsx','Select LI-6800 workbook');
if isequal(f6800,0), error('No LI-6800 file selected.'); end
file6800 = fullfile(p6800,f6800);

fprintf('\nLI-600:  %s\nLI-6800: %s\n',file600,file6800);

%% READ LI-600
[~,~,ext] = fileparts(file600);
if strcmpi(ext,'.csv')
    T600 = readtable(file600,'VariableNamingRule','preserve','TextType','string');
else
    T600 = readAllSheets(file600);
end

bVar   = findVar(T600,["USERDEF_Bar_code","Bar_code","Barcode"],["barcode"]);
dVar   = findVar(T600,["SYS_Date","Date","SYS_2"],["date"]);
qVar   = findVar(T600,["SENSOR_Qamb","FLUORO_Qamb","Qamb","PAR"],["qamb","par"]);
phiVar = findVar(T600,["FLUORO_PhiPS2","FLR_PhiPS2","PhiPS2","PhiPSII"],["phips2","phipsii"]);
etrVar = findVar(T600,["FLUORO_ETR","FLR_ETR","ETR"],["etr"]);

if any([bVar dVar qVar phiVar etrVar]=="")
    disp(string(T600.Properties.VariableNames)');
    error('Required LI-600 variables were not detected.');
end

B600   = cleanBarcode(T600.(bVar));
D600   = parseDate(T600.(dVar));
Q600   = num(T600.(qVar));
Phi600 = num(T600.(phiVar));
ETR600 = num(T600.(etrVar));

%% EXTRACT MATCHED PLANTS
sheets = string(sheetnames(file6800));
R = repmat(struct,4,1);
All6800 = table;
DataSummary = table;

for i = 1:height(M)

    mask = B600==cleanBarcode(M.Barcode(i)) & ...
        dateshift(D600,'start','day')==M.Date(i);

    q6 = Q600(mask); p6 = Phi600(mask); e6 = ETR600(mask);
    ok6 = isfinite(q6)&isfinite(p6)&isfinite(e6)& ...
        q6>=0&q6<=maxPAR&p6>=0&p6<=1&e6>=0;
    q6=q6(ok6); p6=p6(ok6); e6=e6(ok6);

    sh = sheets(normName(sheets)==normName(M.Sheet(i)));
    if isempty(sh), error('LI-6800 sheet missing: %s',M.Sheet(i)); end

    T8 = read6800(file6800,sh(1));
    q8Var   = findVar(T8,["LeafQ_Qin","Qin","PAR"],["qin"]);
    phi8Var = findVar(T8,["FLR_PhiPS2","FlrLS_PhiPS2","PhiPS2"],["phips2","phipsii"]);
    etr8Var = findVar(T8,["FLR_ETR","FlrLS_ETR","ETR"],["etr"]);
    a8Var   = findVar(T8,["GasEx_A","A"],["gasexa","assimilation"]);

    if any([q8Var phi8Var etr8Var a8Var]=="")
        disp(string(T8.Properties.VariableNames)');
        error('Required LI-6800 variables missing in %s.',sh(1));
    end

    q8=num(T8.(q8Var)); p8=num(T8.(phi8Var));
    e8=num(T8.(etr8Var)); a8=num(T8.(a8Var));

    ok8=isfinite(q8)&isfinite(p8)&isfinite(e8)&isfinite(a8)& ...
        q8>=0&q8<=maxPAR&p8>=0&p8<=1&e8>=0;
    q8=q8(ok8); p8=p8(ok8); e8=e8(ok8); a8=a8(ok8);

    [q8,ord]=sort(q8); p8=p8(ord); e8=e8(ord); a8=a8(ord);
    [q8,ia]=unique(q8,'stable'); p8=p8(ia); e8=e8(ia); a8=a8(ia);

    R(i).Q600=q6; R(i).Phi600=p6; R(i).ETR600=e6;
    R(i).Q6800=q8; R(i).Phi6800=p8; R(i).ETR6800=e8; R(i).A6800=a8;
    R(i).Phi600Bin=binData(q6,p6,parEdges);
    R(i).Phi6800Bin=binData(q8,p8,parEdges);

    All6800=[All6800;table(repmat(i,numel(a8),1),e8,a8,q8,p8, ...
        'VariableNames',{'Plant','ETR','A','PAR','PhiPSII'})]; %#ok<AGROW>

    DataSummary=[DataSummary;table(M.Date(i),M.Barcode(i),numel(q6),numel(q8), ...
        'VariableNames',{'Date','Barcode','LI600_N','LI6800_N'})]; %#ok<AGROW>
end

%% CALIBRATION: LI-6800 A = b0 + b1*ETR
model = fitlm(All6800,'A ~ ETR');
beta0 = model.Coefficients.Estimate(1);
beta1 = model.Coefficients.Estimate(2);
ETRmin = min(All6800.ETR); ETRmax = max(All6800.ETR);

calibrationStats = stats(All6800.A,predict(model,All6800));

%% LEAVE-ONE-PLANT-OUT VALIDATION
cvA = nan(height(All6800),1);
for plant = unique(All6800.Plant)'
    test = All6800.Plant==plant;
    fold = fitlm(All6800(~test,:),'A ~ ETR');
    cvA(test)=predict(fold,All6800(test,:));
end
cvStats = stats(All6800.A,cvA);

%% APPLY MODEL TO LI-600 ONLY INSIDE CALIBRATION RANGE
for i=1:height(M)
    keep=R(i).ETR600>=ETRmin & R(i).ETR600<=ETRmax;
    q=R(i).Q600(keep); e=R(i).ETR600(keep);
    pred=beta0+beta1*e;
    R(i).PredictedA600=pred;
    R(i).A600Bin=binData(q,pred,parEdges);
    R(i).A6800Bin=binData(R(i).Q6800,R(i).A6800,parEdges);
end

%% COMMON-BIN AGREEMENT
allPhi6=[]; allPhi8=[]; phiPlant=[];
allA8=[]; allA6=[]; aPlant=[];
PhiPlantStats=table; APlantStats=table;

for i=1:height(M)

    [x,y,~]=commonBins(R(i).Phi600Bin,R(i).Phi6800Bin);
    s=stats(x,y);
    allPhi6=[allPhi6;x]; allPhi8=[allPhi8;y];
    phiPlant=[phiPlant;repmat(i,numel(x),1)];
    PhiPlantStats=[PhiPlantStats;table(M.Barcode(i),numel(x),s.R2,s.Slope,s.RMSE,s.MAE,s.Bias, ...
        'VariableNames',{'Barcode','CommonBins','R2','Slope','RMSE','MAE','Bias'})]; %#ok<AGROW>

    [pred,meas,~]=commonBins(R(i).A600Bin,R(i).A6800Bin);
    s=stats(meas,pred);
    allA8=[allA8;meas]; allA6=[allA6;pred];
    aPlant=[aPlant;repmat(i,numel(meas),1)];
    APlantStats=[APlantStats;table(M.Barcode(i),numel(meas),s.R2,s.Slope,s.RMSE,s.MAE,s.Bias, ...
        'VariableNames',{'Barcode','CommonBins','R2','Slope','RMSE','MAE','Bias'})]; %#ok<AGROW>
end

phiStats=stats(allPhi6,allPhi8);
aStats=stats(allA8,allA6);
residualA=allA6-allA8;

%% SAVE
AnalysisSummary=table( ...
    ["PhiPSII common bins";"LI-6800 calibration";"Leave-one-plant-out";"Assimilation common bins"], ...
    [phiStats.N;calibrationStats.N;cvStats.N;aStats.N], ...
    [phiStats.R2;calibrationStats.R2;cvStats.R2;aStats.R2], ...
    [phiStats.Slope;calibrationStats.Slope;cvStats.Slope;aStats.Slope], ...
    [phiStats.RMSE;calibrationStats.RMSE;cvStats.RMSE;aStats.RMSE], ...
    [phiStats.MAE;calibrationStats.MAE;cvStats.MAE;aStats.MAE], ...
    [phiStats.Bias;calibrationStats.Bias;cvStats.Bias;aStats.Bias], ...
    'VariableNames',{'Analysis','N','R2','Slope','RMSE','MAE','Bias'});

writetable(DataSummary,fullfile(outDir,'Data_Summary.csv'));
writetable(AnalysisSummary,fullfile(outDir,'Analysis_Summary.csv'));
writetable(PhiPlantStats,fullfile(outDir,'PhiPSII_Plant_Statistics.csv'));
writetable(APlantStats,fullfile(outDir,'Assimilation_Plant_Statistics.csv'));

save(fullfile(outDir,'Analysis_Data.mat'), ...
    'M','R','All6800','DataSummary','AnalysisSummary', ...
    'allPhi6','allPhi8','phiPlant','allA8','allA6','aPlant','residualA', ...
    'phiStats','aStats','calibrationStats','cvStats','cvA', ...
    'beta0','beta1','ETRmin','ETRmax','parEdges','outDir');

fprintf('\n============================================================\n');
fprintf(' ANALYSIS COMPLETE\n');
fprintf('============================================================\n');
disp(DataSummary);
fprintf('Calibration: A = %.4f + %.4f ETR\n',beta0,beta1);
fprintf('Calibration R2 = %.3f; RMSE = %.3f\n',calibrationStats.R2,calibrationStats.RMSE);
fprintf('LOPOCV R2 = %.3f; RMSE = %.3f; bias = %.3f\n',cvStats.R2,cvStats.RMSE,cvStats.Bias);
fprintf('PhiPSII bins = %d; R2 = %.3f; RMSE = %.3f\n',phiStats.N,phiStats.R2,phiStats.RMSE);
fprintf('Assimilation bins = %d; R2 = %.3f; RMSE = %.3f; bias = %.3f\n', ...
    aStats.N,aStats.R2,aStats.RMSE,aStats.Bias);
fprintf('Saved: %s\n',fullfile(outDir,'Analysis_Data.mat'));
fprintf('Next run: PHOTOSYNTHETICA_02_FIGURES\n');

%% FUNCTIONS
function name=findVar(T,exact,keys)
names=string(T.Properties.VariableNames); n=normName(names); name="";
for x=exact(:)'
    k=find(n==normName(x),1); if ~isempty(k), name=names(k); return; end
end
for x=keys(:)'
    k=find(contains(n,normName(x)),1); if ~isempty(k), name=names(k); return; end
end
end

function x=normName(x)
x=lower(regexprep(strtrim(string(x)),'[^a-zA-Z0-9]',''));
end

function x=cleanBarcode(x)
x=upper(strtrim(string(x))); x=replace(x,["_"," "],"-");
x=regexprep(x,'-+','-'); x=regexprep(x,'^PLT','PL');
x=regexprep(x,'-P0+(\d+)','-P$1');
end

function x=num(x)
if isnumeric(x), x=double(x(:));
else, x=str2double(replace(strtrim(string(x)),",","")); x=x(:); end
end

function d=parseDate(x)
if isdatetime(x), d=x; return; end
if isnumeric(x), d=datetime(double(x(:)),'ConvertFrom','excel'); return; end
x=string(x); d=NaT(size(x));
formats=["MM/dd/yyyy","M/d/yyyy","yyyy-MM-dd","MM/dd/yyyy HH:mm:ss"];
for f=formats'
    k=isnat(d)&~ismissing(x);
    try, d(k)=datetime(x(k),'InputFormat',f); catch, end
end
end

function B=binData(x,y,edges)
x=x(:); y=y(:); ok=isfinite(x)&isfinite(y); x=x(ok); y=y(ok);
bin=discretize(x,edges); nb=numel(edges)-1;
id=(1:nb)'; PAR=nan(nb,1); Mean=nan(nb,1); SE=nan(nb,1); N=zeros(nb,1);
for b=1:nb
    k=bin==b; N(b)=sum(k);
    if N(b)>0
        PAR(b)=mean(x(k)); Mean(b)=mean(y(k));
        if N(b)>1, SE(b)=std(y(k))/sqrt(N(b)); else, SE(b)=0; end
    end
end
k=N>0; B=table(id(k),PAR(k),Mean(k),SE(k),N(k), ...
    'VariableNames',{'BinID','PAR','Mean','SE','N'});
end

function [x,y,p]=commonBins(A,B)
x=[]; y=[]; p=[]; if isempty(A)||isempty(B), return; end
[~,ia,ib]=intersect(A.BinID,B.BinID,'stable');
x=A.Mean(ia); y=B.Mean(ib); p=mean([A.PAR(ia),B.PAR(ib)],2,'omitnan');
k=isfinite(x)&isfinite(y)&isfinite(p); x=x(k); y=y(k); p=p(k);
end

function S=stats(obs,pred)
obs=obs(:); pred=pred(:); k=isfinite(obs)&isfinite(pred); obs=obs(k); pred=pred(k);
S=struct('N',numel(obs),'R2',NaN,'Intercept',NaN,'Slope',NaN,'RMSE',NaN,'MAE',NaN,'Bias',NaN);
if numel(obs)<2, return; end
r=pred-obs; m=fitlm(obs,pred);
S.R2=m.Rsquared.Ordinary; S.Intercept=m.Coefficients.Estimate(1);
S.Slope=m.Coefficients.Estimate(2); S.RMSE=sqrt(mean(r.^2));
S.MAE=mean(abs(r)); S.Bias=mean(r);
end

function T=read6800(file,sh)
raw=readcell(file,'Sheet',sh,'TextType','string'); S=string(raw); hr=NaN;
for r=1:min(30,size(S,1))
    z=lower(strtrim(S(r,:)));
    if any(contains(z,"qin")) && any(contains(z,"phips")) && any(strcmpi(z,"etr"))
        hr=r; break;
    end
end
if isnan(hr), error('Header not found in %s.',sh); end
g=strtrim(S(hr-1,:)); v=strtrim(S(hr,:)); names=strings(1,size(S,2)); last="";
for c=1:size(S,2)
    if ismissing(g(c)), g(c)=""; end
    if ismissing(v(c)), v(c)=""; end
    if g(c)~="", last=g(c); else, g(c)=last; end
    if g(c)~=""&&v(c)~="", names(c)=g(c)+"_"+v(c);
    elseif v(c)~="", names(c)=v(c); else, names(c)="Var"+c; end
end
names=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(names));
data=raw(hr+1:end,:); empty=all(ismissing(string(data))|strlength(strtrim(string(data)))==0,2);
data=data(~empty,:); data=data(:,1:numel(names));
T=cell2table(data,'VariableNames',cellstr(names));
end

function T=readAllSheets(file)
S=string(sheetnames(file)); T=table;
for i=1:numel(S)
    X=readtable(file,'Sheet',S(i),'VariableNamingRule','preserve','TextType','string');
    if isempty(T), T=X; else, [T,X]=align(T,X); T=[T;X]; end %#ok<AGROW>
end
end

function [A,B]=align(A,B)
names=unique([string(A.Properties.VariableNames),string(B.Properties.VariableNames)],'stable');
for n=names
    if ~ismember(n,string(A.Properties.VariableNames)), A.(n)=repmat(missing,height(A),1); end
    if ~ismember(n,string(B.Properties.VariableNames)), B.(n)=repmat(missing,height(B),1); end
end
A=A(:,cellstr(names)); B=B(:,cellstr(names));
end
