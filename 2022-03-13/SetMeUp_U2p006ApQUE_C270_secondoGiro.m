%% user input
description(iScanSetUps)="2022-03: U2-006A-QUE";      % just a label
path(iScanSetUps)="2022\Emittanze 2022\secondo giro\Scan U2-06-H26";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-006A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U2-006A-QUE";
scanDescription(iScanSetUps)="scan: U2-006A-QUE - C, 270 mm - secondo Giro";
plotName(iScanSetUps)="U2-006A-QUE_C270_secondoGiro";
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
fitIndicesH=[ 10 28; 11 27; 12 26; 13 25; 14 24; 15 23; 16 22]'; % HOR plane, symmetric, 7 couples
fitIndicesV=[ 12 30; 13 29; 14 28; 15 27; 16 26; 17 25; 18 24]';  % VER plane, symmetric, 7 couples
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
