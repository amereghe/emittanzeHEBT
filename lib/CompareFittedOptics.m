function CompareFittedOptics(xVals,yVals,myXLabel,myYLabel,RowNames,ColNames,SeriesNames,myTitle,outName,filterX,filterY)
    if ( exist("filterX","var") && exist("filterY","var") ), lFilter=true; end
    if ( ~exist("filterY","var") ), lFilter=false; end
    nRows=length(RowNames); % eg: mons
    nCols=length(ColNames); % eg: scanDescription
    nSeries=length(SeriesNames); % eg: fitSet
    
    %% actual plotting
    ff=figure();
    cm=colormap(parula(nSeries));
    ff.Position(1:2)=[0 0]; % figure at lower-left corner of screen
    ff.Position(3)=ff.Position(3)*nCols*(2./3.); % larger figure:
    ff.Position(4)=ff.Position(4)*nRows*(2./3.); % larger figure:
    t = tiledlayout(nRows,nCols+1,'TileSpacing','Compact','Padding','Compact'); % minimise whitespace around plots
    iPlot=0;
    for iRow=1:nRows
        for iCol=1:nCols
            iPlot=iPlot+1; axs(iRow,iCol)=nexttile; % subplot(nRows,nCols+1,iPlot); %#ok<*AGROW>
            if ( lFilter )
                plot(xVals(filterX(:,iRow,iCol)),yVals(filterX(:,iRow,iCol),filterY(:,iRow,iCol),iRow,iCol),"k*"); hold on
            end
            lFirst=true;
            for iSeries=1:nSeries
                if ( any(~isnan(yVals(:,iSeries,iRow,iCol))) )
                    if ( lFirst ), lFirst=false; else, hold on; end
                    plot(xVals,yVals(:,iSeries,iRow,iCol),".-","color",cm(iSeries,:));
                end
            end
            grid(); xlabel(myXLabel); ylabel(myYLabel); title(sprintf("%s - %s",RowNames(iRow),ColNames(iCol)));
        end
        if ( iRow==1 )
            % legend
            iPlot=iPlot+1; nexttile; % subplot(nRows,nCols+1,iPlot);
            if ( lFilter ), plot(NaN,NaN,"k*"); hold on; end
            lFirst=true;
            for iSeries=1:nSeries
                if ( lFirst ), lFirst=false; else, hold on; end
                plot(NaN,NaN,".-","color",cm(iSeries,:));
            end
            myLegends=SeriesNames;
            if ( lFilter ), myLegends=["filtered" myLegends]; end
            legend(myLegends,"Location","best");
        end
    end

    %% general
    sgtitle(myTitle);
    for iRow=1:nRows
        linkaxes(axs(iRow,:),"xy");
    end
    
    %% save figure
    if ( exist('outName','var') )
        if ( strlength(outName)>0 )
            savefig(outName);
            fprintf("...saving to file %s ...\n",outName);
        end
    end
end
