function FWxMPlots(Is,FWHMs,BARs,ReducedFWxM,fracEst,indices,scanDescription,actPlotName)
    fprintf("plotting FWxM data (scan plots)...\n");
    figure();
    nMons=2;
    nPlotsPerMon=5;
    nLevels=size(FWHMs,4);
    cm=colormap(parula(nLevels));
    planes=[ "HOR" "VER" ];
    iPlot=0;
    Xs=Is(indices(1,1):indices(1,2));
    for iMon=1:nMons % CAMeretta,DDS
        switch iMon
            case 1
                myMon="CAMeretta";
            case 2
                myMon="DDS";
        end
        % FWxM
        for iPlane=1:length(planes)
            iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
            for iLev=1:nLevels
                if (iLev>1), hold on; end
                Ys=FWHMs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon,iLev);
                plot(Xs,Ys,".-","Color",cm(iLev,:));
            end
            PlotMonsBinWidth(Xs,myMon);
            if (iPlot==1), legend(string(fracEst*100)+"%","Location","best"); end
            grid on; xlabel("I [A]"); ylabel(sprintf("FWxM_{%s} [mm]",planes(iPlane)));
        end
        % normalised FWxM
        for iPlane=1:length(planes)
            iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
            for iLev=1:nLevels
                if (iLev>1), hold on; end
                Ys=ReducedFWxM(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon,iLev);
                plot(Xs,Ys,".-","Color",cm(iLev,:));
            end
            PlotMonsBinWidth(Xs,myMon);
            % legend(string(fracEst*100)+"%","Location","best");
            grid on; xlabel("I [A]"); ylabel(sprintf("\\sigma_{%s} [mm]",planes(iPlane)));
        end
        % BAR 
        iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
        % - hor
        yyaxis left; iPlane=1;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,".-");
        ylabel(sprintf("BAR_{%s} [mm]",planes(iPlane)));
        yyaxis right; iPlane=2;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,".-");
        ylabel(sprintf("BAR_{%s} [mm]",planes(iPlane)));
        yyaxis left;
        grid on; xlabel("I [A]");
    end
    % general
    sgtitle(scanDescription);
    linkaxes(ax,"x");
    if ( exist('actPlotName','var') )
        MapFileOut=sprintf("%s_scans_FWxM.fig",actPlotName);
        savefig(MapFileOut);
        fprintf("...saving to file %s ...\n",MapFileOut);
    end
    fprintf("...done.\n");
end
