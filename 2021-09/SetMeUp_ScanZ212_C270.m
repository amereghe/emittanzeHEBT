%% user input
description(iScanSetUps)="2021-09: RFKO";             % just a label
path(iScanSetUps)="2021\QuadScanSep2021\ScanZ212";    % subfolder in parentPath
currFile(iScanSetUps)="2021\QuadScanSep2021\ScanZ212-RFKOC270mmSala1.xls";
LGENscanned(iScanSetUps)="PB-008A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="Z2-012A-QUE";
scanDescription(iScanSetUps)="scan: Z2-012A-QUE - C, 270 mm";
plotName(iScanSetUps)="Z2-012A-QUE_C270";
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
fitIndicesH=[ 10 49; 17 47; 21 43; 23 41; 25 39; 27 37; 29 35 ]'; % symmetric, 7 couples (min at ID=32)
fitIndicesV=[ 10 49; 12 46; 15 43; 18 40; 21 37; 23 34; 25 31 ]'; % symmetric, 7 couples (min at ID=28)
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
fitIndices(2,:,:,:,iScanSetUps)=fitIndices(1,:,:,:,iScanSetUps)-iCurr2mon(1)+iCurr2mon(2);
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
