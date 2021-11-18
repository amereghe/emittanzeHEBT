function [BARs,FWHMs,INTs]=StatDistributions(profiles)
    fprintf("computing stats...\n");
    nDataSets=size(profiles,2)-1;
    BARs=zeros(nDataSets,2,2); % 2: hor/ver; 3: CAM/DDS
    FWHMs=zeros(nDataSets,2,2); % 2: hor/ver; 3: CAM/DDS
    INTs=zeros(nDataSets,2,2); % 2: hor/ver; 3: CAM/DDS
    for ii=1:2 % 1:CAMeretta; 2:DDS;
        switch ii
            case 1
                fprintf("...CAMeretta...\n");
                [BARs(:,:,ii),FWHMs(:,:,ii),INTs(:,:,ii)]=StatDistributionsCAMProcedure(profiles(:,:,:,ii,:));
            case 2
                fprintf("...DDS...\n");
                [BARs(:,:,ii),FWHMs(:,:,ii),INTs(:,:,ii)]=StatDistributionsBDProcedure(profiles(:,:,:,ii,:));
        end
    end
    fprintf("...done!\n");
end