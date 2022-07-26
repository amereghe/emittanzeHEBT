% {}~

%% include libraries
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - include Matlab libraries
pathToLibrary="externals\ExternalMatLabTools";
addpath(genpath(pathToLibrary));
% - include local library with functions
pathToLibrary="lib";
addpath(genpath(pathToLibrary));

%% main - load infos
measPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY";
LPOWmonPath="S:\Area Ricerca\EMITTANZE SUMMARY\EMITTANZE SUMMARY\LPOW_error_log";
% LPOWmonPath="S:\Accelerating-System\Accelerator-data\Area dati MD\LPOWmonitor\ErrorLog";
% fracEst=[ 0.875 0.75 0.625 0.5 0.375 0.25 ]; % initial
% fracEst=[ 0.875 0.8125 0.75 0.6875 0.625 0.5625 0.5 0.4375 0.375 0.3125 0.25 ]; % very detailed
fracEst=[ 0.85 0.75 0.65 0.55 0.45 0.35 0.25 ]; % 
fracEstStrings=compose("frac=%g%%",fracEst*100);
mons=["CAM" "DDS"]; nMons=length(mons);
planes=["H" "V"];

% returns:
dataTree="2022-03-13";
run(sprintf("%s\\%s",dataTree,"SetMeUp_U1p008ApQUE_C270_secondoGiro.m"));
% run(sprintf("%s\\%s",dataTree,"SetMeUp_U1p014ApQUE_C270_secondoGiro.m"));
run(sprintf("%s\\%s","lib","SetUpWorkSpace.m"));
nFitSets=size(fitIndices,4);

%% main - parse data files
% - parse beam profiles
clear cyProgsProf cyCodesProf profiles nDataProf ;
[cyProgsProf,cyCodesProf,profiles,nDataProf]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths);
% - compute statistics on profiles
clear BARsProf FWHMsProf INTsProf ;
[BARsProf,FWHMsProf,INTsProf]=ComputeDistStats(profiles);
% - parse summary files
clear cyProgsSumm cyCodesSumm BARsSumm FWHMsSumm ASYMsSumm INTsSumm nDataSumm ;
[cyProgsSumm,cyCodesSumm,BARsSumm,FWHMsSumm,ASYMsSumm,INTsSumm,nDataSumm]=AcquireSummaryData(actCAMPaths,actDDSPaths);
% - parse current files
clear IsXLS LGENnamesXLS nDataCurr;
[IsXLS,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currPath);
% - parse LPOW monitor log
clear tStampsLPOWMon LGENsLPOWMon LPOWsLPOWMon racksLPOWMon repoValsLPOWMon appValsLPOWMon cyCodesLPOWMon cyProgsLPOWMon endCycsLPOWMon;
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWmonPaths);
% - cyProgs of LPOWmon are off!!!!
if ( ~ismissing(LGENsLPOWMon) )
    cyProgsLPOWMon=string(str2double(cyProgsLPOWMon)+4097); % 4097=2^12+1;
end
% - get TM currents
clear cyCodesTM rangesTM EksTM BrhosTM currentsTM fieldsTM kicksTM psNamesTM FileNameCurrentsTM ;
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machine,config);
psNamesTM=string(psNamesTM);
cyCodesTM=upper(string(cyCodesTM));
% - build table of currents
clear tableIs;
[tableIs]=BuildCurrentTable(cyCodesProf,cyProgsProf,allLGENs,IsXLS(:,LGENnamesXLS==LGENscanned),LGENscanned,psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices);

%% main - cross checks
% - raw plots (ie CAM/DDS: FWHM, bar and integral vs ID; scanned quad: I vs ID), to get indices
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,scanDescription,["CAMeretta" "DDS"]);
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,INTsProf,nDataProf,scanDescription,["CAMeretta" "DDS"],outName);
% ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,scanDescription,["CAMeretta" "DDS"]);
ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,INTsProf,nDataProf,scanDescription,["CAMeretta" "DDS"]);
% - compare data from summary files and statistics computed on profiles
CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm);
% - compare currents: LPOW error log vs xls and TM values
if ( ~ismissing(LGENsLPOWMon) )
    CompareCurrents(IsXLS,indices,LGENscanned,appValsLPOWMon,LGENsLPOWMon,allLGENs,tableIs,cyProgsSumm,cyProgsLPOWMon); % indices are based on summary data
end
% - plot distributions (3D visualisation)
myOutName=sprintf("%s_3D_aligned.fig",outName); myRemark="aligned distributions";
ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark,IsXLS(:,LGENnamesXLS==LGENscanned),indices);
for iFitSet=1:nFitSets
    myOutName=sprintf("%s_3D_fitDistributions_%02d.fig",outName,iFitSet); myRemark=sprintf("distributions to be fitted (set # %2i)",iFitSet);
    ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark,IsXLS(:,LGENnamesXLS==LGENscanned),fitIndices(:,:,:,iFitSet));
