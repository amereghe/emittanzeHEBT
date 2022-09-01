fprintf("setting up data in %s - scanDesc: %s ...\n",path(iScanSetUps),scanDescription(iScanSetUps));

%% some consistency checks of user input
if ( sum(strcmpi(allLGENs,LGENscanned(iScanSetUps)))==0 )
    error("...unable to find scanned LGEN %s in array of all LGENs!",LGENscanned(iScanSetUps));
elseif ( sum(strcmpi(allLGENs,LGENscanned(iScanSetUps)))>1 )
    error("...LGEN %s found multiple times in array of all LGENs!",LGENscanned(iScanSetUps));
end

%% build actual paths
currPath(iScanSetUps)=sprintf("%s\\%s",measPath,currFile(iScanSetUps));
[filepath,name,ext]=fileparts(scanSetUps(iScanSetUps));
savePath(iScanSetUps)=sprintf("%s\\%s",filepath,plotName(iScanSetUps));
if not(isfolder(savePath(iScanSetUps)))
    warning("...creating folder %s...",savePath(iScanSetUps));
    mkdir(savePath(iScanSetUps));
end
outName(iScanSetUps)=sprintf("%s\\%s",savePath(iScanSetUps),plotName(iScanSetUps));
% CAM/DDS paths
for ii=1:length(CAMpaths)
    actCAMPaths(ii,iScanSetUps)=sprintf("%s\\%s\\%s\\*summary.txt",measPath,path(iScanSetUps),CAMpaths(ii)); %#ok<*SAGROW>
    actDDSPaths(ii,iScanSetUps)=sprintf("%s\\%s\\%s\\Data*.csv",measPath,path(iScanSetUps),DDSpaths(ii));
    CAMProfsPaths(ii,iScanSetUps)=sprintf("%s\\%s\\%s\\profiles\\*_profiles.txt",measPath,path(iScanSetUps),CAMpaths(ii));
    DDSProfsPaths(ii,iScanSetUps)=sprintf("%s\\%s\\%s\\Profiles\\Data*DDSF.csv",measPath,path(iScanSetUps),DDSpaths(ii));
end
clear ii;

%% largest fit range
for iMon=1:2
    for iPlane=1:2
        [myRange,myId]=max(fitIndices(iMon,2,iPlane,:,iScanSetUps)-fitIndices(iMon,1,iPlane,:,iScanSetUps)+1);
        if (myRange>largestFitRange(iPlane,iScanSetUps))
            largestFitRange(iPlane,iScanSetUps)=myRange;
            iLargestFitRange(iPlane,iScanSetUps)=myId;
        end
    end
end
clear iMon iPlane myrange myId;

%%
clear filepath name ext; 
fprintf("...done\n");
