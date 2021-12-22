function ShowParsedDistributions(profiles,Is,LGENscanned,indices)
    fprintf("plotting distributions...\n");
    if ( exist('indices','var') )
        myRemark="aligned distributions";
    else
        myRemark="all distributions";
    end
    monitorNames=[ "CAMeretta" "DDS" ];
    planeNames=[ "Hor plane" "Ver plane" ];
    xlabels=[ "x" "y" ];
    figure();
    iPlot=0;
    for iMon=1:2
        for iPlane=1:2
            iPlot=iPlot+1;
            subplot(2,2,iPlot);
            if ( exist('indices','var') )
                PlotSpectra(profiles(:,[1 indices(iMon,1):indices(iMon,2) ],iPlane,iMon),false,Is(indices(3,1):indices(3,2)),"I [A]");
            else
                PlotSpectra(profiles(:,:,iPlane,iMon));
            end
            grid on; xlabel(sprintf("%s [mm]",xlabels(iPlane))); zlabel("counts []");
            title(sprintf("%s - %s",monitorNames(iMon),planeNames(iPlane)));
        end
    end
    sgtitle(sprintf("%s - %s",myRemark,LabelMe(LGENscanned)));
    fprintf("...done.\n");
end