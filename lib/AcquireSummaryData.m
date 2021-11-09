function [cyProgs,cyCodes,BARs,FWHMs,ASYMs,INTs,nData]=AcquireSummaryData(CAMPaths,DDSPaths)
    fprintf("acquiring data...\n");
    nPaths=1;
    cyProgs=strings(1,2,nPaths); % CAM and DDS
    cyCodes=strings(1,2,nPaths); % CAM and DDS
    BARs=zeros(1,2,2,nPaths);    % CAM and DDS
    FWHMs=zeros(1,2,2,nPaths);   % CAM and DDS
    ASYMs=zeros(1,2,2,nPaths);   % CAM and DDS
    INTs=zeros(1,2,2,nPaths);    % CAM and DDS
    nData=zeros(2,nPaths);       % CAM and DDS
    for ii=1:nPaths
        % acquire CAM/DDS data
        [camCyProgs,camCyCodes,camBARs,camFWHMs,camASYMs,camINTs]=ParseCAMSummaryFiles(CAMPaths(ii));
        [ddsCyProgs,ddsCyCodes,ddsBARs,ddsFWHMs,ddsASYMs,ddsINTs]=ParseCAMSummaryFiles(DDSPaths(ii),"DDS");
        if ( isempty(camCyProgs) & isempty(ddsCyProgs) )
            warning("...no measurement data at all! continuing...");
            continue
        end
        % store common data
        fprintf("...storing data...\n");
        if ( ~isempty(camCyProgs) )
            nData(1,ii)=length(camCyProgs);
            BARs (1:nData(1,ii),1:2,1,ii)=camBARs;
            FWHMs(1:nData(1,ii),1:2,1,ii)=camFWHMs;
            ASYMs(1:nData(1,ii),1:2,1,ii)=camASYMs;
            INTs (1:nData(1,ii),1:2,1,ii)=camINTs;
            cyProgs(1:nData(1,ii),1,ii)=camCyProgs;
            cyCodes(1:nData(1,ii),1,ii)=camCyCodes;
        end
        if ( ~isempty(ddsCyProgs) )
            nData(2,ii)=length(ddsCyProgs);
            BARs (1:nData(2,ii),1:2,2,ii)=ddsBARs;
            FWHMs(1:nData(2,ii),1:2,2,ii)=ddsFWHMs;
            ASYMs(1:nData(2,ii),1:2,2,ii)=ddsASYMs;
            INTs (1:nData(2,ii),1:2,2,ii)=ddsINTs;
            cyProgs(1:nData(2,ii),2,ii)=ddsCyProgs;
            cyCodes(1:nData(2,ii),2,ii)=ddsCyCodes;
        end
        fprintf("...acquired %d cyProgs with CAMeretta;\n",nData(1,ii));
        fprintf("...acquired %d cyProgs with DDS;\n",nData(2,ii));
    end
    fprintf("...done.\n");
end

