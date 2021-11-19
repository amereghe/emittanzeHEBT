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

%% main - load infos
% returns:
dataTree="2021-09";
run(sprintf("%s\\SetMeUp.m",dataTree));

%% main - parse data files
% - parse beam profiles
[cyProgsProf,cyCodesProf,profiles,nDataProf]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths);
% - compute statistics on profiles
[BARsProf,FWHMsProf,INTsProf]=StatDistributions(profiles);
% - parse summary files
[cyProgsSumm,cyCodesSumm,BARsSumm,FWHMsSumm,ASYMsSumm,INTsSumm,nDataSumm]=AcquireSummaryData(actCAMPaths,actDDSPaths);
% - parse current files
[Is,nDataCurr]=AcquireCurrentData(currPaths,LGENnames);
% - parse LPOW monitor log
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWmonPaths);
return

%% main - cross checks
% - compare data from summary files and statistics computed on profiles
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm);
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm);
% - plot distributions (3D visualisation)
ShowParsedDistributions(profiles,Is,LGENnames,indices);
return

%% main - actual analysis
% - raw plots
% RawPlots(Is,nDataCurr,FWHMs,BARs,INTs,summNData,descs,outNames);
RawPlots(Is,nDataCurr,FWHMsProf,BARsProf,INTsProf,nDataProf,descs,outNames);
% - actual plots
% ScanPlots(Is,FWHMsSumm,BARsSumm,indices,descs,outNames);
ScanPlots(Is,FWHMsProf,BARsProf,indices,descs,outNames);
% - export data to xlsx files
% ExportData(Is,nDataCurr,FWHMs,BARs,INTs,summNData,indices,outNames);
ExportData(Is,nDataCurr,FWHMsProf,BARsProf,profINTs,nDataProf,indices,outNames);
return
