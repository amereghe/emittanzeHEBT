function ShowFittedEllipsesGrouped(beta,alpha,emiG,nMaxPerPlane,planeLabs,labCouple,labsLegend,myTit,outName)
    nSetsPerPlot=size(beta,1); nSig=1;
    nCoupledPlots=max(nMaxPerPlane);
    [nRows,nCols]=GetNrowsNcols(nCoupledPlots);
    if ( nRows*nCols==nCoupledPlots ), nRows=nRows+1; end
    
    %% actually plot
    ff=figure();
    cm=colormap(parula(nSetsPerPlot));
    ff.Position(1:2)=[0 0]; % figure at lower-left corner of screen
    ff.Position(3)=ff.Position(3)*nCols*(2./3.); % larger figure:
    ff.Position(4)=ff.Position(4)*nRows*(2./3.); % larger figure:
    t = tiledlayout(nRows,2*nCols,'TileSpacing','Compact','Padding','Compact'); % minimise whitespace around plots
    ii=0;
    for iCoupledPlot=1:nCoupledPlots
        for iPlane=1:length(planeLabs)
            ii=ii+1; axs(iCoupledPlot,iPlane)=nexttile; % subplot(nRows,2*nCols,ii);
            if ( iCoupledPlot<=nMaxPerPlane(iPlane) )
                for iEllypse=1:nSetsPerPlot
                    mySig=sqrt(beta(iEllypse,iCoupledPlot,iPlane)*emiG(iEllypse,iCoupledPlot,iPlane));
                    xx=linspace(-nSig*mySig,nSig*mySig,100);
                    yp=(-alpha(iEllypse,iCoupledPlot,iPlane)*xx+sqrt(mySig^2-xx.^2))/beta(iEllypse,iCoupledPlot,iPlane);
                    yn=(-alpha(iEllypse,iCoupledPlot,iPlane)*xx-sqrt(mySig^2-xx.^2))/beta(iEllypse,iCoupledPlot,iPlane);
                    if ( iEllypse>1 ), hold on; end
                    plot([xx xx(end:-1:1)]*1E3,[yp yn(end:-1:1)]*1E3,".-","Color",cm(iEllypse,:));
                end
                title(sprintf("%s plane - %s",planeLabs(iPlane),labCouple(iCoupledPlot))); xlabel("z [mm]"); ylabel("zp [mrad]"); grid();
            end
        end
    end
    % dedicated plot for the legend
    ii=ii+1; nexttile; % subplot(nRows,2*nCols,ii);
    for iEllypse=1:nSetsPerPlot
        if ( iEllypse>1 ), hold on; end
        plot(NaN(),NaN(),".-","Color",cm(iEllypse,:));
    end
    legend(labsLegend(1:nSetsPerPlot),"Location","best");
    % general
    sgtitle(myTit);
    if ( length(labCouple)>1 )
        linkaxes(axs(:,1),"xy"); % all HOR ellypses
        linkaxes(axs(:,2),"xy"); % all VER ellypses
    end
    % save figure
    if ( exist('outName','var') )
        if ( strlength(outName)>0 )
            savefig(outName);
            fprintf("...saving to file %s ...\n",outName);
        end
    end
end
