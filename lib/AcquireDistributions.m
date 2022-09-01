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
    
    profiles=missing();               % 1:fiber_pos; 2:z,data; 3:hor/ver; 4:CAM/DDS;
    cyProgs=missing();                % CAM and DDS
    cyCodes=missing();                % CAM and DDS
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
            nData(jProf)=length(tmpCyProgs);
            profiles=ExpandMat(profiles,tmpProfiles); clear tmpProfiles;
            cyCodes=ExpandMat(cyCodes,tmpCyCodes); clear tmpCyCodes;
            cyProgs=ExpandMat(cyProgs,tmpCyProgs); clear tmpCyProgs;
            fprintf("...acquired %d %s profiles;\n",nData(1),profTypes(jProf));
        end
    end
    
    fprintf("...done.\n");
end

