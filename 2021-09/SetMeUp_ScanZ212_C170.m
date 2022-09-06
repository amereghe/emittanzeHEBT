%% user input
description(iScanSetUps)="2021-09: RFKO";               % just a label
path(iScanSetUps)="2021\QuadScanSep2021\ScanZ212-C170"; % subfolder in parentPath
currFile(iScanSetUps)="2021\QuadScanSep2021\ScanZ212-RFKOC170mmSala1.xls";
LGENscanned(iScanSetUps)="PB-008A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="Z2-012A-QUE";
scanDescription(iScanSetUps)="scan: Z2-012A-QUE - C, 170 mm";
plotName(iScanSetUps)="Z2-012A-QUE_C170";
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
fitIndicesH=[ 10 49; 12 45; 14 42; 16 39; 18 36; 21 33; 24 30 ]'; % symmetric, 7 couples (min at ID=27)
fitIndicesV=[ 10 49; 12 45; 14 41; 16 38; 18 35; 20 32; 23 29 ]'; % symmetric, 7 couples (min at ID=26)
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
clear fitIndicesH fitIndicesV;
fitIndicesH=[ 11 49; 13 45; 15 42; 17 39; 20 36; 23 33; 26 31 ]'; % symmetric, 7 couples (min at ID=28-29)
fitIndicesV=[ 11 49; 13 45; 15 41; 17 38; 19 35; 21 32; 23 29 ]'; % symmetric, 7 couples (min at ID=25)
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end % V plane: sigma oscillates around a slowly-increasing value
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
