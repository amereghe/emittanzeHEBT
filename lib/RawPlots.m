function RawPlots(Is,currNData,FWHMs,BARs,INTs,nData,scanDescription,actPlotName)
    fprintf("plotting data (raw plots)...\n");
    if ( exist('actPlotNames','var') )
        ff = figure('visible','off');
        ff.Position=[ ff.Position(1:2) 1.6*ff.Position(3:4) ]; % increase the default size of the plot
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
        for kk=1:3 % FWHM,BAR,INT
            switch kk
                case 1
                    whatToShow=FWHMs; whatName="FWHM"; labelY="[mm]";
                case 2
                    whatToShow=BARs; whatName="Baricentre"; labelY="[mm]";
                case 3
                    whatToShow=INTs; whatName="integral"; labelY="[]";
            end
            iPlot=kk+(jj-1)*3;
            ax(iPlot)=subplot(3,3,iPlot);
            plot(whatToShow(1:nData(jj),1,jj),"*-"); hold on; plot(whatToShow(1:nData(jj),2,jj),"*-"); 
            grid on; ylabel(labelY); xlabel("ID []");
            title(sprintf("%s - %s",whatName,myMon)); legend("HOR","VER","Location","best");
        end
    end
    % corrente
    iPlot=iPlot+1;
    ax(iPlot)=subplot(3,3,iPlot);
    plot(Is(1:currNData),"*-");
    grid on; ylabel("[A]"); xlabel("ID []");
    title("Scan current");
    % general
    sgtitle(scanDescription);
    linkaxes(ax,"x");
    if ( exist('actPlotNames','var') )
        MapFileOut=sprintf("%s_rawData.png",actPlotName);
        exportgraphics(ff,MapFileOut,'Resolution',300); % resolution=DPI
        fprintf("...saving to file %s ...\n",MapFileOut);
    end
    fprintf("...done.\n");
end

