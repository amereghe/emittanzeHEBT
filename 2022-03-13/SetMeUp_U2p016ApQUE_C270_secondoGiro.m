%% user input
description(iScanSetUps)="2022-03: U2-016A-QUE";      % just a label
parentPath(iScanSetUps)="2022\Emittanze 2022";
path(iScanSetUps)="secondo giro\Scan U2-16-H28";      % subfolder in parentPath
currFile(iScanSetUps)="Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-008A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U2-016A-QUE";
scanDescription(iScanSetUps)="scan: U2-016A-QUE - C, 270 mm - secondo Giro";
plotName(iScanSetUps)="U2-016A-QUE_C270_secondoGiro";
clear CAMpaths DDSpaths;
CAMpaths=[
    "CarbSO1_LineU_Size6_*"
    ];
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end

%% indices in measurements
% - 1st col: 1=current, 2=CAM (summary file), 3=DDS (summary file);
% - 2nd col: min,max;
indices(1,:,iScanSetUps)=[5 44];
indices(2,:,iScanSetUps)=indices(1,:,iScanSetUps)-2;
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)-1;
% indices for fitting data
fitIndicesH=[  9 37; 12 34; 15 31; 18 28; 19 27; 20 26]'; % HOR plane, waist at ID=23, symmetric, 6 couples
fitIndicesV=[  4 32;  7 29; 10 26; 13 23; 14 22; 15 21]'; % VER plane, waist at ID=18, symmetric, 6 couples
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
% - 1st col: 1=current, 2=CAM (summary file), 3=DDS (summary file);
% - 2nd col: min,max;
% - 3rd col: hor,ver;
% - 4th col: fit ranges;
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
fitIndices(fitIndices==0)=NaN();
fitIndices(1,:,:,:,iScanSetUps)=fitIndices(2,:,:,:,iScanSetUps)+2;
fitIndices(3,:,:,:,iScanSetUps)=fitIndices(2,:,:,:,iScanSetUps)+1;
