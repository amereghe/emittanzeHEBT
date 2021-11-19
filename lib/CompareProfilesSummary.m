function CompareProfilesSummary(BARsProf,FWHMsProf,INTsProf,BARsSumm,FWHMsSumm,INTsSumm,cyProgsProf,cyProgsSumm)
    fprintf("comparing stats based on profiles and stats based on summary files...\n");
    if ( ~exist('cyProgsSumm','var') & exist('cyProgsProf','var') )
        warning("...you gave me cyProgs from profiles but not those from the summary! Ignoring available info...");
    end
    figure();
    nCols=3; % INTs, FWHMs, BARs
    nRows=2; % CAMeretta and DDS
    nDataProf=size(FWHMsProf,1);
    nDataSumm=size(FWHMsSumm,1);
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
                    whatProf=FWHMsProf; whatSumm=FWHMsSumm; myYLab="FWHM [mm]";
                case 2
                    whatProf=BARsProf; whatSumm=BARsSumm; myYLab="BAR [mm]";
                case 3
                    whatProf=INTsProf; whatSumm=INTsSumm; myYLab="INT []";
            end
            subplot(nRows,nCols,iPlot);
            for iPlane=1:2
                if ( iPlane>1 ), hold on; end
                if ( exist('cyProgsProf','var') & exist('cyProgsSumm','var') )
                    xDataProf=str2double(cyProgsProf(:,iRow));
                    xDataSumm=str2double(cyProgsSumm(:,iRow));
                else
                    xDataProf=1:nDataProf;
                    xDataSumm=1:nDataSumm;
                end
                plot(xDataProf,whatProf(:,iPlane,iRow),"o",...
                     xDataSumm,whatSumm(:,iPlane,iRow),"*");
            end
            if ( exist('cyProgsProf','var') & exist('cyProgsSumm','var') )
                xlabel("cyProgs []");
            else
                xlabel("ID []");
            end
            ylabel(myYLab); grid on; title(myTit);
            if ( iCol==3 ), set(gca, 'YScale', 'log'); end
            legend("hor - prof","hor - summ","ver - prof","ver - summ","location","best");
        end
    end
    fprintf("...end.\n");
end
