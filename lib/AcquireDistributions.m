function [cyProgs,cyCodes,profiles,nData]=AcquireDistributions(CAMProfsPaths,DDSProfsPaths)
    fprintf("acquiring distributions...\n");
    profTypes=["CAM" "DDS"];
    nProfTypes=length(profTypes);
    nPaths=max(length(CAMProfsPaths),length(DDSProfsPaths));
    if ( nPaths==0 )
        warning("...no paths given!");
        cyProgs=missing(); cyCodes=missing(); profiles=missing(); nData=missing();
        return
    end
    
    profiles=zeros(1,2,2,nProfTypes); % 1:fiber_pos; 2:z,data; 3:hor/ver; 4:CAM/DDS;
    cyProgs=strings(1,nProfTypes);    % CAM and DDS
    cyCodes=strings(1,nProfTypes);    % CAM and DDS
    nData=zeros(nProfTypes,1);        % CAM and DDS
    
    for jProf=1:nProfTypes
        switch jProf
            case 1
                myPaths=CAMProfsPaths;
            case 2
                myPaths=DDSProfsPaths;
        end
        % acquire profiles
        if ( length(myPaths)>0 )
            [tmpProfiles,tmpCyCodes,tmpCyProgs]=ParseDDSProfiles(myPaths,profTypes(jProf));
            profiles(1:size(tmpProfiles,1),1:size(tmpProfiles,2),1:size(tmpProfiles,3),jProf)=tmpProfiles;
            nData(jProf)=length(tmpCyProgs);
            cyProgs(1:nData(jProf),jProf)=tmpCyProgs;
            cyCodes(1:nData(jProf),jProf)=tmpCyCodes;
            fprintf("...acquired %d %s profiles;\n",nData(1),profTypes(jProf));
        end
    end
    
    fprintf("...done.\n");
end

