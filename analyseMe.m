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
    "2022-03-13\SetMeUp_U2p016ApQUE_C270_secondoGiro.m"
%     "2022-03-13\SetMeUp_U1p014ApQUE_C270_secondoGiro.m"
%     "2022-03-13\SetMeUp_U1p018ApQUE_C270_secondoGiro.m"
%     "2022-03-13\SetMeUp_U2p006ApQUE_C270_secondoGiro.m"
%     "2022-03-13\SetMeUp_U2p010ApQUE_C270_secondoGiro.m"
    ];
% - scan infos
nScanSetUps=length(scanSetUps);
iMinScanSetUps=1; iMaxScanSetUps=nScanSetUps;

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

%% main - cross checks
if ( ~lAnalyseOnly )
    for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
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
        % - plot distributions (3D visualisation)
        myOutName=sprintf("%s_3D_aligned.fig",outName(iScanSetUps)); myRemark="aligned distributions";
        [indicesMon,indicesCur]=GenIndices(indices(2:3,:,iScanSetUps),iCurr2mon);
        ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
        clear indicesMon indicesCur;
        % for iFitSet=1:nFitSets
        %     myOutName=sprintf("%s_3D_fitDistributions_%02d.fig",outName(iScanSetUps),iFitSet); myRemark=sprintf("distributions to be fitted (set # %2i)",iFitSet);
        %     ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),fitIndices(:,:,:,iFitSet,iScanSetUps));
        % end
        if ( iLargestFitRange(1,iScanSetUps)==iLargestFitRange(2,iScanSetUps) )
            [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(1,iScanSetUps),iScanSetUps),iCurr2mon);
            myOutName=sprintf("%s_3D_fitDistributions_largestFitRange.fig",outName(iScanSetUps)); myRemark=sprintf("distributions to be fitted (largest set: # %2i)",iLargestFitRange(1,iScanSetUps));
            ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
            clear indicesMon indicesCur;
        else
            for iPlane=1:2
                [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(iPlane,iScanSetUps),iScanSetUps),iCurr2mon);
                myOutName=sprintf("%s_3D_fitDistributions_largestFitRange_%s.fig",outName(iScanSetUps),planes(iPlane)); myRemark=sprintf("distributions to be fitted (largest set on %s plane: # %2i)",planes(iPlane),iLargestFitRange(iPlane,iScanSetUps));
                ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark,IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),indicesMon,indicesCur);
                clear indicesMon indicesCur;
            end
            clear iPlane;
        end
        myOutName=sprintf("%s_3D_allIDs.fig",outName(iScanSetUps)); myRemark="all distributions";
        ShowParsedDistributions(profiles(:,:,:,:,iScanSetUps),LGENscanned(iScanSetUps),myOutName,myRemark);
    end
end

