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
% - parse data
[Is,cyProgs,cyCodes,BARs,FWHMs,ASYMs,INTs,nData]=AcquireData(currPaths,actCAMPaths,actDDSPaths,LGENnames);
% - raw plots
RawPlots(Is,FWHMs,BARs,INTs,nData,descs,outNames);
% - actual plots
ScanPlots(Is,FWHMs,BARs,indices,descs,outNames);
% - export data to xlsx files
ExportData(Is,FWHMs,BARs,INTs,nData,indices,outNames);

