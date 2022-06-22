function ShowParsedDistributions(profiles,LGENscanned,actPlotName,Is,indices)
    fprintf("plotting distributions...\n");
    if ( exist('Is','var') & exist('indices','var') )
        myRemark="aligned distributions";
    elseif ( ~exist('Is','var') & ~exist('indices','var') )
        myRemark="all distributions";
    else
        error("please provide me with both Is and indices!");
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
            if ( exist('Is','var') )
                PlotSpectra(profiles(:,[1 indices(iMon,1):indices(iMon,2) ],iPlane,iMon),false,Is(indices(1,1):indices(1,2)),"I [A]");
            else
                PlotSpectra(profiles(:,:,iPlane,iMon));
            end
            grid on; xlabel(sprintf("%s [mm]",xlabels(iPlane))); zlabel("counts []");
            title(sprintf("%s - %s",monitorNames(iMon),planeNames(iPlane)));
        end
    end
    sgtitle(sprintf("%s - %s",myRemark,LabelMe(LGENscanned)));
    
    % save figure
    if ( exist('actPlotName','var') )
        if ( strlength(actPlotName)>0 )
            if ( exist('Is','var') )
                MapFileOut=sprintf("%s_3D_reduced.fig",actPlotName);
            else
                MapFileOut=sprintf("%s_3D.fig",actPlotName);
            end
            savefig(MapFileOut);
            fprintf("...saving to file %s ...\n",MapFileOut);
        end
    end
    
    fprintf("...done.\n");
end