%% main - actual analysis
[BARsProfScan,FWHMsProfScan,INTsProfScan]=deal(missing(),missing(),missing());
ReducedFWxM=missing();
for iScanSetUps=iMinScanSetUps:iMaxScanSetUps
    % - compute statistics on profiles at different heights
    [tmpBARsProfScan,tmpFWHMsProfScan,tmpINTsProfScan]=ComputeDistStats(profiles(:,:,:,:,iScanSetUps),fracEst);
    % - reduced values for FWxMs:
    [tmpReducedFWxM]=GetReducedFWxM(tmpFWHMsProfScan,fracEst);
    
    if ( ~lAnalyseOnly )
        % - actual plots (FWHM and baricentre vs Iscan (actual range), CAMeretta and DDS)
        % ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"],outName(iScanSetUps));
        ShowScanAligned(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),indices(:,:,iScanSetUps),scanDescription(iScanSetUps),["CAMeretta" "DDS"]);
        % - export data to xlsx files
        [indicesMon,indicesCur]=GenIndices(indices(2:3,:,iScanSetUps),iCurr2mon);
        % myOutName=sprintf("%s_SummaryData.xlsx",outName(iScanSetUps)); ExportDataOverview(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsSumm(:,:,:,iScanSetUps),BARsSumm(:,:,:,iScanSetUps),INTsSumm(:,:,:,iScanSetUps),nDataSumm(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        myOutName=sprintf("%s_ProfStatsData.xlsx",outName(iScanSetUps)); ExportDataOverview(tableIs(:,:,:,iScanSetUps),allLGENs,FWHMsProf(:,:,:,iScanSetUps),BARsProf(:,:,:,iScanSetUps),INTsProf(:,:,:,iScanSetUps),nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        clear indicesMon indicesCur;
        % - show statistics on profiles at different heights
        FWxMPlots(IsXLS(:,LGENnamesXLS(:,iScanSetUps)==LGENscanned(iScanSetUps),iScanSetUps),tmpFWHMsProfScan,tmpBARsProfScan,tmpReducedFWxM,fracEst,indices(:,:,iScanSetUps),scanDescription(iScanSetUps),outName(iScanSetUps));
        % - export data to xlsx files
        %   NB: integrals are from the summary files, whereas the other quantities come from the analysis on the profiles...
        % for iFitSet=1:nFitSets
        %     [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iFitSet,iScanSetUps),iCurr2mon);
        %     myOutName=sprintf("%s_FWxM_%02d.xlsx",outName(iScanSetUps),iFitSet); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpFWHMsProfScan,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
        %     myOutName=sprintf("%s_SIGxM_%02d.xlsx",outName(iScanSetUps),iFitSet); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpReducedFWxM,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
        %     clear indicesMon indicesCur;
        % end
        if ( iLargestFitRange(1,iScanSetUps)==iLargestFitRange(2,iScanSetUps) )
            [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(1,iScanSetUps),iScanSetUps),iCurr2mon);
            myOutName=sprintf("%s_FWxM_largestFitRange.xlsx",outName(iScanSetUps)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpFWHMsProfScan,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
            myOutName=sprintf("%s_SIGxM_largestFitRange.xlsx",outName(iScanSetUps)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpReducedFWxM,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
            clear indicesMon indicesCur;
        else
            for iPlane=1:2
                [indicesMon,indicesCur]=GenIndices(fitIndices(:,:,:,iLargestFitRange(iPlane,iScanSetUps),iScanSetUps),iCurr2mon);
                myOutName=sprintf("%s_FWxM_largestFitRange_%s.xlsx",outName(iScanSetUps),planes(iPlane)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpFWHMsProfScan,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName);
                myOutName=sprintf("%s_SIGxM_largestFitRange_%s.xlsx",outName(iScanSetUps),planes(iPlane)); ExportDataFWxM(tableIs(:,:,:,iScanSetUps),allLGENs,tmpReducedFWxM,tmpBARsProfScan,INTsMapped(:,:,:,iScanSetUps),fracEst,nDataProf(:,iScanSetUps),indicesMon,indicesCur,myOutName,true);
                clear indicesMon indicesCur;
            end
            clear iPlane;
        end
    end
    
    % - store data:
    %   . profiles:
    BARsProfScan=ExpandMat(BARsProfScan,tmpBARsProfScan); clear tmpBARsProfScan;
    FWHMsProfScan=ExpandMat(FWHMsProfScan,tmpFWHMsProfScan); clear tmpFWHMsProfScan;
    INTsProfScan=ExpandMat(INTsProfScan,tmpINTsProfScan); clear tmpINTsProfScan;
    ReducedFWxM=ExpandMat(ReducedFWxM,tmpReducedFWxM); clear tmpReducedFWxM;
end

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

%% fit data
% sigdpp=0:5E-5:1E-3;
% sigdpp=0:1E-3:1E-3;
sigdpp=[ 0.0 1E-3 ]; sigdppStrings=compose("sigdpp=%g",sigdpp);
labelsType=[ "EMI_RMS" "EMI_HWxM" ];
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
        for iPlane=1:length(planes)
            for iFitSet=1:nFitRanges(iPlane,iScanSetUps)
                % - range of data set to consider:
                iMinFit=fitIndices(iMon,1,iPlane,iFitSet,iScanSetUps);
                iMaxFit=fitIndices(iMon,2,iPlane,iFitSet,iScanSetUps);
                % - corresponding range in current:
                jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==iMinFit-iCurr2mon(iMon));
                jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==iMaxFit-iCurr2mon(iMon));
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
        % for iType=1:2
        %     for iPlane=1:length(planes)
        %         for iFitSet=1:nFitSets
        %             ShowFittedOpticsFunctions(beta0(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),alpha0(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),emiG(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),sigdpp,planes(iPlane),fracEstStrings);
        %             ShowFittedOrbits(z(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),pz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),dpz(:,:,iPlane,iFitSet,iType,iMon,iScanSetUps),planes(iPlane),avedpp(:,iPlane,iFitSet,iType,iMon,iScanSetUps),fracEstStrings);
        %         end
        %     end
        % end
        if ( ~lAnalyseOnly )
            ShowFittedOpticsFunctionsGrouped(...
                beta0(:,:,:,:,:,iMon,iScanSetUps),alpha0(:,:,:,:,:,iMon,iScanSetUps),emiG(:,:,:,:,:,iMon,iScanSetUps),...
                dz(:,:,:,:,:,iMon,iScanSetUps),dpz(:,:,:,:,:,iMon,iScanSetUps),...
                z(:,:,:,:,:,iMon,iScanSetUps),pz(:,:,:,:,:,iMon,iScanSetUps),...
                1-fracEst,"1-frac []",planes,compose("fit set #%2d",1:nMaxFitSets),...
                sigdppStrings,labelsType,scanDescription(iScanSetUps),mons(iMon),nFitRanges(:,iScanSetUps),outName(iScanSetUps));
            ShowFittedEllipsesGrouped(...
                beta0(:,:,:,:,:,iMon,iScanSetUps),alpha0(:,:,:,:,:,iMon,iScanSetUps),emiG(:,:,:,:,:,iMon,iScanSetUps),...
                planes,compose("fit set #%2d",1:nMaxFitSets),fracEstStrings,sigdppStrings,labelsType,scanDescription(iScanSetUps),mons(iMon),nFitRanges(:,iScanSetUps),outName(iScanSetUps));
        end
    end
