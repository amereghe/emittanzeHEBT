%% user input
description="2022-03: U1-008A-QUE";      % just a label
parentPath="2022\Emittanze 2022";
path="secondo giro\Scan U1-08-H23";      % subfolder in parentPath
currFile="Scan01QuadU.xlsx";
LGENscanned="P9-003A-LGEN";              % scanning quad
LGENscannedNickName="U1-008A-QUE";
scanDescription="scan: U1-008A-QUE - C, 270 mm";
plotName="U1-008A-QUE_C270";
CAMpaths=[
    "CarbSO1_LineU_Size6_*"
    ];
allLGENs=["P9-003A-LGEN" "P9-004A-LGEN" "P9-005A-LGEN" "P9-006A-LGEN" "P9-007A-LGEN" "P9-008A-LGEN" ];
LPOWlogFiles=[
    "2022-03-13\*.txt"
    ];
%% getting TM currents
beamPart="CARBON";
machine="LineU";
config="TM"; % select configuration: TM, RFKO

%% indices in measurements
% - 1st col: 1=current, 2=CAM (summary file), 3=DDS (summary file);
% - 2nd col: min,max;
indices=zeros(3,2);
indices(1,:)=[5 44];
indices(2,:)=indices(1,:)-2;
indices(3,:)=indices(1,:)-1;
% indices for fitting data
fitIndices=zeros(3,2);
fitIndices(2,:)=[8 24];
fitIndices(1,:)=fitIndices(2,:)+2;
fitIndices(3,:)=fitIndices(2,:)+1;
