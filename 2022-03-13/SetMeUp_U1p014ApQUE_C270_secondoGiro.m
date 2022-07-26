%% user input
description="2022-03: U1-014A-QUE";      % just a label
parentPath="2022\Emittanze 2022";
path="secondo giro\Scan U1-14-H24";      % subfolder in parentPath
currFile="Scan01QuadU.xlsx";
LGENscanned="P9-004A-LGEN";              % scanning quad
LGENscannedNickName="U1-014A-QUE";
scanDescription="scan: U1-014A-QUE - C, 270 mm - secondo Giro";
plotName="U1-014A-QUE_C270_secondoGiro";
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
fitIndices=zeros(3,2,7);
fitIndices(2,:,:)=[11 30; 12 29; 13 28; 14 27; 15 26; 16 25; 17 24]'; % symmetric, 7 couples
% fitIndices(2,:,:)=[7 23; 7 24; 7 25; 7 26; 8 23; 8 24; 8 25; 8 26; 9 23; 9 24; 9 25; 9 26; 10 23; 10 24; 10 25; 10 26; ]'; % asymmetric, 16 couples
fitIndices(1,:,:)=fitIndices(2,:,:)+2;
fitIndices(3,:,:)=fitIndices(2,:,:)+1;