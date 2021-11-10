function ShowParsedDistributions(profiles,Is,LGENnames,indices)
    fprintf("plotting distributions...\n");
    if ( exist('indices','var') )
        myRemark="aligned distributions";
    else
        myRemark="all distributions";
    end
    nPaths=size(profiles,5);
    monitorNames=[ "CAMeretta" "DDS" ];
    planeNames=[ "Hor plane" "Ver plane" ];
    xlabels=[ "x" "y" ];
    for iPath=1:nPaths
        figure();
        iPlot=0;
        for iMon=1:2
            for iPlane=1:2
                iPlot=iPlot+1;
                subplot(2,2,iPlot);
                if ( exist('indices','var') )
                    PlotSpectra(profiles(:,[1 indices(iMon,1,iPath):indices(iMon,2,iPath) ],iPlane,iMon,iPath),false,Is(indices(3,1,iPath):indices(3,2,iPath),iPath),"I [A]");
                else
                    PlotSpectra(profiles(:,:,iPlane,iMon,iPath));
                end
                grid on; xlabel(sprintf("%s [mm]",xlabels(iPlane))); zlabel("counts []");
                title(sprintf("%s - %s",monitorNames(iMon),planeNames(iPlane)));
            end
        end
        sgtitle(sprintf("%s - %s",myRemark,LabelMe(LGENnames(iPath))));
    end
    fprintf("...done.\n");
end