function CompareProfilesSummary(profBARs,profFWHMs,profINTs,BARs,FWHMs,INTs)
    figure();
    nCols=3; % INTs, FWHMs, BARs
    nRows=2; % CAMeretta and DDS
    nDataProf=size(profFWHMs,1);
    nDataSumm=size(FWHMs,1);
    iPlot=0;
    for iRow=1:nRows
        switch iRow
            case 1
                myTit="CAMeretta";
            case 2
                myTit="DDS";
        end
        for iCol=1:nCols
            iPlot=iPlot+1;
            switch iCol
                case 1
                    whatProf=profFWHMs; whatSumm=FWHMs; myYLab="FWHM [mm]";
                case 2
                    whatProf=profBARs; whatSumm=BARs; myYLab="BAR [mm]";
                case 3
                    whatProf=profINTs; whatSumm=INTs; myYLab="INT []";
            end
            subplot(nRows,nCols,iPlot);
            for iPlane=1:2
                if ( iPlane>1 ), hold on; end
                plot([1:nDataProf],whatProf(:,iPlane,iRow),"o",...
                     [1:nDataSumm],whatSumm(:,iPlane,iRow),"*");
            end
            xlabel("ID []"); ylabel(myYLab); grid on; title(myTit);
            if ( iCol==3 ), set(gca, 'YScale', 'log'); end
            legend("hor - prof","hor - summ","ver - prof","ver - summ","location","best");
        end
    end
end
