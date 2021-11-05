function ScanPlots(Is,FWHMs,BARs,indices,descs,actPlotNames)
    fprintf("plotting data (scan plots)...\n");
    nScans=size(Is,2);
    for ii=1:nScans
        if ( exist('actPlotNames','var') )
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
                plot(Is(indices(3,1,ii):indices(3,2,ii),ii),whatToShow(indices(jj,1,ii):indices(jj,2,ii),1,jj,ii),"*-"); ylabel(sprintf("HOR %s",labelY));
                yyaxis right;
                plot(Is(indices(3,1,ii):indices(3,2,ii),ii),whatToShow(indices(jj,1,ii):indices(jj,2,ii),2,jj,ii),"*-"); ylabel(sprintf("VER %s",labelY));
                yyaxis left;
                grid on; xlabel("I [A]");
                title(sprintf("%s - %s",whatName,myMon)); % legend("HOR","VER","Location","best");
            end
        end
        % general
        sgtitle(descs(ii));
        linkaxes(ax,"x");
        if ( exist('actPlotNames','var') )
            MapFileOut=sprintf("%s_scans.png",actPlotNames);
            exportgraphics(ff,MapFileOut,'Resolution',300); % resolution=DPI
            fprintf("...saving to file %s ...\n",MapFileOut);
        end
    end
    fprintf("...done.\n");
end
