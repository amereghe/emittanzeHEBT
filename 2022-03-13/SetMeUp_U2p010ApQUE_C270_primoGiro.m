%% user input
path(iScanSetUps)="2022\Emittanze 2022\primo giro\Scan U2-10-H27";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-007A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U2-010A-QUE";
scanDescription(iScanSetUps)="2022-03-13 - U2-010A-QUE - C, 270 mm - primo Giro";
plotName(iScanSetUps)="U2-010A-QUE_C270_primoGiro";
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
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1); % DDS has same IDs as CAMeretta
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[  6 24;  8 22;  9 21; 10 20; 11 19; 12 18]'; % HOR plane, symmetric, 6 couples (min at ID=15)
fitIndicesV=[  5 25;  7 23;  9 21; 10 20; 11 19; 12 18]'; % VER plane, symmetric, 6 couples (min at ID=15)
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
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH; % indices identical to CAM
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV-1;
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