end
myOutName=sprintf("%s_3D_allIDs.fig",outName); myRemark="all distributions";
ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark);

%% main - actual analysis
% - actual plots (FWHM and baricentre vs Iscan (actual range), CAMeretta and DDS)
% ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsSumm,BARsSumm,indices,scanDescription,["CAMeretta" "DDS"],outName);
ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,indices,scanDescription,["CAMeretta" "DDS"],outName);
ShowScanAligned(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProf,BARsProf,indices,scanDescription,["CAMeretta" "DDS"]);
% - export data to xlsx files
% myOutName=sprintf("%s_SummaryData.xlsx",outName); ExportDataOverview(tableIs,allLGENs,FWHMsSumm,BARsSumm,INTsSumm,nDataSumm,indices,myOutName);
myOutName=sprintf("%s_ProfStatsData.xlsx",outName); ExportDataOverview(tableIs,allLGENs,FWHMsProf,BARsProf,INTsProf,nDataProf,indices,myOutName);
% - compute statistics on profiles at different heights
clear BARsProfScan FWHMsProfScan INTsProfScan;
[BARsProfScan,FWHMsProfScan,INTsProfScan]=ComputeDistStats(profiles,fracEst);
% - reduce values for FWxMs:
clear  ReducedFWxM;
[ReducedFWxM]=GetReducedFWxM(FWHMsProfScan,fracEst);
% - show statistics on profiles at different heights
FWxMPlots(IsXLS(:,LGENnamesXLS==LGENscanned),FWHMsProfScan,BARsProfScan,ReducedFWxM,fracEst,indices,scanDescription,outName);
% - export data to xlsx files
for iFitSet=1:nFitSets
    myOutName=sprintf("%s_FWxM_%02d.xlsx",outName,iFitSet); ExportDataFWxM(tableIs,allLGENs,FWHMsProfScan,BARsProfScan,fracEst,nDataProf,fitIndices(:,:,:,iFitSet),myOutName);
    myOutName=sprintf("%s_SIGxM_%02d.xlsx",outName,iFitSet); ExportDataFWxM(tableIs,allLGENs,ReducedFWxM,BARsProfScan,fracEst,nDataProf,fitIndices(:,:,:,iFitSet),myOutName,true);
end

%% main - MADX part
myMon="CAM"; iMon=find(strcmpi(myMon,mons));
nMaxFitData=max(fitIndices(iMon+1,2,1,:))-min(fitIndices(iMon+1,1,1,:))+1;
if ( size(fitIndices,3)==2 )
    nMaxFitData=max(nMaxFitData,max(fitIndices(iMon+1,2,2,:))-min(fitIndices(iMon+1,1,2,:))+1);
end

%% export MADX table, to compute response matrices of scan
MADXFileName=sprintf("%s_%s.tfs",outName,myMon);
nCols=size(tableIs,2);
header=allLGENs+" [A]";
headerTypes=strings(1,nCols);
headerTypes(:)="%le";
ExportMADXtable(MADXFileName,scanDescription,tableIs(indices(1,1):indices(1,2),:,iMon),header,headerTypes);

%% read MADX tfs table with response matrices of scan
reMatFileName=sprintf("externals\\optics\\HEBT\\%s_%s_ReMat.tfs",plotName,myMon);
fprintf('parsing file %s ...\n',reMatFileName);
rMatrix = readmatrix(reMatFileName,'HeaderLines',1,'Delimiter',',','FileType','text');
clear TM;
for iPlane=1:length(planes)
    TM(:,:,:,iPlane)=GetTransMatrix(rMatrix,planes(iPlane),"SCAN");
end

