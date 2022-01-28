% {}~

%% include libraries
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - include local library with functions
pathToLibrary="lib";
addpath(genpath(pathToLibrary));

measPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY";
LPOWmonPath="S:\Accelerating-System\Accelerator-data\Area dati MD\LPOWmonitor\ErrorLog";
fracEst=[ 0.875 0.75 0.625 0.5 0.375 0.25 ];

%% main - load infos
% returns:
dataTree="2021-09";
run(sprintf("%s\\%s",dataTree,"SetMeUp_ScanZ212_C170.m"));
run(sprintf("%s\\%s","lib","SetUpWorkSpace.m"));

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

%% main - actual analysis
% - build table of currents
[tableIs]=BuildCurrentTable(cyCodesProf,cyProgsProf,allLGENs,IsXLS,LGENnamesXLS,psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices);
% - actual plots (FWHM and barycentre vs Iscan (actual range), CAMeretta and DDS)
% ScanPlots(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,indices,scanDescription,outName);
ScanPlots(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,indices,scanDescription,outName);
% - export data to xlsx files
% ExportDataOverview(tableIs,allLGENs,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,indices,outName);
ExportDataOverview(tableIs,allLGENs,FWHMsProf,BARsProf,INTsProf,nDataProf,indices,outName);
% - compute statistics on profiles at different heights
[BARsProfScan,FWHMsProfScan,INTsProfScan]=ComputeDistStats(profiles,fracEst);
% - reduce values for FWxMs:
[ReducedFWxM]=GetReducedFWxM(FWHMsProfScan,fracEst);
% - show statistics on profiles at different heights
FWxMPlots(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProfScan,BARsProfScan,ReducedFWxM,fracEst,indices,scanDescription,outName);
% - export data to xlsx files
ExportDataFWxM(tableIs,allLGENs,FWHMsProfScan,BARsProfScan,fracEst,nDataProf,indices,outName);
ExportDataFWxM(tableIs,allLGENs,ReducedFWxM,BARsProfScan,fracEst,nDataProf,indices,outName,true);

%% main - cross checks
% - raw plots (ie CAM/DDS: FWHM, bar and integral vs ID; scanned quad: I vs ID), to get indices
% RawPlots(IsXLS(:,LGENnamesXLS==LGENscanned),nDataCurr,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,scanDescription,outName);
RawPlots(IsXLS(:,LGENnamesXLS==LGENscanned),nDataCurr,FWHMsProf,BARsProf,INTsProf,nDataProf,scanDescription,outName);
% - compare data from summary files and statistics computed on profiles
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm);
% - compare currents: LPOW error log vs xls and TM values
if ( ~ismissing(LGENsLPOWMon) )
    CompareCurrents(IsXLS,indices,LGENscanned,appValsLPOWMon,LGENsLPOWMon,allLGENs,tableIs,cyProgsSumm,cyProgsLPOWMon); % indices are based on summary data
end
% - plot distributions (3D visualisation)
ShowParsedDistributions(profiles,IsXLS(:,LGENnamesXLS==LGENscanned),LGENscanned,indices);
