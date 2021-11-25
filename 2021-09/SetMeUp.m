%% user input
parentPath="2021\QuadScanSep2021";
description="2021-09: RFKO";
% subfolders in parentPath
paths=[
    "ScanZ218-C270"
    ];
currFiles=[
    "ScanZ218-RFKOC270mmSala1.xls"
    ];
% scanning quads (1 per scan)
LGENnames=[
    "PB-009A-LGEN"
    ];
LGENnickNames=[
    "Z2-018A-QUE"
    ];
descs=[
    "scan: Z2-018A-QUE - C, 270 mm"
    ];
plotNames=[
    "Z2-018A-QUE_C270"
    ];
CAMpaths=[
    "CarbSO2_LineZ_Size6_*"
    ];
allLGENs=[
    "PB-005A-LGEN" "PB-006A-LGEN" "PB-007A-LGEN" "PB-008A-LGEN" "PB-009A-LGEN" ;
    ];
LPOWlogFiles=[
    "2021-09-02\*.txt"
    "2021-09-03\*.txt"
    ];
beamPart="CARBON";
machine="LineZ";
config="TM"; % select configuration: TM, RFKO

% indices in measurements
% - 1st col: CAM (summary file), DDS (summary file), current;
% - 2nd col: min,max;
indices=zeros(3,2,length(paths));
indices(3,:,1)=[12 51];
indices(1,:,1)=indices(3,:,1)-2;
indices(2,:,1)=indices(3,:,1)-1;

%% 
fprintf("setting up data in %s - desc: %s ...\n",parentPath,description);

%% some consistency checks of user input
if ( length(paths)~=length(currFiles) ), error("...different number of paths (%d) and current files (%d)!",length(paths),length(currFiles)); end
if ( length(paths)~=length(LGENnames) ), error("...different number of paths (%d) and LGEN names (%d)!",length(paths),length(LGENnames)); end
if ( length(paths)~=length(LGENnickNames) ), error("...different number of paths (%d) and LGEN element names (%d)!",length(paths),length(LGENnickNames)); end
if ( length(paths)~=length(CAMpaths) ), error("...different number of paths (%d) and paths to CAMeretta data (%d)!",length(paths),length(CAMpaths)); end
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end
if ( length(paths)~=length(DDSpaths) ), error("...different number of paths (%d) and paths to DDS data (%d)!",length(paths),length(DDSpaths)); end

%% build actual paths
currPaths=strings(length(paths),1);
actCAMPaths=strings(length(paths),1);
CAMProfsPaths=strings(length(paths),1);
actDDSPaths=strings(length(paths),1);
DDSProfsPaths=strings(length(paths),1);
outNames=strings(length(paths),1);
LPOWmonPaths=strings(length(LPOWlogFiles),1);
for ii=1:length(paths)
    currPaths(ii)=sprintf("%s\\%s\\%s",measPath,parentPath,currFiles(ii));
    actCAMPaths(ii)=sprintf("%s\\%s\\%s\\%s\\*summary.txt",measPath,parentPath,paths(ii),CAMpaths(ii));
    CAMProfsPaths(ii)=sprintf("%s\\%s\\%s\\%s\\profiles\\*_profiles.txt",measPath,parentPath,paths(ii),CAMpaths(ii));
    actDDSPaths(ii)=sprintf("%s\\%s\\%s\\%s\\Data*.csv",measPath,parentPath,paths(ii),DDSpaths(ii));
    DDSProfsPaths(ii)=sprintf("%s\\%s\\%s\\%s\\Profiles\\Data*DDSF.csv",measPath,parentPath,paths(ii),DDSpaths(ii));
    outNames(ii)=sprintf("%s\\%s",dataTree,plotNames(ii));
end
for ii=1:length(LPOWlogFiles)
    LPOWmonPaths(ii)=sprintf("%s\\%s",LPOWmonPath,LPOWlogFiles(ii));
end

%%
fprintf("...done\n");
