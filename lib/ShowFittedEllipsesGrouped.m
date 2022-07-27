function ShowFittedEllipsesGrouped(beta,alpha,emiG,planeLabs,labels1,labels2,labels3,myTit)
    nFitSets=size(beta,2); nSig=1;
    nSeries=size(beta,4);
    [nRows,nCols]=GetNrowsNcols(nSeries);
    if ( nRows*nCols==nSeries ), nRows=nRows+1; end
    
    %% actually plot
    for iLab3=1:length(labels3)
        figure();
        cm=colormap(parula(nFitSets));
        ii=0;
        for iPar2=1:length(labels1)
            for iPlane=1:length(planeLabs)
                ii=ii+1; axs(iPar2,iPlane)=subplot(nRows,2*nCols,ii);
                for iFitSet=1:nFitSets
                    mySig=sqrt(beta(iLab3,iFitSet,iPlane,iPar2)*emiG(iLab3,iFitSet,iPlane,iPar2));
                    xx=linspace(-nSig*mySig,nSig*mySig,100);
                    yp=(-alpha(iLab3,iFitSet,iPlane,iPar2)*xx+sqrt(mySig^2-xx.^2))/beta(iLab3,iFitSet,iPlane,iPar2);
                    yn=(-alpha(iLab3,iFitSet,iPlane,iPar2)*xx-sqrt(mySig^2-xx.^2))/beta(iLab3,iFitSet,iPlane,iPar2);
                    if ( iFitSet>1 ), hold on; end
                    plot([xx xx(end:-1:1)]*1E3,[yp yn(end:-1:1)]*1E3,".-","Color",cm(iFitSet,:));
                end
                title(sprintf("%s plane - %s",planeLabs(iPlane),labels1(iPar2))); xlabel("z [mm]"); ylabel("zp [mrad]"); grid();
            end
        end
        % dedicated plot for the legend
        ii=ii+1; subplot(nRows,2*nCols,ii);
        for iFitSet=1:nFitSets
            if ( iFitSet>1 ), hold on; end
            plot(NaN(),NaN(),".-","Color",cm(iFitSet,:));
        end
        legend(labels2,"Location","best");
        % general
        sgtitle(sprintf("%s - %s",myTit,labels3(iLab3)));
        if ( length(labels1)>1 )
            linkaxes(axs(:,1),"xy"); % all HOR ellypses
            linkaxes(axs(:,2),"xy"); % all VER ellypses
        end
    end
end
