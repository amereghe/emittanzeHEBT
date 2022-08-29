% {}~

%% include libraries
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - include Matlab libraries
pathToLibrary="externals\ExternalMatLabTools";
addpath(genpath(pathToLibrary));
% - include local library with functions
pathToLibrary="lib";
addpath(genpath(pathToLibrary));

%% main - user infos
measPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY";
LPOWmonPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY\LPOW_error_log";
% LPOWmonPath="S:\Accelerating-System\Accelerator-data\Area dati MD\LPOWmonitor\ErrorLog";
% fracEst=[ 0.875 0.75 0.625 0.5 0.375 0.25 ]; % initial
% fracEst=[ 0.875 0.8125 0.75 0.6875 0.625 0.5625 0.5 0.4375 0.375 0.3125 0.25 ]; % very detailed
fracEst=[ 0.85 0.75 0.65 0.55 0.45 0.35 0.25 ]; % 
fracEstStrings=compose("frac=%g%%",fracEst*100);

mons=["CAM" "DDS"]; nMons=length(mons);
planes=["HOR" "VER"];

allLGENs=["P9-003A-LGEN" "P9-004A-LGEN" "P9-005A-LGEN" "P9-006A-LGEN" "P9-007A-LGEN" "P9-008A-LGEN" ];

LPOWlogFiles=[
    "2022-03-13\*.txt"
    ];

iCurr2mon=[-2 -1]; % 1=CAM, 2=DDS; iCAM=iCurr+iCurr2mon(1); iDDS=iCurr+iCurr2mon(2);

beamPart="CARBON";
machine="LineU";
config="TM"; % select configuration: TM, RFKO

scanSetUps=[
    "2022-03-13\SetMeUp_U1p008ApQUE_C270_secondoGiro.m"
    "2022-03-13\SetMeUp_U1p014ApQUE_C270_secondoGiro.m"
    "2022-03-13\SetMeUp_U1p018ApQUE_C270_secondoGiro.m"
    "2022-03-13\SetMeUp_U2p006ApQUE_C270_secondoGiro.m"
    "2022-03-13\SetMeUp_U2p010ApQUE_C270_secondoGiro.m"
    "2022-03-13\SetMeUp_U2p016ApQUE_C270_secondoGiro.m"
    ];
% - scan infos
nScanSetUps=length(scanSetUps);
iMinScanSetUps=1; iMaxScanSetUps=nScanSetUps; % iMinScanSetUps=1; iMaxScanSetUps=1;

% - processing
lAnalyseOnly=false;

%% main - load infos
% - indices in measurements (CAM/DDS summary files):
%   . 1st col: 1=current, 2=CAM, 3=DDS;
%   . 2nd col: min,max;
indices=NaN(3,2,nScanSetUps);
% - indices of measurements to be fitted (CAM/DDS summary files):
%   . 1st col: 1=CAM, 2=DDS;
%   . 2nd col: min,max;
%   . 3rd col: hor,ver;
%   . 4th col: fit ranges;
fitIndices=NaN(2,2,2,1,nScanSetUps);
% - largest fit range
iLargestFitRange=zeros(2,nScanSetUps); largestFitRange=zeros(2,nScanSetUps);
% - how many fit ranges
nFitRanges=NaN(2,nScanSetUps);
% - load measuerement infos
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    run(scanSetUps(iScanSetUps));
    run("lib\SetUpWorkSpace.m");
end
nMaxFitSets=size(fitIndices,4);
% - LPOW paths
LPOWmonPaths=strings(length(LPOWlogFiles),1);
for ii=1:length(LPOWlogFiles)
    LPOWmonPaths(ii)=sprintf("%s\\%s",LPOWmonPath,LPOWlogFiles(ii));
end

%% main - gatherings
run("2022-03-13\gatherings_secondoGiro_All.m");

%% main - parse data files

% - parse LPOW monitor log
clear tStampsLPOWMon LGENsLPOWMon LPOWsLPOWMon racksLPOWMon repoValsLPOWMon appValsLPOWMon cyCodesLPOWMon cyProgsLPOWMon endCycsLPOWMon;
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWmonPaths);
% - cyProgs of LPOWmon are off!!!!
if ( ~ismissing(LGENsLPOWMon) )
    cyProgsLPOWMon=string(str2double(cyProgsLPOWMon)+4097); % 4097=2^12+1;
end

% - get TM currents
clear cyCodesTM rangesTM EksTM BrhosTM currentsTM fieldsTM kicksTM psNamesTM FileNameCurrentsTM ;
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machine,config);
psNamesTM=string(psNamesTM);
cyCodesTM=upper(string(cyCodesTM));

