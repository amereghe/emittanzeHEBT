% {}~

%% include libraries
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - include local library with functions
pathToLibrary="lib";
addpath(genpath(pathToLibrary));

measPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY";

%% main - load infos
% returns:
dataTree="2021-09";
run(sprintf("%s\\SetMeUp.m",dataTree));
% - parse distributions
[profCyProgs,profCyCodes,profiles,profNData]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths);
[profBARs,profFWHMs,profINTs]=StatDistributions(profiles);
% - parse summary files
[cyProgs,cyCodes,BARs,FWHMs,ASYMs,INTs,summNData]=AcquireSummaryData(actCAMPaths,actDDSPaths);
% - parse current files
[Is,currNData]=AcquireCurrentData(currPaths,LGENnames);
% - plot distributions
ShowParsedDistributions(profiles,Is,LGENnames,indices);
% - raw plots
% RawPlots(Is,currNData,FWHMs,BARs,INTs,summNData,descs,outNames);
RawPlots(Is,currNData,profFWHMs,profBARs,profINTs,profNData,descs,outNames);
% - actual plots
% ScanPlots(Is,FWHMs,BARs,indices,descs,outNames);
ScanPlots(Is,profFWHMs,profBARs,indices,descs,outNames);
% - export data to xlsx files
% ExportData(Is,currNData,FWHMs,BARs,INTs,summNData,indices,outNames);
ExportData(Is,currNData,profFWHMs,profBARs,profINTs,profNData,indices,outNames);

