%% user input
description(iScanSetUps)="2021-09: RFKO";               % just a label
path(iScanSetUps)="2021\QuadScanSep2021\ScanZ218-C170"; % subfolder in parentPath
currFile(iScanSetUps)="2021\QuadScanSep2021\ScanZ218-RFKOC170mmSala1.xls";
LGENscanned(iScanSetUps)="PB-009A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="Z2-018A-QUE";
scanDescription(iScanSetUps)="scan: Z2-018A-QUE - C, 170 mm";
plotName(iScanSetUps)="Z2-018A-QUE_C170";
clear CAMpaths DDSpaths;
CAMpaths=[
    "CarbSO2_LineZ_Size6_*"
    ];
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end

%% indices in measurements (CAM/DDS summary files)
%   . 1st col: 1=current, 2=CAM, 3=DDS;
%   . 2nd col: min,max;
indices(1,:,iScanSetUps)=[12 51];
indices(2,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1);
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(2);
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[11 49; 14 46; 17 43; 20 40; 23 37; 25 35; 27 33]'; % symmetric, 7 couples (min at ID=30)
fitIndicesV=[11 48; 13 45; 15 41; 17 37; 19 33; 21 31; 23 29]'; % symmetric, 7 couples (min at ID=26)
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end % V plane: sigma oscillates around a slowly-increasing value
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
% - 1st col: 1=CAM (summary file), 2=DDS (summary file);
% - 2nd col: min,max;
% - 3rd col: hor,ver;
% - 4th col: fit ranges;
fitIndices(1,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(1,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - DDS (very similar to CAM, apart from ID-shift)
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndices(1,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)-(iCurr2mon(1)-iCurr2mon(2));
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndices(1,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)-(iCurr2mon(1)-iCurr2mon(2));
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
