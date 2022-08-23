function ShowFittedEllipsesGrouped(beta,alpha,emiG,planeLabs,labels1,labels2,labels3,labelsType,myTit,myMon,nFitRanges,outName)
    nFitSets=size(beta,2); nSig=1;
    nSeries=max(nFitRanges);
    [nRows,nCols]=GetNrowsNcols(nSeries);
    if ( nRows*nCols==nSeries ), nRows=nRows+1; end
    
    %% actually plot
    for iType=1:length(labelsType)
        for iLab3=1:length(labels3)
            figure();
            cm=colormap(parula(nFitSets));
            ii=0;
            for iPar2=1:nSeries
                for iPlane=1:length(planeLabs)
                    ii=ii+1; axs(iPar2,iPlane)=subplot(nRows,2*nCols,ii);
                    if ( iPar2<=nFitRanges(iPlane) )
                        for iFitSet=1:nFitSets
                            mySig=sqrt(beta(iLab3,iFitSet,iPlane,iPar2,iType)*emiG(iLab3,iFitSet,iPlane,iPar2,iType));
                            xx=linspace(-nSig*mySig,nSig*mySig,100);
                            yp=(-alpha(iLab3,iFitSet,iPlane,iPar2,iType)*xx+sqrt(mySig^2-xx.^2))/beta(iLab3,iFitSet,iPlane,iPar2,iType);
                            yn=(-alpha(iLab3,iFitSet,iPlane,iPar2,iType)*xx-sqrt(mySig^2-xx.^2))/beta(iLab3,iFitSet,iPlane,iPar2,iType);
                            if ( iFitSet>1 ), hold on; end
                            plot([xx xx(end:-1:1)]*1E3,[yp yn(end:-1:1)]*1E3,".-","Color",cm(iFitSet,:));
                        end
                        title(sprintf("%s plane - %s",planeLabs(iPlane),labels1(iPar2))); xlabel("z [mm]"); ylabel("zp [mrad]"); grid();
                    end
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
            sgtitle(sprintf("%s - %s - %s - %s",myTit,myMon,labels3(iLab3),LabelMe(labelsType(iType))));
            if ( length(labels1)>1 )
                linkaxes(axs(:,1),"xy"); % all HOR ellypses
                linkaxes(axs(:,2),"xy"); % all VER ellypses
            end
            % save figure
            if ( exist('outName','var') )
                if ( strlength(outName)>0 )
                    if ( iLab3>1 )
                        myOutName=sprintf("%s_%s_fittedOptics_%s_ellypses_%s.fig",outName,myMon,labelsType(iType),labels3(iLab3)); 
                    else
                        myOutName=sprintf("%s_%s_fittedOptics_%s_ellypses.fig",outName,myMon,labelsType(iType)); 
                    end
                    savefig(myOutName);
                    fprintf("...saving to file %s ...\n",myOutName);
                end
            end
        end
    end
end
