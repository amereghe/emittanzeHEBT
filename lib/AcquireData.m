function [Is,cyProgs,cyCodes,BARs,FWHMs,ASYMs,INTs,nData]=AcquireData(currPaths,CAMPaths,DDSPaths,LGENnames)
    fprintf("acquiring data...\n");
    nPaths=length(currPaths);
    Is=zeros(1,nPaths);
    cyProgs=strings(1,2,nPaths); % CAM and DDS
    cyCodes=strings(1,2,nPaths); % CAM and DDS
    BARs=zeros(1,2,2,nPaths);    % CAM and DDS
    FWHMs=zeros(1,2,2,nPaths);   % CAM and DDS
    ASYMs=zeros(1,2,2,nPaths);   % CAM and DDS
    INTs=zeros(1,2,2,nPaths);    % CAM and DDS
    nData=zeros(3,nPaths);       % CAM, DDS and current
    for ii=1:nPaths
        % acquire currents
        tmpIs=AcquireCurrent(currPaths(ii),LGENnames(ii));
        nData(3,ii)=length(tmpIs);
        Is(1:nData(3,ii),ii)=tmpIs;
        fprintf("...acquired %d current values;\n",nData(3,ii));
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

