%% user input
parentPath="2021\QuadScanSep2021";
description="2021-09: RFKO";             % just a label
path="ScanZ218-C170";                    % subfolder in parentPath
currFile="ScanZ218-RFKOC170mmSala1.xls";
LGENscanned="PB-009A-LGEN";              % scanning quad
LGENscannedNickName="Z2-018A-QUE";
scanDescription="scan: Z2-018A-QUE - C, 170 mm";
plotName="Z2-018A-QUE_C170";
CAMpaths=[
    "CarbSO2_LineZ_Size6_*"
    ];
allLGENs=["PB-005A-LGEN" "PB-006A-LGEN" "PB-007A-LGEN" "PB-008A-LGEN" "PB-009A-LGEN"];
LPOWlogFiles=[
    "2021-09-02\*.txt"
    "2021-09-03\*.txt"
    ];
%% getting TM currents
beamPart="CARBON";
machine="LineZ";
config="TM"; % select configuration: TM, RFKO

%% indices in measurements
% - 1st col: 1=CAM (summary file), 2=DDS (summary file), 3=current;
% - 2nd col: min,max;
indices=zeros(3,2);
indices(3,:)=[12 51];
indices(1,:)=indices(3,:)-2;
indices(2,:)=indices(3,:)-1;
