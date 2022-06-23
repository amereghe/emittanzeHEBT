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

%% main - load infos
measPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY";
LPOWmonPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY\LPOW_error_log";
% LPOWmonPath="S:\Accelerating-System\Accelerator-data\Area dati MD\LPOWmonitor\ErrorLog";
fracEst=[ 0.875 0.75 0.625 0.5 0.375 0.25 ];

% returns:
dataTree="2022-03-13";
run(sprintf("%s\\%s",dataTree,"SetMeUp_U1p008ApQUE_C270_secondoGiro.m"));
run(sprintf("%s\\%s","lib","SetUpWorkSpace.m"));
clear cyProgsProf cyCodesProf profiles nDataProf BARsProf FWHMsProf INTsProf IsXLS LGENnamesXLS nDataCurr BARsProfScan FWHMsProfScan INTsProfScan ReducedFWxM

%% main - parse data files
% - parse beam profiles
[cyProgsProf,cyCodesProf,profiles,nDataProf]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths);
% - compute statistics on profiles
[BARsProf,FWHMsProf,INTsProf]=ComputeDistStats(profiles);
% - parse summary files
[cyProgsSumm,cyCodesSumm,BARsSumm,FWHMsSumm,ASYMsSumm,INTsSumm,nDataSumm]=AcquireSummaryData(actCAMPaths,actDDSPaths);
% - parse current files
[IsXLS,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currPath);
% - parse LPOW monitor log
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWmonPaths);
% - cyProgs of LPOWmon are off!!!!
if ( ~ismissing(LGENsLPOWMon) )
    cyProgsLPOWMon=string(str2double(cyProgsLPOWMon)+4097); % 4097=2^12+1;
end
% - get TM currents
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machine,config);
psNamesTM=string(psNamesTM);
cyCodesTM=upper(string(cyCodesTM));
% - build table of currents
[tableIs]=BuildCurrentTable(cyCodesProf,cyProgsProf,allLGENs,IsXLS(:,LGENnamesXLS==LGENscanned),LGENscanned,psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices);

%% main - cross checks
% - raw plots (ie CAM/DDS: FWHM, bar and integral vs ID; scanned quad: I vs ID), to get indices
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,scanDescription,["CAMeretta" "DDS"],outName);
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,INTsProf,nDataProf,scanDescription,["CAMeretta" "DDS"],outName);
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,scanDescription,["CAMeretta" "DDS"]);
ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,INTsProf,nDataProf,scanDescription,["CAMeretta" "DDS"]);
% - compare data from summary files and statistics computed on profiles
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm);
% - compare currents: LPOW error log vs xls and TM values
if ( ~ismissing(LGENsLPOWMon) )
    CompareCurrents(IsXLS,indices,LGENscanned,appValsLPOWMon,LGENsLPOWMon,allLGENs,tableIs,cyProgsSumm,cyProgsLPOWMon); % indices are based on summary data
end
% - plot distributions (3D visualisation)
myOutName=sprintf("%s_3D_aligned.fig",outName); myRemark="aligned distributions";
ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark,IsXLS(:,LGENnamesXLS==LGENscanned),indices);
myOutName=sprintf("%s_3D_fitDistributions.fig",outName); myRemark="distributions to be fitted";
ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark,IsXLS(:,LGENnamesXLS==LGENscanned),fitIndices);
myOutName=sprintf("%s_3D_allIDs.fig",outName); myRemark="all distributions";
ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark);

%% main - actual analysis
% - actual plots (FWHM and baricentre vs Iscan (actual range), CAMeretta and DDS)
% ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,indices,scanDescription,["CAMeretta" "DDS"],outName);
ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,indices,scanDescription,["CAMeretta" "DDS"],outName);
ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,indices,scanDescription,["CAMeretta" "DDS"]);
% - export data to xlsx files
% myOutName=sprintf("%s_SummaryData.xlsx",outName); ExportDataOverview(tableIs,allLGENs,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,indices,myOutName);
myOutName=sprintf("%s_ProfStatsData.xlsx",outName); ExportDataOverview(tableIs,allLGENs,FWHMsProf,BARsProf,INTsProf,nDataProf,indices,myOutName);
% - compute statistics on profiles at different heights
[BARsProfScan,FWHMsProfScan,INTsProfScan]=ComputeDistStats(profiles,fracEst);
% - reduce values for FWxMs:
[ReducedFWxM]=GetReducedFWxM(FWHMsProfScan,fracEst);
% - show statistics on profiles at different heights
FWxMPlots(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProfScan,BARsProfScan,ReducedFWxM,fracEst,indices,scanDescription,outName);
% - export data to xlsx files
myOutName=sprintf("%s_FWxM.xlsx",outName); ExportDataFWxM(tableIs,allLGENs,FWHMsProfScan,BARsProfScan,fracEst,nDataProf,fitIndices,myOutName);
myOutName=sprintf("%s_SIGxM.xlsx",outName); ExportDataFWxM(tableIs,allLGENs,ReducedFWxM,BARsProfScan,fracEst,nDataProf,fitIndices,myOutName,true);

%% main - MADX part
% export MADX table
MADXFileName=sprintf("%s_CAM.tfs",outName);
nCols=size(tableIs,2);
header="I_"+allLGENs+" [A]";
headerTypes=strings(1,nCols);
headerTypes(:)="%le";
ExportMADXtable(MADXFileName,scanDescription,tableIs(fitIndices(1,1):fitIndices(1,2),:,1),header,headerTypes);

