function ScanPlots(Is,FWHMs,BARs,indices,scanDescription,actPlotName)
    fprintf("plotting data (scan plots)...\n");
    if ( exist('actPlotName','var') )
        ff = figure('visible','off');
    else
        figure();
    end
    for jj=1:2 % CAMeretta,DDS
        switch jj
            case 1
                myMon="CAMeretta";
            case 2
                myMon="DDS";
        end
        for kk=1:2 % FWHM,BAR
            switch kk
                case 1
                    whatToShow=FWHMs; whatName="FWHM"; labelY="[mm]";
                case 2
                    whatToShow=BARs; whatName="Baricentre"; labelY="[mm]";
            end
            iPlot=kk+(jj-1)*2;
            ax(iPlot)=subplot(2,2,iPlot);
            yyaxis left;
            plot(Is(indices(3,1):indices(3,2)),whatToShow(indices(jj,1):indices(jj,2),1,jj),"*-"); ylabel(sprintf("HOR %s",labelY));
            yyaxis right;
            plot(Is(indices(3,1):indices(3,2)),whatToShow(indices(jj,1):indices(jj,2),2,jj),"*-"); ylabel(sprintf("VER %s",labelY));
            yyaxis left;
            grid on; xlabel("I [A]");
            title(sprintf("%s - %s",whatName,myMon)); % legend("HOR","VER","Location","best");
        end
    end
    % general
    sgtitle(scanDescription);
    linkaxes(ax,"x");
    if ( exist('actPlotName','var') )
        MapFileOut=sprintf("%s_scans.png",actPlotName);
        fprintf("...saving to file %s ...\n",MapFileOut);
        exportgraphics(ff,MapFileOut,'Resolution',300); % resolution=DPI
    end
    fprintf("...done.\n");
end
