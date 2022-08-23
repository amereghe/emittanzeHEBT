%% user input
description(iScanSetUps)="2022-03: U1-008A-QUE";      % just a label
parentPath(iScanSetUps)="2022\Emittanze 2022";
path(iScanSetUps)="secondo giro\Scan U1-08-H23";      % subfolder in parentPath
currFile(iScanSetUps)="Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-003A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U1-008A-QUE";
scanDescription(iScanSetUps)="scan: U1-008A-QUE - C, 270 mm - secondo Giro";
plotName(iScanSetUps)="U1-008A-QUE_C270_secondoGiro";
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
fitIndicesH=[8 26; 9 25; 10 24; 11 23; 12 22; 13 21; 14 20]'; % symmetric, 7 couples 
% fitIndicesH=[7 23; 7 24; 7 25; 7 26; 8 23; 8 24; 8 25; 8 26; 9 23; 9 24; 9 25; 9 26; 10 23; 10 24; 10 25; 10 26; ]'; % asymmetric, 16 couples
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