% - parse actual data files
[cyProgsProf,cyCodesProf,profiles,nDataProf,BARsProf,FWHMsProf,INTsProf]=deal(missing(),missing(),missing(),missing(),missing(),missing(),missing());
[cyProgsSumm,cyCodesSumm,BARsSumm,FWHMsSumm,ASYMsSumm,INTsSumm,nDataSumm]=deal(missing(),missing(),missing(),missing(),missing(),missing(),missing());
INTsMapped=missing();
[IsXLS,LGENnamesXLS,nDataCurr]=deal(missing(),missing(),missing());
tableIs=missing();
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    % - parse beam profiles
    [tmpCyProgsProf,tmpCyCodesProf,tmpProfiles,tmpNDataProf]=AcquireDistributions(CAMProfsPaths(:,iScanSetUps),DDSProfsPaths(:,iScanSetUps));
    %   compute statistics on profiles
    [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=ComputeDistStats(tmpProfiles);
    % - parse summary files
    [tmpCyProgsSumm,tmpCyCodesSumm,tmpBARsSumm,tmpFWHMsSumm,tmpASYMsSumm,tmpINTsSumm,tmpNDataSumm]=AcquireSummaryData(actCAMPaths(:,iScanSetUps),actDDSPaths(:,iScanSetUps));
    % - map cyProgs from summary and from profiles (used for fitting)
    tmpINTsMapped=MapMe(tmpINTsProf,tmpINTsSumm,tmpCyProgsProf,tmpCyProgsSumm);
    % - parse current files
    [tmpIsXLS,tmpLGENnamesXLS,tmpNDataCurr]=AcquireCurrentData(currPath(iScanSetUps));
    % - build table of currents
    [tmpTableIs]=BuildCurrentTable(tmpCyCodesProf,tmpCyProgsProf,allLGENs,tmpIsXLS(:,tmpLGENnamesXLS==LGENscanned(iScanSetUps)),LGENscanned(iScanSetUps),psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices(:,:,iScanSetUps));
    % - store data:
    %   . profiles:
    cyProgsProf=ExpandMat(cyProgsProf,tmpCyProgsProf); clear tmpCyProgsProf;
    cyCodesProf=ExpandMat(cyCodesProf,tmpCyCodesProf); clear tmpCyCodesProf;
    profiles=ExpandMat(profiles,tmpProfiles); clear tmpProfiles;
    nDataProf=ExpandMat(nDataProf,tmpNDataProf); clear tmpNDataProf ;
    BARsProf=ExpandMat(BARsProf,tmpBARsProf); clear tmpBARsProf;
    FWHMsProf=ExpandMat(FWHMsProf,tmpFWHMsProf); clear tmpFWHMsProf;
    INTsProf=ExpandMat(INTsProf,tmpINTsProf); clear tmpINTsProf;
    %   . summary files
    cyProgsSumm=ExpandMat(cyProgsSumm,tmpCyProgsSumm); clear tmpCyProgsSumm;
    cyCodesSumm=ExpandMat(cyCodesSumm,tmpCyCodesSumm); clear tmpCyCodesSumm;
    BARsSumm=ExpandMat(BARsSumm,tmpBARsSumm); clear tmpBARsSumm;
    FWHMsSumm=ExpandMat(FWHMsSumm,tmpFWHMsSumm); clear tmpFWHMsSumm;
    ASYMsSumm=ExpandMat(ASYMsSumm,tmpASYMsSumm); clear tmpASYMsSumm;
    INTsSumm=ExpandMat(INTsSumm,tmpINTsSumm); clear tmpINTsSumm;
    nDataSumm=ExpandMat(nDataSumm,tmpNDataSumm); clear tmpNDataSumm;
    %   . integrals
    INTsMapped=ExpandMat(INTsMapped,tmpINTsMapped); clear tmpINTsMapped;
    %   . currents
    IsXLS=ExpandMat(IsXLS,tmpIsXLS); clear tmpIsXLS;
    LGENnamesXLS=ExpandMat(LGENnamesXLS,tmpLGENnamesXLS); clear tmpLGENnamesXLS;
    nDataCurr=ExpandMat(nDataCurr,tmpNDataCurr); clear tmpNDataCurr;
    tableIs=ExpandMat(tableIs,tmpTableIs); clear tmpTableIs;
end
fprintf("...end of data parsing;\n");

%% main - cross checks
if ( ~lAnalyseOnly )
    for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    % for iScanSetUps=2:2
        % - raw plots (ie CAM/DDS: FWHM, bar and integral vs ID; scanned quad: I vs ID), to get indices
        % ShowScanRawPlots(IsXLS(1:nDataCurr(iScanSetUps),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),INTsSumm(:,:,:,iScanSetUps),nDataSumm(:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"]);
        % ShowScanRawPlots(IsXLS(1:nDataCurr(iScanSetUps),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),INTsProf(:,:,:,iScanSetUps),nDataProf(:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        % ShowScanRawPlots(IsXLS(1:nDataCurr(iScanSetUps),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),INTsSumm(:,:,:,iScanSetUps),nDataSumm(:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"]);
        ShowScanRawPlots(IsXLS(1:nDataCurr(iScanSetUps),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),INTsProf(:,:,:,iScanSetUps),nDataProf(:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        % - compare data from summary files and statistics computed on profiles
        CompareProfilesSummary(BARsProf(:,:,:,iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),INTsProf(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),FWHMsSumm(:,:,:,iScanSetUps),INTsSumm(:,:,:,iScanSetUps),cyProgsProf(:,:,iScanSetUps),cyProgsSumm(:,:,iScanSetUps),outName(iScanSetUps));
        % - compare currents: LPOW error log vs xls and TM values
        if ( ~ismissing(LGENsLPOWMon) )
            CompareCurrents(IsXLS(:,:,iScanSetUps),indices(:,:,iScanSetUps),LGENscanned(iScanSetUps),appValsLPOWMon,LGENsLPOWMon,allLGENs,tableIs(:,:,:,iScanSetUps),cyProgsSumm(:,:,iScanSetUps),cyProgsLPOWMon); % indices are based on summary data
        end
        myCurr2mon=GetMyCurr2mon(iCurr2mon,indices(:,1,iScanSetUps));
        % - plot distributions (3D visualisation)
        myOutName=sprintf("%s_3D_aligned.fig",outName(iScanSetUps)); myRemark="aligned distributions";
        [indicesMon,indicesCur]=GenIndices(indices(2:3,:,iScanSetUps),myCurr2mon);
        ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
        clear indicesMon indicesCur;
        myOutName=sprintf("%s_3D_allIDs.fig",outName(iScanSetUps)); myRemark="all distributions";
        ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark);
        % for iFitSet=1:nFitSets
        %     myOutName=sprintf("%s_3D_fitDistributions_%02d.fig",outName(iScanSetUps),iFitSet); myRemark=sprintf("distributions to be fitted (set # %2i)",iFitSet);
        %     ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),fitIndices(:,:,:,iFitSet,iScanSetUps));
        % end
        if ( iLargestFitRange(1,iScanSetUps)==iLargestFitRange(2,iScanSetUps) )
            [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(1,iScanSetUps),iScanSetUps),myCurr2mon);
            myOutName=sprintf("%s_3D_fitDistributions_largestFitRange.fig",outName(iScanSetUps)); myRemark=sprintf("distributions to be fitted (largest set: # %2i)",iLargestFitRange(1,iScanSetUps));
            ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
            clear indicesMon indicesCur;
        else
            for iPlane=1:2
                [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(iPlane,iScanSetUps),iScanSetUps),myCurr2mon);
                myOutName=sprintf("%s_3D_fitDistributions_largestFitRange_%s.fig",outName(iScanSetUps),planes(iPlane)); myRemark=sprintf("distributions to be fitted (largest set on %s plane: # %2i)",planes(iPlane),iLargestFitRange(iPlane,iScanSetUps));
                ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
                clear indicesMon indicesCur;
            end
            clear iPlane;
        end
    end
end
fprintf("...end of cross checks;\n");

%% main - actual analysis
[BARsProfScan,FWHMsProfScan,INTsProfScan]=deal(missing(),missing(),missing());
ReducedFWxM=missing();
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    % - compute statistics on profiles at different heights
    [tmpBARsProfScan,tmpFWHMsProfScan,tmpINTsProfScan]=ComputeDistStats(profiles(:,:,:,:,iScanSetUps),fracEst);
    % - reduced values for FWxMs:
    [tmpReducedFWxM]=GetReducedFWxM(tmpFWHMsProfScan,fracEst);
    % - store data:
    %   . profiles:
    BARsProfScan=ExpandMat(BARsProfScan,tmpBARsProfScan); clear tmpBARsProfScan;
    FWHMsProfScan=ExpandMat(FWHMsProfScan,tmpFWHMsProfScan); clear tmpFWHMsProfScan;
    INTsProfScan=ExpandMat(INTsProfScan,tmpINTsProfScan); clear tmpINTsProfScan;
    ReducedFWxM=ExpandMat(ReducedFWxM,tmpReducedFWxM); clear tmpReducedFWxM;
end
if ( ~lAnalyseOnly )
    for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    % for iScanSetUps=2:2
        % - actual plots (FWHM and baricentre vs Iscan (actual range), CAMeretta and DDS)
        % ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        % ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"]);
        % - export data to xlsx files
        myCurr2mon=GetMyCurr2mon(iCurr2mon,indices(:,1,iScanSetUps));
        [indicesMon,indicesCur]=GenIndices(indices(2:3,:,iScanSetUps),myCurr2mon);
        % myOutName=sprintf("%s_SummaryData.xlsx",outName(iScanSetUps)); ExportDataOverview(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),INTsSumm(:,:,:,iScanSetUps),nDataSumm(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        myOutName=sprintf("%s_ProfStatsData.xlsx",outName(iScanSetUps)); ExportDataOverview(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),INTsProf(:,:,:,iScanSetUps),nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        clear indicesMon indicesCur;
        % - show statistics on profiles at different heights
        FWxMPlots(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProfScan(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),ReducedFWxM(:,:,:,:,iScanSetUps),fracEst,indices(:,:,iScanSetUps),scanDescription(iScanSetUps),outName(iScanSetUps));
        % - export data to xlsx files
        %   NB: integrals are from the summary files, whereas the other quantities come from the analysis on the profiles...
        % for iFitSet=1:nFitSets
        %     [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iFitSet,iScanSetUps),myCurr2mon);
        %     myOutName=sprintf("%s_FWxM_%02d.xlsx",outName(iScanSetUps),iFitSet); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsProfScan(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        %     myOutName=sprintf("%s_SIGxM_%02d.xlsx",outName(iScanSetUps),iFitSet); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,ReducedFWxM(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
        %     clear indicesMon indicesCur;
        % end
        if ( iLargestFitRange(1,iScanSetUps)==iLargestFitRange(2,iScanSetUps) )
            [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(1,iScanSetUps),iScanSetUps),myCurr2mon);
            myOutName=sprintf("%s_FWxM_largestFitRange.xlsx",outName(iScanSetUps)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsProfScan(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
            myOutName=sprintf("%s_SIGxM_largestFitRange.xlsx",outName(iScanSetUps)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,ReducedFWxM(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
            clear indicesMon indicesCur;
        else
            for iPlane=1:2
                [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(iPlane,iScanSetUps),iScanSetUps),myCurr2mon);
                myOutName=sprintf("%s_FWxM_largestFitRange_%s.xlsx",outName(iScanSetUps),planes(iPlane)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsProfScan(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
                myOutName=sprintf("%s_SIGxM_largestFitRange_%s.xlsx",outName(iScanSetUps),planes(iPlane)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,ReducedFWxM(:,:,:,:,iScanSetUps),BARsProfScan(:,:,:,iScanSetUps),INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
                clear indicesMon indicesCur;
            end
            clear iPlane;
        end
    end
end
fprintf("...end of actual analysis;\n");

%% export MADX table, to compute response matrices of scan
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    for iMon=1:nMons
        MADXFileName=sprintf("%s_%s.tfs",outName(iScanSetUps),mons(iMon));
        nCols=size(tableIs(:,:,:,iScanSetUps),2);
        header=allLGENs+" [A]";
        headerTypes=strings(1,nCols);
        headerTypes(:)="%le";
        ExportMADXtable(MADXFileName,scanDescription(iScanSetUps),tableIs(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps),:,iMon,iScanSetUps),header,headerTypes);
    end
    clear iMon;
end
fprintf("...end of exporting to MADX files;\n");

%% read MADX tfs table with response matrices of scan
TM=missing();
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    tmpTM=NaN(3,3,1,length(planes),nMons);
    for iMon=1:nMons
        nMaxFitData=max(fitIndices(iMon,2,:,:,iScanSetUps),[],"all")-min(fitIndices(iMon,1,:,:,iScanSetUps),[],"all")+1;
        reMatFileName=sprintf("externals\\optics\\HEBT\\%s_%s_ReMat.tfs",plotName(iScanSetUps),mons(iMon));
        fprintf('parsing file %s ...\n',reMatFileName);
        rMatrix = readmatrix(reMatFileName,'HeaderLines',1,'Delimiter',',','FileType','text');
        for iPlane=1:length(planes)
            tmpTM(:,:,1:size(rMatrix,1),iPlane,iMon)=GetTransMatrix(rMatrix,planes(iPlane),"SCAN");
        end
        clear rMatrix;
        clear iPlane;
    end
    % store data
    TM=ExpandMat(TM,tmpTM); clear tmpTM;
end
fprintf("...end of reading MADX files;\n");

%% fit data
% sigdpp=0:5E-5:1E-3;
% sigdpp=0:1E-3:1E-3;
sigdpp=[ 0.0 1E-3 ]; sigdppStrings=compose("sigdpp=%g",sigdpp);
labelsType=[ "EMI_RMS" "EMI_HWxM" ];
myYlabels=[ "\sigma [mm]" "HWxM [mm]" ];
clear beta0 alpha0 emiG z pz dz dpz avedpp TT SS;
beta0=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
alpha0=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
emiG=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
z=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
pz=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
dz=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
dpz=NaN(length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
avedpp=NaN(length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
TT=NaN(nMaxFitData,length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
SS=NaN(nMaxFitData,length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    for iMon=1:nMons
        myCurr2mon=GetMyCurr2mon(iCurr2mon,indices(:,1,iScanSetUps));
        for iPlane=1:length(planes)
            for iFitSet=1:nFitRanges(iPlane,iScanSetUps)
                % - range of data set to consider:
                iMinFit=fitIndices(iMon,1,iPlane,iFitSet,iScanSetUps);
                iMaxFit=fitIndices(iMon,2,iPlane,iFitSet,iScanSetUps);
                % - corresponding range in current:
                jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==iMinFit-myCurr2mon(iMon));
                jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==iMaxFit-myCurr2mon(iMon));
                nFit=iMaxFit-iMinFit+1;
                for iFrac=1:length(fracEst)
                    for iType=1:length(labelsType)
                        % - baricentres and sigmas:
                        TT(1:nFit,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)=BARsProfScan(iMinFit:iMaxFit,iPlane,iMon,iScanSetUps);
                        if ( strcmpi(labelsType(iType),"EMI_RMS") )
                            SS(1:nFit,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)=ReducedFWxM(iMinFit:iMaxFit,iPlane,iMon,iFrac,iScanSetUps);
                        elseif ( strcmpi(labelsType(iType),"EMI_HWxM") )
                            SS(1:nFit,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)=FWHMsProfScan(iMinFit:iMaxFit,iPlane,iMon,iFrac,iScanSetUps)/2;
                        end
                        % - perform fit:
                        [beta0(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),alpha0(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),emiG(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),...
                            dz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),~]=FitOpticsThroughSigmaData(TM(:,:,jMinFit:jMaxFit,iPlane,iMon,iScanSetUps),SS(1:nFit,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),sigdpp);
                        [z(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),pz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),avedpp(iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)]=...
                            FitOpticsThroughOrbitData(TM(:,:,jMinFit:jMaxFit,iPlane,iMon,iScanSetUps),TT(1:nFit,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),dz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps));
                    end
                end
            end
        end
    end
end
if ( ~lAnalyseOnly )
    for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
        for iMon=1:nMons
            % for iType=1:2
            %     for iPlane=1:length(planes)
            %         for iFitSet=1:nFitSets
            %             ShowFittedOpticsFunctions(beta0(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),alpha0(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),emiG(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),sigdpp,planes(iPlane),fracEstStrings);
            %             ShowFittedOrbits(z(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),pz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),planes(iPlane),avedpp(:,iPlane,iFitSet,iType,iMon,iScanSetUps),fracEstStrings);
            %         end
            %     end
            % end
            % - show optics
            for iPlane=1:length(planes)
                for iType=1:length(labelsType)
                    for iSigDpp=1:length(sigdppStrings)
                        % permute dimensions: showBeta0(fracEst,nMaxFitSets,length(planes),iSigDpp)
                        clear showBeta0; showBeta0=permute(beta0(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]); 
                        clear showAlpha0; showAlpha0=permute(alpha0(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        clear showEmiG; showEmiG=permute(emiG(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        clear showDz; showDz=permute(dz(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        clear showDpz; showDpz=permute(dpz(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        clear showZ; showZ=permute(z(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        clear showPz; showPz=permute(pz(iSigDpp,:,iPlane,1:nFitRanges(iPlane,iScanSetUps),iType,iMon,iScanSetUps),[2 4 3 1]);
                        myTitle=sprintf("%s - %s - %s plane - %s - %s",scanDescription(iScanSetUps),mons(iMon),planes(iPlane),sigdppStrings(iSigDpp),LabelMe(labelsType(iType)));
                        if ( sigdpp(iSigDpp)==0.0 )
                            myOutName=sprintf("%s_%s_fittedOptics_%s_%s.fig",outName(iScanSetUps),mons(iMon),labelsType(iType),planes(iPlane)); 
                        else
                            myOutName=sprintf("%s_%s_fittedOptics_%s_%s_%s.fig",outName(iScanSetUps),mons(iMon),labelsType(iType),planes(iPlane),sigdppStrings(iSigDpp)); 
                        end
                        ShowFittedOpticsFunctionsGrouped(showBeta0,showAlpha0,showEmiG,showDz,showDpz,showZ,showPz,...
                            1-fracEst,"1-frac []",compose("fit set #%2d",1:nMaxFitSets),myTitle,myOutName);
                    end
                end
            end
            % - show ellypses
            for iType=1:length(labelsType)
                for iSigDpp=1:length(sigdppStrings)
                    % permute dimensions: showBeta0(fracEst,nMaxFitSets,length(planes),iSigDpp)
                    clear showBeta0; showBeta0=permute(beta0(iSigDpp,:,:,:,iType,iMon,iScanSetUps),[2 4 3 1]); 
                    clear showAlpha0; showAlpha0=permute(alpha0(iSigDpp,:,:,:,iType,iMon,iScanSetUps),[2 4 3 1]);
                    clear showEmiG; showEmiG=permute(emiG(iSigDpp,:,:,:,iType,iMon,iScanSetUps),[2 4 3 1]);
                    myTitle=sprintf("%s - %s - %s - %s",scanDescription(iScanSetUps),mons(iMon),sigdppStrings(iSigDpp),LabelMe(labelsType(iType)));
                    if ( sigdpp(iSigDpp)==0.0 )
                        myOutName=sprintf("%s_%s_fittedOptics_%s_ellypses.fig",outName(iScanSetUps),mons(iMon),labelsType(iType)); 
                    else
                        myOutName=sprintf("%s_%s_fittedOptics_%s_ellypses_%s.fig",outName(iScanSetUps),mons(iMon),labelsType(iType),sigdppStrings(iSigDpp)); 
                    end
                    ShowFittedEllipsesGrouped(showBeta0,showAlpha0,showEmiG,nFitRanges(:,iScanSetUps),...
                        planes,compose("fit set #%2d",1:nMaxFitSets),fracEstStrings,myTitle,myOutName);
                end
            end
        end
    end
end
fprintf("...end of fitting;\n");

%% compare fits and measured data
clear gamma0; gamma0=(1+alpha0.^2)./beta0; % same size as alpha0 and beta0
clear calcSigmas; calcSigmas=NaN(nMaxFitData,length(sigdpp),length(fracEst),length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
clear calcBars; calcBars=NaN(nMaxFitData,length(sigdpp),1,length(planes),nMaxFitSets,length(labelsType),nMons,nScanSetUps);
clear scanCurrents; scanCurrents=NaN(nMaxFitData,length(planes),nMaxFitSets,nMons,nScanSetUps);
clear measSigma; measSigma=NaN(nMaxFitData,length(planes),length(fracEst),length(labelsType),nMons,nScanSetUps);
clear measBARs; measBARs=NaN(nMaxFitData,length(planes),nMons,nScanSetUps);
clear measCurr; measCurr=NaN(nMaxFitData,length(planes),nMons,nScanSetUps);
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    for iMon=1:nMons
        myCurr2mon=GetMyCurr2mon(iCurr2mon,indices(:,1,iScanSetUps));
        for iPlane=1:length(planes)
            % - transport optics
            for iFitSet=1:nFitRanges(iPlane,iScanSetUps)
                % - range of data set to consider:
                jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==fitIndices(iMon,1,iPlane,iFitSet,iScanSetUps)-myCurr2mon(iMon));
                jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==fitIndices(iMon,2,iPlane,iFitSet,iScanSetUps)-myCurr2mon(iMon));
                nFit=jMaxFit-jMinFit+1;
                for iFrac=1:length(fracEst)
                    for iType=1:length(labelsType)
                        % - actually transport optics
                        clear betaO alphaO gammaO;
                        [betaO,alphaO,gammaO]=TransportOptics(TM(1:2,1:2,jMinFit:jMaxFit,iPlane,iMon,iScanSetUps),...
                            beta0(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),alpha0(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),gamma0(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps));
                        clear dO dpO;
                        [dO,dpO]=TransportOrbit(TM(1:2,1:2,jMinFit:jMaxFit,iPlane,iMon,iScanSetUps),dz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps));
                        % - fix NaNs
                        dO(isnan(dO))=0.0; dpO(isnan(dpO))=0.0; 
                        % - compute sigmas
                        calcSigmas(1:nFit,:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)=sqrt(betaO.*repmat(emiG(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps)',size(betaO,1),1)+...
                            (dO.*repmat(sigdpp,size(dO,1),1)).^2);
                        % - transport baricentre (for the time being, independent of fractEst)
                        if ( iFrac==1 )
                            [calcBars(1:nFit,:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),~]=TransportOrbit(TM(1:2,1:2,jMinFit:jMaxFit,iPlane,iMon,iScanSetUps),...
                                z(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps),pz(:,iFrac,iPlane,iFitSet,iType,iMon,iScanSetUps));
                        end
                    end
                end
                % - keep track of currents
                myMapCurr=indices(1,1,iScanSetUps):indices(1,2,iScanSetUps);
                scanCurrents(1:nFit,iPlane,iFitSet,iMon,iScanSetUps)=tableIs(myMapCurr(jMinFit:jMaxFit),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iMon,iScanSetUps);
            end
            % - set of measurements for fit:
            %   range of data set to consider:
            iMinFit=min(fitIndices(iMon,1,iPlane,:,iScanSetUps));
            iMaxFit=max(fitIndices(iMon,2,iPlane,:,iScanSetUps));
            %   corresponding range in current:
            jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==min(fitIndices(iMon,1,iPlane,:,iScanSetUps)-myCurr2mon(iMon)));
            jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==max(fitIndices(iMon,2,iPlane,:,iScanSetUps)-myCurr2mon(iMon)));
            nFit=iMaxFit-iMinFit+1;
            for iType=1:length(labelsType)
                if ( strcmpi(labelsType(iType),"EMI_RMS") )
                    measSigma(1:nFit,iPlane,1:length(fracEst),iType,iMon,iScanSetUps)=reshape(ReducedFWxM(iMinFit:iMaxFit,iPlane,iMon,:,iScanSetUps),nFit,1,length(fracEst));
                elseif ( strcmpi(labelsType(iType),"EMI_HWxM") )
                    measSigma(1:nFit,iPlane,1:length(fracEst),iType,iMon,iScanSetUps)=reshape(FWHMsProfScan(iMinFit:iMaxFit,iPlane,iMon,:,iScanSetUps)/2,nFit,1,length(fracEst));
                end
            end
            measBARs(1:nFit,iPlane,iMon,iScanSetUps)=BARsProfScan(iMinFit:iMaxFit,iPlane,iMon,iScanSetUps);
            myMapCurr=indices(1,1,iScanSetUps):indices(1,2,iScanSetUps);
            measCurr(1:nFit,iPlane,iMon,iScanSetUps)=tableIs(myMapCurr(jMinFit:jMaxFit),LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iMon,iScanSetUps);
        end
        if ( ~lAnalyseOnly )
            % - compare SIGs
            for iType=1:length(labelsType)
                for iSigDpp=1:length(sigdppStrings)
                    % permute dimensions:
                    clear showCalcSigma; showCalcSigma=permute(calcSigmas(:,iSigDpp,:,:,:,iType,iMon,iScanSetUps),[1 4 5 3 2]); % showCalcSigma(nMaxFitData,length(planes),nMaxFitSets,fracEst,iSigDpp)
                    clear showScanCurrents; showScanCurrents=scanCurrents(:,:,:,iMon,iScanSetUps); % showScanCurrents(nMaxFitData,length(planes),nMaxFitSets)
                    clear showMeasSigma; showMeasSigma=measSigma(:,:,:,iType,iMon,iScanSetUps); % showMeasSigma(nMaxFitData,length(planes),fracEst)
                    clear showMeasCurr; showMeasCurr=measCurr(:,:,iMon,iScanSetUps); % showMeasCurr(nMaxFitData,length(planes))
                    myTitle=sprintf("%s - %s - %s - %s",scanDescription(iScanSetUps),mons(iMon),sigdppStrings(iSigDpp),LabelMe(labelsType(iType)));
                    if ( sigdpp(iSigDpp)==0.0 )
                        myOutName=sprintf("%s_%s_fittedOptics_%s_compareFitsSIGs.fig",outName(iScanSetUps),mons(iMon),labelsType(iType)); 
                    else
                        myOutName=sprintf("%s_%s_fittedOptics_%s_compareFitsSIGs_%s.fig",outName(iScanSetUps),mons(iMon),labelsType(iType),sigdppStrings(iSigDpp)); 
                    end
                    CompareFits(showCalcSigma,showScanCurrents,showMeasSigma,showMeasCurr,"SIG",sprintf("I_{%s} [A]",LGENscanned(iScanSetUps)),myYlabels(iType),...
                        fracEstStrings,planes,compose("fit set #%2d",1:nMaxFitSets),myTitle,mons(iMon),nFitRanges(:,iScanSetUps),myOutName);
                end
            end
            % - compare BARs
            for iType=1:length(labelsType)
                for iSigDpp=1:length(sigdppStrings)
                    % permute dimensions:
                    clear showCalcBars; showCalcBars=permute(calcBars(:,iSigDpp,1,:,:,iType,iMon,iScanSetUps),[1 4 5 3 2]); % showCalcBars(nMaxFitData,length(planes),nMaxFitSets,1,iSigDpp)
                    clear showScanCurrents; showScanCurrents=scanCurrents(:,:,:,iMon,iScanSetUps); % showScanCurrents(nMaxFitData,length(planes),nMaxFitSets)
                    clear showMeasBars; showMeasBars=measBARs(:,:,iMon,iScanSetUps); % showMeasBars(nMaxFitData,length(planes))
                    clear showMeasCurr; showMeasCurr=measCurr(:,:,iMon,iScanSetUps); % showMeasCurr(nMaxFitData,length(planes))
                    myTitle=sprintf("%s - %s - %s - %s",scanDescription(iScanSetUps),mons(iMon),sigdppStrings(iSigDpp),LabelMe(labelsType(iType)));
                    if ( sigdpp(iSigDpp)==0.0 )
                        myOutName=sprintf("%s_%s_fittedOptics_%s_compareFitsBARs.fig",outName(iScanSetUps),mons(iMon),labelsType(iType)); 
                    else
                        myOutName=sprintf("%s_%s_fittedOptics_%s_compareFitsBARs_%s.fig",outName(iScanSetUps),mons(iMon),labelsType(iType),sigdppStrings(iSigDpp)); 
                    end
                    CompareFits(showCalcBars,showScanCurrents,showMeasBars,showMeasCurr,"BAR",sprintf("I_{%s} [A]",LGENscanned(iScanSetUps)),"BAR [mm]",...
                        "all fractions",planes,compose("fit set #%2d",1:nMaxFitSets),myTitle,mons(iMon),nFitRanges(:,iScanSetUps),myOutName);
                end
            end
        end
    end
end
fprintf("...end of comparing fit results and measurements;\n");

%% superimpose plots
iSigDpp=find(sigdpp==0); iPlane=find(strcmpi(planes,"HOR")); iType=find(strcmpi(labelsType,"EMI_HWxM")); iMon=find(strcmpi(mons,"CAM"));
% re-map data: (fractEst,(iScanSetUps-1)*nMaxFitSets+iFitSet)
clear showBeta0; showBeta0=reshape(beta0(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showAlpha0; showAlpha0=reshape(alpha0(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showEmiG; showEmiG=reshape(emiG(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showDz; showDz=reshape(dz(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showDpz; showDpz=reshape(dpz(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showZ; showZ=reshape(z(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
clear showPz; showPz=reshape(pz(iSigDpp,:,iPlane,:,iType,iMon,:),length(fracEst),nMaxFitSets*nScanSetUps);
myTitle=sprintf("%s - %s - %s plane - %s - %s","all scans/fits",mons(iMon),planes(iPlane),sigdppStrings(iSigDpp),LabelMe(labelsType(iType)));
myLegends=strings(nMaxFitSets*nScanSetUps,1);
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    myLegends((iScanSetUps-1)*nMaxFitSets+1:(iScanSetUps-1)*nMaxFitSets+nMaxFitSets)=scanDescription(iScanSetUps)+compose("fit set #%2d",1:nMaxFitSets);
end
ShowFittedOpticsFunctionsGrouped(showBeta0,showAlpha0,showEmiG,showDz,showDpz,showZ,showPz,...
    1-fracEst,"1-frac []",myLegends,myTitle);%,myOutName);
% figure();
% plot(fracEst,showEmiG(:,:),".-");
fprintf("...end of comparisons-1;\n");

%% superimpose plots - take 2
iSigDpp=find(sigdpp==0); iType=find(strcmpi(labelsType,"EMI_RMS")); % iPlane=strcmpi(planes,"HOR");
% whats=[ "\beta" "\alpha" "\epsilon" ];
% whatsFigure=[ "BETA" "ALPHA" "EPSILON" ];
% whatDims=[ "[m]" "[]" "[\mum]" ];
whats=[ "\epsilon" ];
whatDims=[ "[\mum]" ];
whatsFigure=[ "EPSILON" ];
for iPlane=1:length(planes)
    for iWhat=1:length(whats)
        myTitle=sprintf("compare %s - %s plane - %s - %s",whats(iWhat),planes(iPlane),LabelMe(labelsType(iType)),sigdppStrings(iSigDpp));
        clear showMe;
        switch upper(whats(iWhat))
            case "\BETA"
                showMe=permute(beta0(iSigDpp,:,iPlane,:,iType,:,:),[2 4 6 7 1 3 5]);
            case "\ALPHA"
                showMe=permute(alpha0(iSigDpp,:,iPlane,:,iType,:,:),[2 4 6 7 1 3 5]);
            case "\EPSILON"
                showMe=permute(emiG(iSigDpp,:,iPlane,:,iType,:,:)*1E6,[2 4 6 7 1 3 5]);
            otherwise
                error("Wrong what! %s",whats(iWhat));
        end
        if ( sigdpp(iSigDpp)==0.0 )
            myOutName=sprintf("%s_fittedOptics_%s_compare_%s_%s.fig",outNameCompare,labelsType(iType),whatsFigure(iWhat),planes(iPlane)); 
        else
            myOutName=sprintf("%s_fittedOptics_%s_compare_%s_%s_%s.fig",outNameCompare,labelsType(iType),whatsFigure(iWhat),planes(iPlane),sigdppStrings(iSigDpp)); 
        end
        % CompareFittedOptics(1-fracEst',showMe,"1-frac []",whatDims(iWhat),mons,scanDescription,compose("fit set #%2d",1:nMaxFitSets),myTitle,myOutName,lKeepFrac,lKeepFits);
        CompareFittedOptics(1-fracEst',showMe,"1-frac []",whatDims(iWhat),mons,scanDescription,compose("fit set #%2d",1:nMaxFitSets),myTitle,myOutName);
    end
end
fprintf("...end of comparisons-2;\n");
        
%%
iFrac=4; iPlane=1;
% myAlpha0=(-10:0.5:10)'; myBeta0=50*ones(length(myAlpha0),1);
myBeta0=(31:5:91)'; myAlpha0=-9*ones(length(myBeta0),1);
myEmig=0.15E-6; myGamma0=(1+myAlpha0.^2)./myBeta0; 
[myBetaO,myAlphaO,myGammaO]=TransportOptics(TM(1:2,1:2,:,iPlane),myBeta0,myAlpha0,myGamma0);
myCalcSigma=sqrt(myBetaO.*myEmig);
% CompareFits(myCalcSigma,SS(:,iFrac,iPlane),compose("\\alpha=%g",myAlpha0),fracEstStrings,planes(iPlane),scanCurrents,sprintf("I_{%s} [A]",LGENscanned));
CompareFits(myCalcSigma,SS(:,iFrac,iPlane),compose("\\beta=%g",myBeta0),fracEstStrings,planes(iPlane),scanCurrents,sprintf("I_{%s} [A]",LGENscanned));

%% local functions
function myCurr2mon=GetMyCurr2mon(iCurr2mon,indices)
    myCurr2mon=NaN(size(iCurr2mon));
    for iMon=1:length(iCurr2mon)
        myCurr2mon(iMon)=indices(iMon+1)-indices(1);
    end
end

function MappedQuant=MapMe(myQuantProf,myQuantSumm,cyProgsProf,cyProgsSumm)
    MappedQuant=NaN(size(myQuantProf));
    for iMon=1:size(cyProgsSumm,2)
        for iPlane=1:size(myQuantProf,2)
            [~,ia,ib]=intersect(cyProgsProf(:,iMon),cyProgsSumm(:,iMon));
            MappedQuant(ia,iPlane,iMon)=myQuantSumm(ib,iPlane,iMon);
        end
    end
end
