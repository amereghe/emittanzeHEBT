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
% - cyProgs of LPOWmon are off!!!!
cyProgsLPOWMon=str2double(cyProgsLPOWMon)+4097; % 4097=2^12+1;
% - get TM currents
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machine,config);
psNamesTM=string(psNamesTM);
cyCodesTM=upper(string(cyCodesTM));
% - fill in current arrays
scannedIsTM=zeros(1,length(allLGENs));
for iLGEN=1:length(allLGENs)
    % find LGEN in TM array
    ii=find(psNamesTM==allLGENs(iLGEN));
    if ( ismissing(ii) )
        error("...error while getting TM values for %s",allLGENs(iLGEN));
    elseif ( length(ii)>1 )
        error("...non unique entry named %s in TM values",allLGENs(iLGEN));
    end
    % find proper cyCode
    uniqueCyCodes=unique(cyCodesProf);
    uniqueCyCodes=uniqueCyCodes(~ismissing(uniqueCyCodes));
    [rangeCodes,partCodes]=DecodeCyCodes(uniqueCyCodes);
    rangeCode=unique(rangeCodes);
    if ( ismissing(rangeCode) )
        error("...error while getting unique range code from measurements");
    elseif ( length(rangeCode)>1 )
        error("...non unique range code in measurements");
    end
    jj=find(cyCodesTM==rangeCode);
    if ( ismissing(jj) )
        error("...error while getting unique range code in TM values");
    elseif ( length(jj)>1 )
        error("...non unique range code in TM values");
    end
    scannedIsTM(1:indices(3,2,1)-indices(3,1,1)+1,iLGEN)=currentsTM(jj,ii)';
end
return

%% main - cross checks
% - compare data from summary files and statistics computed on profiles
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm);
% - compare currents
CompareCurrents(Is,indices,LGENnames,appValsLPOWMon,LGENsLPOWMon,allLGENs,scannedIsTM,cyProgsSumm,cyProgsLPOWMon); % indices are based on summary data
% - plot distributions (3D visualisation)
ShowParsedDistributions(profiles,Is,LGENnames,indices);
return

%% main - actual analysis
% - raw plots
% RawPlots(Is,nDataCurr,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,descs,outNames);
RawPlots(Is,nDataCurr,FWHMsProf,BARsProf,INTsProf,nDataProf,descs,outNames);
% - actual plots
% ScanPlots(Is,FWHMsSumm,BARsSumm,indices,descs,outNames);
ScanPlots(Is,FWHMsProf,BARsProf,indices,descs,outNames);
% - export data to xlsx files
% ExportData(Is,nDataCurr,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,indices,outNames);
ExportData(Is,nDataCurr,FWHMsProf,BARsProf,profINTs,nDataProf,indices,outNames);
return
