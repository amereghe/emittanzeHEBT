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

%% indices in measurements (CAM/DDS summary files)
%   . 1st col: 1=current, 2=CAM, 3=DDS;
%   . 2nd col: min,max;
indices(1,:,iScanSetUps)=[5 44];
indices(2,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1);
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(2);
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[  6 30;  7 29;  8 28;  9 27; 10 26; 11 25; 12 24]'; % HOR plane, symmetric, 7 couples (min at ID=~18)
fitIndicesV=fitIndicesH+1; % VER plane, symmetric, 7 couples (min at ID=~19)
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
% - 1st col: 1=CAM (summary file), 2=DDS (summary file);
% - 2nd col: min,max;
% - 3rd col: hor,ver;
% - 4th col: fit ranges;
fitIndices(1,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(1,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - DDS
fitIndices(2,:,1,:,iScanSetUps)=fitIndices(1,:,1,:,iScanSetUps)-iCurr2mon(1)+iCurr2mon(2); % HOR plane same as CAM (apart from shift of IDs)
fitIndicesV=fitIndicesV+3; % VER plane, symmetric, 7 couples (min at ID=~22)
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
