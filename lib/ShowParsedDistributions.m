function ShowParsedDistributions(profiles,LGENscanned,myOutName,myRemark,Is,indicesMon,indicesCur)
    fprintf("plotting distributions...\n");
    if ( ( exist('Is','var') & ~exist('indicesMon','var') ) || ( exist('indicesMon','var') & ~exist('indicesCur','var') ) )
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
                if ( size(indicesMon,3)==1 )
                   PlotSpectra(profiles(:,[0 indicesMon(iMon,1):indicesMon(iMon,2)]+1,iPlane,iMon),false,Is(indicesCur(iMon,1):indicesCur(iMon,2)),"I [A]");
                else
                   PlotSpectra(profiles(:,[0 indicesMon(iMon,1,iPlane):indicesMon(iMon,2,iPlane)]+1,iPlane,iMon),false,Is(indicesCur(1,1,iPlane):indicesCur(1,2,iPlane)),"I [A]");
                end
            else
                PlotSpectra(profiles(:,:,iPlane,iMon));
            end
            grid on; xlabel(sprintf("%s [mm]",xlabels(iPlane))); zlabel("counts []");
            title(sprintf("%s - %s",monitorNames(iMon),planeNames(iPlane)));
        end
    end
    sgtitle(sprintf("%s - %s",myRemark,LabelMe(LGENscanned)));
    
    % save figure
    if ( exist('myOutName','var') )
        if ( strlength(myOutName)>0 )
            savefig(myOutName);
            fprintf("...saving to file %s ...\n",myOutName);
        end
    end
    
    fprintf("...done.\n");
end
