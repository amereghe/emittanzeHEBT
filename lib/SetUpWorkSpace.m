fprintf("setting up data in %s - desc: %s ...\n",parentPath,description);

%% some consistency checks of user input
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end
if ( sum(strcmpi(allLGENs,LGENscanned))==0 )
    error("...unable to find scanned LGEN %s in array of all LGENs!",LGENscanned);
elseif ( sum(strcmpi(allLGENs,LGENscanned))>1 )
    error("...LGEN %s found multiple times in array of all LGENs!",LGENscanned);
end
% check that the LGEN name of the scanned magnet is in the allLGENs array

%% build actual paths
currPath=sprintf("%s\\%s\\%s",measPath,parentPath,currFile);
outName=sprintf("%s\\%s",dataTree,plotName);
% CAM/DDS paths
nCamPaths=length(CAMpaths);
actCAMPaths=strings(nCamPaths,1);
actDDSPaths=strings(nCamPaths,1);
CAMProfsPaths=strings(nCamPaths,1);
DDSProfsPaths=strings(nCamPaths,1);
for ii=1:nCamPaths
    actCAMPaths(ii)=sprintf("%s\\%s\\%s\\%s\\*summary.txt",measPath,parentPath,path,CAMpaths(ii));
    actDDSPaths(ii)=sprintf("%s\\%s\\%s\\%s\\Data*.csv",measPath,parentPath,path,DDSpaths(ii));
    CAMProfsPaths(ii)=sprintf("%s\\%s\\%s\\%s\\profiles\\*_profiles.txt",measPath,parentPath,path,CAMpaths(ii));
    DDSProfsPaths(ii)=sprintf("%s\\%s\\%s\\%s\\Profiles\\Data*DDSF.csv",measPath,parentPath,path,DDSpaths(ii));
end
% LPOW paths
LPOWmonPaths=strings(length(LPOWlogFiles),1);
for ii=1:length(LPOWlogFiles)
    LPOWmonPaths(ii)=sprintf("%s\\%s",LPOWmonPath,LPOWlogFiles(ii));
end

%%
% - general infos
mons=["CAM" "DDS"]; nMons=length(mons);
planes=["H" "V"];
% - fit infos
nFitSets=size(fitIndices,4);
if ( size(fitIndices,3)==1 )
    fitIndices(:,:,2,:)=fitIndices(:,:,1,:);
end
% - largest fit range
iLargestFitRange=zeros(2,1); largestFitRange=zeros(2,1);
for iMon=1:2
    for iPlane=1:2
        [myRange,myId]=max(fitIndices(iMon+1,2,iPlane,:)-fitIndices(iMon+1,1,iPlane,:)+1);
        if (myRange>largestFitRange(iPlane))
            largestFitRange(iPlane)=myRange;
            iLargestFitRange(iPlane)=myId;
        end
    end
end

%%
fprintf("...done\n");
