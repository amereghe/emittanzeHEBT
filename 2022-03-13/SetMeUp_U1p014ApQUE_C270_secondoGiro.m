%% user input
description(iScanSetUps)="2022-03: U1-014A-QUE";      % just a label
path(iScanSetUps)="2022\Emittanze 2022\secondo giro\Scan U1-14-H24";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-004A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U1-014A-QUE";
scanDescription(iScanSetUps)="scan: U1-014A-QUE - C, 270 mm - secondo Giro";
plotName(iScanSetUps)="U1-014A-QUE_C270_secondoGiro";
clear CAMpaths DDSpaths;
CAMpaths=[
    "CarbSO1_LineU_Size6_*"
    ];
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end

%% indices in measurements
% - 1st col: 1=current, 2=CAM (summary file), 3=DDS (summary file);
% - 2nd col: min,max;
indices(1,:,iScanSetUps)=[5 44];
indices(2,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1);
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(2);
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[12 30; 13 29; 14 28; 15 27; 16 26; 17 25; 18 24]'; % HOR plane, symmetric, 7 couples (min at ID=21)
fitIndicesV=[18 42; 19 41; 20 40; 21 39; 22 38; 24 36; 26 34]'; % VER plane, symmetric, 7 couples (min at ID=30)
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
% - 1st col: 1=CAM (summary file), 2=DDS (summary file);
% - 2nd col: min,max;
% - 3rd col: hor,ver;
% - 4th col: fit ranges;
fitIndices(1,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(1,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - DDS (very similar to CAM, apart from ID-shift)
fitIndices(2,:,:,:,iScanSetUps)=fitIndices(1,:,:,:,iScanSetUps)-iCurr2mon(1)+iCurr2mon(2);
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
