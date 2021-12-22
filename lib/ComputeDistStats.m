function [BARs,FWHMs,INTs]=ComputeDistStats(profiles,fracEst)
    fprintf("computing stats...\n");
    if ( exist('fracEst','var') )
        fprintf("...at height(s) different from default ones!\n");
        nCases=length(fracEst);
    else
        nCases=1;
    end
    nDataSets=size(profiles,2)-1;
    nMonitors=size(profiles,3);
    BARs=zeros(nDataSets,2,nMonitors);         % 2: hor/ver; 3: CAM/DDS
    FWHMs=zeros(nDataSets,2,nMonitors,nCases); % 2: hor/ver; 3: CAM/DDS
    INTs=zeros(nDataSets,2,nMonitors);         % 2: hor/ver; 3: CAM/DDS
    if ( exist('fracEst','var') )
        fprintf("...using the same algorithm for DDS and CAMeretta!\n");
        for ii=1:size(profiles,4)
            [BARs(:,:,ii),FWHMs(:,:,ii,:),INTs(:,:,ii)]=StatDistributions(profiles(:,:,:,ii),fracEst);
        end
    else
        for ii=1:2 % 1:CAMeretta; 2:DDS;
            switch ii
                case 1
                    fprintf("...CAMeretta...\n");
                    [BARs(:,:,ii),FWHMs(:,:,ii),INTs(:,:,ii)]=StatDistributionsCAMProcedure(profiles(:,:,:,ii));
                case 2
                    fprintf("...DDS...\n");
                    [BARs(:,:,ii),FWHMs(:,:,ii),INTs(:,:,ii)]=StatDistributionsBDProcedure(profiles(:,:,:,ii));
            end
        end
    end
    fprintf("...done!\n");
end