end

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
        for iPlane=1:length(planes)
            % - transport optics
            for iFitSet=1:nFitRanges(iPlane,iScanSetUps)
                % - range of data set to consider:
                jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==fitIndices(iMon,1,iPlane,iFitSet,iScanSetUps)-iCurr2mon(iMon));
                jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==fitIndices(iMon,2,iPlane,iFitSet,iScanSetUps)-iCurr2mon(iMon));
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
            jMinFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==min(fitIndices(iMon,1,iPlane,:,iScanSetUps)-iCurr2mon(iMon)));
            jMaxFit=find(indices(1,1,iScanSetUps):indices(1,2,iScanSetUps)==max(fitIndices(iMon,2,iPlane,:,iScanSetUps)-iCurr2mon(iMon)));
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
            CompareFits(calcSigmas(:,:,:,:,:,:,iMon,iScanSetUps),scanCurrents(:,:,:,iMon,iScanSetUps),measSigma(:,:,:,:,iMon,iScanSetUps),measCurr(:,:,iMon,iScanSetUps),"SIG",...
                sigdppStrings,fracEstStrings,planes,sprintf("I_{%s} [A]",LGENscanned(iScanSetUps)),compose("fit set #%2d",1:nMaxFitSets),labelsType,...
                scanDescription(iScanSetUps),mons(iMon),nFitRanges(:,iScanSetUps),outName(iScanSetUps));
            CompareFits(calcBars(:,:,:,:,:,:,iMon,iScanSetUps),scanCurrents(:,:,:,iMon,iScanSetUps),measBARs(:,:,iMon,iScanSetUps),measCurr(:,:,iMon,iScanSetUps),"BAR",...
                sigdppStrings,fracEstStrings,planes,sprintf("I_{%s} [A]",LGENscanned(iScanSetUps)),compose("fit set #%2d",1:nMaxFitSets),labelsType,...
                scanDescription(iScanSetUps),mons(iMon),nFitRanges(:,iScanSetUps),outName(iScanSetUps));
        end
    end
end

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
function MappedQuant=MapMe(myQuantProf,myQuantSumm,cyProgsProf,cyProgsSumm)
    MappedQuant=NaN(size(myQuantProf));
    for iMon=1:size(cyProgsSumm,2)
        for iPlane=1:size(myQuantProf,2)
            [~,ia,ib]=intersect(cyProgsProf(:,iMon),cyProgsSumm(:,iMon));
            MappedQuant(ia,iPlane,iMon)=myQuantSumm(ib,iPlane,iMon);
        end
    end
end