%% fit data
% sigdpp=0:5E-5:1E-3;
% sigdpp=0:1E-3:1E-3;
sigdpp=[ 0.0 1E-3 ];
sigdppStrings=compose("sigdpp=%g",sigdpp);
clear beta0 alpha0 emiG z pz dz dpz avedpp;
beta0=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
alpha0=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
emiG=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
z=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
pz=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
dz=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
dpz=NaN(length(sigdpp),length(fracEst),length(planes),nFitSets);
avedpp=NaN(length(fracEst),length(planes),nFitSets);
TT=NaN(nMaxFitData,length(fracEst),length(planes),nFitSets);
SS=NaN(nMaxFitData,length(fracEst),length(planes),nFitSets);
for iPlane=1:length(planes)
    for iFrac=1:length(fracEst)
        for iFitSet=1:nFitSets
            if ( size(fitIndices,3)==2 )
                % - range of data set to consider:
                iMinFit=fitIndices(iMon+1,1,iPlane,iFitSet);
                iMaxFit=fitIndices(iMon+1,2,iPlane,iFitSet);
                % - corresponding range in current:
                jMinFit=find(indices(1,1):indices(1,2)==fitIndices(1,1,iPlane,iFitSet));
                jMaxFit=find(indices(1,1):indices(1,2)==fitIndices(1,2,iPlane,iFitSet));
            else
                % - range of data set to consider:
                iMinFit=fitIndices(iMon+1,1,1,iFitSet);
                iMaxFit=fitIndices(iMon+1,2,1,iFitSet);
                % - corresponding range in current:
                jMinFit=find(indices(1,1):indices(1,2)==fitIndices(1,1,iFitSet));
                jMaxFit=find(indices(1,1):indices(1,2)==fitIndices(1,2,iFitSet));
            end
            nFit=iMaxFit-iMinFit+1;
            % - baricentres and sigmas:
            TT(1:nFit,iFrac,iPlane,iFitSet)=BARsProfScan(iMinFit:iMaxFit,iPlane,iMon);
            SS(1:nFit,iFrac,iPlane,iFitSet)=ReducedFWxM(iMinFit:iMaxFit,iPlane,iMon,iFrac);
            % - perform fit:
            [beta0(:,iFrac,iPlane,iFitSet),alpha0(:,iFrac,iPlane,iFitSet),emiG(:,iFrac,iPlane,iFitSet),...
                dz(:,iFrac,iPlane,iFitSet),dpz(:,iFrac,iPlane,iFitSet),~]=FitOpticsThroughSigmaData(TM(:,:,jMinFit:jMaxFit,iPlane),SS(1:nFit,iFrac,iPlane,iFitSet),sigdpp);
            [z(:,iFrac,iPlane,iFitSet),pz(:,iFrac,iPlane,iFitSet),avedpp(iFrac,iPlane,iFitSet)]=FitOpticsThroughOrbitData(TM(:,:,jMinFit:jMaxFit,iPlane),TT(1:nFit,iFrac,iPlane,iFitSet),dz(:,iFrac,iPlane,iFitSet),dpz(:,iFrac,iPlane,iFitSet));
        end
    end
end

%%

% show fitted parameters
for iPlane=1:length(planes)
    for iFitSet=1:nFitSets
        ShowFittedOpticsFunctions(beta0(:,:,iPlane,iFitSet),alpha0(:,:,iPlane,iFitSet),emiG(:,:,iPlane,iFitSet),dz(:,:,iPlane,iFitSet),dpz(:,:,iPlane,iFitSet),sigdpp,planes(iPlane),fracEstStrings);
        ShowFittedOrbits(z(:,:,iPlane,iFitSet),pz(:,:,iPlane,iFitSet),dz(:,:,iPlane,iFitSet),dpz(:,:,iPlane,iFitSet),planes(iPlane),avedpp(:,iPlane,iFitSet),fracEstStrings);
    end
end
ShowFittedOpticsFunctionsGrouped(beta0,alpha0,emiG,dz,dpz,z,pz,fracEst,"FWxM []",planes,compose("fit set #%2d",1:nFitSets),sigdppStrings,myMon);
ShowFittedEllipsesGrouped(beta0,alpha0,emiG,planes,compose("fit set #%2d",1:nFitSets),fracEstStrings,sigdppStrings,myMon);

