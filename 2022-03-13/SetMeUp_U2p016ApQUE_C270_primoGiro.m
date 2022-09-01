%% user input
path(iScanSetUps)="2022\Emittanze 2022\primo giro\Scan U2-16-H28";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-008A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U2-016A-QUE";
scanDescription(iScanSetUps)="2022-03-13 - U2-016A-QUE - C, 270 mm - primo Giro";
plotName(iScanSetUps)="U2-016A-QUE_C270_primoGiro";
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
clear fitIndicesH fitIndicesV;
% - CAM
fitIndicesH=[  5 41;  9 37; 12 34; 14 32; 16 30; 19 27]'; % HOR plane, symmetric, 6 couples (min at ID=23)
fitIndicesV=[  4 33;  7 30; 10 27; 13 24; 14 23; 15 22]'; % VER plane, symmetric, 6 couples (min at ID=18)
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
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH+1;
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV+2;
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
