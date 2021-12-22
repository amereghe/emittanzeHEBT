function [cyProgs,cyCodes,BARs,FWHMs,ASYMs,INTs,nData]=AcquireSummaryData(CAMPaths,DDSPaths)
    fprintf("acquiring data...\n");
    profTypes=["CAM" "DDS"];
    nProfTypes=length(profTypes);
    cyProgs=strings(1,nProfTypes); % 2nd dim: CAM and DDS
    cyCodes=strings(1,nProfTypes); % 2nd dim: CAM and DDS
    BARs=zeros(1,2,nProfTypes);    % 3rd dim: CAM and DDS
    FWHMs=zeros(1,2,nProfTypes);   % 3rd dim: CAM and DDS
    ASYMs=zeros(1,2,nProfTypes);   % 3rd dim: CAM and DDS
    INTs=zeros(1,2,nProfTypes);    % 3rd dim: CAM and DDS
    nData=zeros(nProfTypes,1);     % 1st dim: CAM and DDS

    for jProf=1:nProfTypes
        switch jProf
            case 1
                myPaths=CAMPaths;
            case 2
                myPaths=DDSPaths;
        end
        [tmpCyProgs,tmpCyCodes,tmpBARs,tmpFWHMs,tmpASYMs,tmpINTs]=ParseCAMSummaryFiles(myPaths,profTypes(jProf));
        if ( isempty(tmpCyProgs) )
            warning("...no measurements for %s! continuing...",profTypes(jProf));
        else
            fprintf("...storing data...\n");
            nData(jProf)=length(tmpCyProgs);
            BARs (1:nData(jProf),1:2,jProf)=tmpBARs;
            FWHMs(1:nData(jProf),1:2,jProf)=tmpFWHMs;
            ASYMs(1:nData(jProf),1:2,jProf)=tmpASYMs;
            INTs (1:nData(jProf),1:2,jProf)=tmpINTs;
            cyProgs(1:nData(jProf),jProf)=tmpCyProgs;
            cyCodes(1:nData(jProf),jProf)=tmpCyCodes;
            fprintf("...acquired %d cyProgs with %s;\n",nData(jProf),profTypes(jProf));
        end
    end
        
    fprintf("...done.\n");
end

