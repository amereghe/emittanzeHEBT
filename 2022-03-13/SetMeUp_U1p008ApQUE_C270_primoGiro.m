%% user input
path(iScanSetUps)="2022\Emittanze 2022\primo giro\Scan U1-08-H23";
currFile(iScanSetUps)="2022\Emittanze 2022\Scan01QuadU.xlsx";
LGENscanned(iScanSetUps)="P9-003A-LGEN";              % scanning quad
LGENscannedNickName(iScanSetUps)="U1-008A-QUE";
scanDescription(iScanSetUps)="2022-03-13 - U1-008A-QUE - C, 270 mm - primo Giro";
plotName(iScanSetUps)="U1-008A-QUE_C270_primoGiro";
clear CAMpaths DDSpaths;
CAMpaths=[
    "CarbSO1_LineU_Size6_*"
    ];
if ( ~exist('DDSpaths','var') ), DDSpaths=strings(length(CAMpaths),1); DDSpaths(:)="PRC-544-*"; end

%% indices in measurements (CAM/DDS summary files)
%   . 1st col: 1=current, 2=CAM, 3=DDS;
%   . 2nd col: min,max;
indices(1,:,iScanSetUps)=[5 44];
indices(2,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(1); % data do not allow to conclude on this - let's keep "nominal" ID shifts
indices(3,:,iScanSetUps)=indices(1,:,iScanSetUps)+iCurr2mon(2); % data do not allow to conclude on this - let's keep "nominal" ID shifts
% indices for fitting data
% - CAM
clear fitIndicesH fitIndicesV;
fitIndicesH=[14 21; 14 20; 14 19]'; % symmetric, 7 couples (min at ID=17)
fitIndicesV=[12 24; 13 22; 14 20]'; % symmetric, 7 couples (min at ID=17)
% fitIndicesH=[8 26; 9 25; 10 24; 11 23; 12 22; 13 21; 14 20]'; % symmetric, 7 couples (min at ID=17)
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
% - DDS (very similar to CAM, apart from ID-shift)
fitIndices(2,:,:,:,iScanSetUps)=fitIndices(1,:,:,:,iScanSetUps)-iCurr2mon(1)+iCurr2mon(2);
% - post processing
fitIndices(fitIndices==0)=NaN();
clear fitIndicesH fitIndicesV;
