function RawPlots(Is,FWHMs,BARs,INTs,nData,scanDescription,titleSeries,actPlotName)
% RawPlots               to show FWxMs, BARs and BARicentres of scans 
%                          as simple sequence of values; current values
%                          used in the scan are shown as well.
%
% input:
% - Is (float(:,1)): list of current values [A];
% - FWHMs/BARs/INTs (float(nData,2,nSeries)): list of values of FWHM and
%    BARicentre [mm], and integral of counts;
%    the column indicates the plane:
%    . 1: hor plane;
%    . 2: ver plane;
% - nData (float(nSeries,1)): number of rows in FWHMs/BARs/INTs for each
%    series;
% - scanDescription (string(1,1)): label used for the figure title;
% - titleSeries (string(nSeries,1), optional): a single label for each
%    series, e.g. indicating the name; if not given, the function
%    associates specific names
% - actPlotName (string(1,1), optional): label used to generate a .png file.
%    Please check the variable MapFileOut in this function for the
%    nomenclature. If not given, a window appears with the plot, and no
%    .png file is saved;
%    
    fprintf("plotting raw data of scans: FWHMs, BARs and Integrals vs ID...\n");
    if ( exist('actPlotNames','var') )
        ff = figure('visible','off');
        ff.Position=[ ff.Position(1:2) 1.6*ff.Position(3:4) ]; % increase the default size of the plot
    else
        figure();
    end
    if ( ~exist('titleSeries','var') || sum(ismissing(titleSeries)) )
        titleSeries=compose("Series %02i",(1:size(FWHMs,3))');
    end
    for jj=1:size(FWHMs,3)
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
            title(sprintf("%s - %s",whatName,titleSeries(jj))); legend("HOR","VER","Location","best");
        end
    end
    % corrente
    iPlot=iPlot+1;
    ax(iPlot)=subplot(3,3,iPlot);
    plot(Is,"*-");
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

