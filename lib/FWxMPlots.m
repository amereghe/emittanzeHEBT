function FWxMPlots(Is,FWHMs,BARs,ReducedFWxM,fracEst,indices,scanDescription,actPlotName)
    fprintf("plotting FWxM data (scan plots)...\n");
    if ( exist('actPlotName','var') )
        ff = figure('visible','off');
        % increase by 10 figure dimensions
        ff.Position(1:2)=ff.Position(1:2)/20.;
        ff.Position(3)=ff.Position(3)*4;
        ff.Position(4)=ff.Position(4)*2;
    else
        figure();
    end
    nMons=2;
    nPlotsPerMon=5;
    nLevels=size(FWHMs,4);
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
                plot(Xs,Ys,"*-");
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
                plot(Xs,Ys,"*-");
            end
            PlotMonsBinWidth(Xs,myMon);
            % legend(string(fracEst*100)+"%","Location","best");
            grid on; xlabel("I [A]"); ylabel(sprintf("\\sigma_{%s} [mm]",planes(iPlane)));
        end
        % BAR 
        iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
        % - hor
        yyaxis left; iPlane=1;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,"*-");
        ylabel(sprintf("BAR_{%s} [mm]",planes(iPlane)));
        yyaxis right; iPlane=2;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,"*-");
        ylabel(sprintf("BAR_{%s} [mm]",planes(iPlane)));
        yyaxis left;
        grid on; xlabel("I [A]");
    end
    % general
    sgtitle(scanDescription);
    linkaxes(ax,"x");
    if ( exist('actPlotName','var') )
        MapFileOut=sprintf("%s_scans_FWxM.png",actPlotName);
        fprintf("...saving to file %s ...\n",MapFileOut);
        exportgraphics(ff,MapFileOut,'Resolution',300); % resolution=DPI
    end
    fprintf("...done.\n");
end
