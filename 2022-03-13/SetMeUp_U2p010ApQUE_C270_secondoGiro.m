%% user input
description(iScanSetUps)="2022-03: U2-010A-QUE";      % just a label
path(iScanSetUps)="2022\Emittanze 2022\secondo giro\Scan U2-10-H27";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-007A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U2-010A-QUE";
scanDescription(iScanSetUps)="scan: U2-010A-QUE - C, 270 mm - secondo Giro";
plotName(iScanSetUps)="U2-010A-QUE_C270_secondoGiro";
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
fitIndicesH=[  3 27;  5 25;  7 23;  9 21; 11 19; 12 18]'; % HOR plane, waist at ID=15, symmetric, 6 couples
fitIndicesV=[  3 25;  5 23;  7 21;  9 19; 10 18; 11 17]'; % VER plane, waist at ID=14, symmetric, 6 couples
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
