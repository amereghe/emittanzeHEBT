function [cyProgs,cyCodes,profiles,nData]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths)
    fprintf("acquiring distributions...\n");
    nPaths=max(length(CAMProfsPaths),length(DDSProfsPaths));
    if ( nPaths==0 )
        warning("...no paths given!");
        cyProgs=missing(); cyCodes=missing(); profiles=missing(); nData=missing();
        return
    end
    
    profiles=zeros(1,2,2,2,1);    % 1:fiber_pos; 2:z,data; 3:hor/ver; 4:CAM/DDS; 5:nPaths;
    cyProgs=strings(1,2,nPaths);  % CAM and DDS
    cyCodes=strings(1,2,nPaths);  % CAM and DDS
    nData=zeros(2,nPaths);        % CAM and DDS
    
    % acquire CAMeretta profiles
    if ( length(CAMProfsPaths)>0 )
        for ii=1:length(CAMProfsPaths)
            [camProfiles,camCyCodes,camCyProgs]=ParseDDSProfiles(CAMProfsPaths(ii),"CAM");
            profiles(1:size(camProfiles,1),1:size(camProfiles,2),1:size(camProfiles,3),1,ii)=camProfiles;
            nData(1,ii)=length(camCyProgs);
            cyProgs(1:nData(1,ii),1,ii)=camCyProgs;
            cyCodes(1:nData(1,ii),1,ii)=camCyCodes;
            fprintf("...acquired %d cyProgs with CAMeretta;\n",nData(1,ii));
        end
    end
    % acquire DDS profiles
    if ( length(DDSProfsPaths)>0 )
        for ii=1:length(DDSProfsPaths)
            [ddsProfiles,ddsCyCodes,ddsCyProgs]=ParseDDSProfiles(DDSProfsPaths(ii),"DDS");
            profiles(1:size(ddsProfiles,1),1:size(ddsProfiles,2),1:size(ddsProfiles,3),2,ii)=ddsProfiles;
            nData(2,ii)=length(ddsCyProgs);
            cyProgs(1:nData(2,ii),2,ii)=ddsCyProgs;
            cyCodes(1:nData(2,ii),2,ii)=ddsCyCodes;
            fprintf("...acquired %d cyProgs with DDS;\n",nData(2,ii));
        end
    end
    
    fprintf("...done.\n");
end