%% show fits
clear gamma0; gamma0=(1+alpha0.^2)./beta0; % same size as alpha0 and beta0
clear calcSigmas; calcSigmas=NaN(nMaxFitData,length(sigdpp),length(fracEst),length(planes),nFitSets);
clear calcBars; calcBars=NaN(nMaxFitData,length(sigdpp),1,length(planes),nFitSets);
clear scanCurrents; scanCurrents=NaN(nMaxFitData,length(planes),nFitSets);
for iFitSet=1:nFitSets
    for iPlane=1:length(planes)
        % - range if data set to consider:
        if ( size(fitIndices,3)==2 )
            jMinFit=find(indices(1,1):indices(1,2)==fitIndices(1,1,iPlane,iFitSet));
            jMaxFit=find(indices(1,1):indices(1,2)==fitIndices(1,2,iPlane,iFitSet));
        else
            jMinFit=find(indices(1,1):indices(1,2)==fitIndices(1,1,1,iFitSet));
            jMaxFit=find(indices(1,1):indices(1,2)==fitIndices(1,2,1,iFitSet));
        end
        nFit=jMaxFit-jMinFit+1;
        for iFrac=1:length(fracEst)
            % - actually transport optics
            clear betaO alphaO gammaO;
            [betaO,alphaO,gammaO]=TransportOptics(TM(1:2,1:2,jMinFit:jMaxFit,iPlane),beta0(:,iFrac,iPlane,iFitSet),alpha0(:,iFrac,iPlane,iFitSet),gamma0(:,iFrac,iPlane,iFitSet));
            clear dO dpO;
            [dO,dpO]=TransportOrbit(TM(1:2,1:2,jMinFit:jMaxFit,iPlane),dz(:,iFrac,iPlane,iFitSet),dpz(:,iFrac,iPlane,iFitSet));
            % - fix NaNs
            dO(isnan(dO))=0.0; dpO(isnan(dpO))=0.0; 
            % - compute sigmas
            calcSigmas(1:nFit,:,iFrac,iPlane,iFitSet)=sqrt(betaO.*repmat(emiG(:,iFrac,iPlane,iFitSet)',size(betaO,1),1)+(dO.*repmat(sigdpp,size(dO,1),1)).^2);
            % - transport baricentre (for the time being, independent of fractEst)
            if ( iFrac==1 )
                [calcBars(1:nFit,:,iFrac,iPlane,iFitSet),~]=TransportOrbit(TM(1:2,1:2,jMinFit:jMaxFit,iPlane),z(:,iFrac,iPlane,iFitSet),pz(:,iFrac,iPlane,iFitSet));
            end
        end
        % - keep track of currents
        scanCurrents(1:nFit,iPlane,iFitSet)=tableIs(jMinFit:jMaxFit,LGENnamesXLS==LGENscanned,iMon);
    end
end
% - set of measurements for fit:
clear measSigma measBARs measCurr;
measSigma=NaN(nMaxFitData,length(planes),nFitSets);
measBARs=NaN(nMaxFitData,length(planes));
measCurr=NaN(nMaxFitData,length(planes));
for iPlane=1:length(planes)
    if ( size(fitIndices,3)==2 )
        % - range of data set to consider:
        iMinFit=min(fitIndices(iMon+1,1,iPlane,:));
        iMaxFit=max(fitIndices(iMon+1,2,iPlane,:));
        % - corresponding range in current:
        jMinFit=find(indices(1,1):indices(1,2)==min(fitIndices(1,1,iPlane,:)));
        jMaxFit=find(indices(1,1):indices(1,2)==max(fitIndices(1,2,iPlane,:)));
    else
        % - range of data set to consider:
        iMinFit=min(fitIndices(iMon+1,1,1,:));
        iMaxFit=max(fitIndices(iMon+1,2,1,:));
        % - corresponding range in current:
        jMinFit=find(indices(1,1):indices(1,2)==min(fitIndices(1,1,1,:)));
        jMaxFit=find(indices(1,1):indices(1,2)==max(fitIndices(1,2,1,:)));
    end
    nFit=iMaxFit-iMinFit+1;
    measSigma(1:nFit,iPlane,1:nFitSets)=reshape(ReducedFWxM(iMinFit:iMaxFit,iPlane,iMon,:),nFit,1,nFitSets);
    measBARs(1:nFit,iPlane)=BARsProfScan(iMinFit:iMaxFit,iPlane,iMon);
    measCurr(1:nFit,iPlane)=tableIs(jMinFit:jMaxFit,LGENnamesXLS==LGENscanned,iMon);
end
CompareFits(calcSigmas,scanCurrents,measSigma,measCurr,"SIG",sigdppStrings,fracEstStrings,planes,sprintf("I_{%s} [A]",LGENscanned),compose("fit set #%2d",1:nFitSets),myMon);
CompareFits(calcBars,scanCurrents,measBARs,measCurr,"BAR",sigdppStrings,fracEstStrings,planes,sprintf("I_{%s} [A]",LGENscanned),compose("fit set #%2d",1:nFitSets),myMon);

%%
iFrac=4; iPlane=1;
% myAlpha0=(-10:0.5:10)'; myBeta0=50*ones(length(myAlpha0),1);
myBeta0=(31:5:91)'; myAlpha0=-9*ones(length(myBeta0),1);
myEmig=0.15E-6; myGamma0=(1+myAlpha0.^2)./myBeta0; 
[myBetaO,myAlphaO,myGammaO]=TransportOptics(TM(1:2,1:2,:,iPlane),myBeta0,myAlpha0,myGamma0);
myCalcSigma=sqrt(myBetaO.*myEmig);
% CompareFits(myCalcSigma,SS(:,iFrac,iPlane),compose("\\alpha=%g",myAlpha0),fracEstStrings,planes(iPlane),scanCurrents,sprintf("I_{%s} [A]",LGENscanned));
CompareFits(myCalcSigma,SS(:,iFrac,iPlane),compose("\\beta=%g",myBeta0),fracEstStrings,planes(iPlane),scanCurrents,sprintf("I_{%s} [A]",LGENscanned));
