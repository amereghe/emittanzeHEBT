%% user input
path(iScanSetUps)="2022\Emittanze 2022\primo giro\Scan U1-18-H25";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-005A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U1-018A-QUE";
scanDescription(iScanSetUps)="2022-03-13 - U1-018A-QUE - C, 270 mm - primo Giro";
plotName(iScanSetUps)="U1-018A-QUE_C270_primoGiro";
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
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1);
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[ 3 20; 4 19; 5 18; 6 17; 7 16; 8 15]'; % HOR plane, symmetric, 6 couples (min at ID=11)
% fitIndicesH=[7 23; 7 24; 7 25; 7 26; 8 23; 8 24; 8 25; 8 26; 9 23; 9 24; 9 25; 9 26; 10 23; 10 24; 10 25; 10 26; ]'; % asymmetric, 16 couples
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end % V plane: sigma oscillates around a slowly-increasing value
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
% - 1st col: 1=CAM (summary file), 2=DDS (summary file);
% - 2nd col: min,max;
% - 3rd col: hor,ver;
% - 4th col: fit ranges;
fitIndices(1,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(1,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - DDS
fitIndicesH=fitIndicesH+1; % HOR plane, very similar to CAM
fitIndicesV=fitIndicesV+1; % VER plane, very similar to CAM
if ( ~exist('fitIndicesV','var') ), fitIndicesV=fitIndicesH; end
nFitRanges(1,iScanSetUps)=size(fitIndicesH,2);
nFitRanges(2,iScanSetUps)=size(fitIndicesV,2);
fitIndices(2,:,1,1:nFitRanges(1,iScanSetUps),iScanSetUps)=fitIndicesH;
fitIndices(2,:,2,1:nFitRanges(2,iScanSetUps),iScanSetUps)=fitIndicesV;
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
