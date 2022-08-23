function ShowFittedOpticsFunctionsGrouped(beta,alpha,emiG,disp,dispP,zz,zp,xVals,xLab,planeLabs,labels1,labels2,labelsType,myTit,myMon,nFitRanges,outName)

    for iPlane=1:length(planeLabs)
        for iType=1:length(labelsType)
            for iLab2=1:length(labels2)
                figure();
                cm=colormap(parula(nFitRanges(iPlane)));
                ii=0;
                %% first row
                % - beta
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,beta(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("\beta"); ylabel("[m]"); grid(); xlabel(xLab);
                % - alpha
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,alpha(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("\alpha"); ylabel("[]"); grid(); xlabel(xLab);
                % - geometric emittance
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,emiG(iLab2,:,iPlane,iFitSet,iType)*1E6,".-","Color",cm(iFitSet,:));
                end
                title("\epsilon"); ylabel("[\mum]"); grid(); xlabel(xLab);
                %% second row
                % - disp
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,disp(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("D"); ylabel("[m]"); grid(); xlabel(xLab);
                % - disp prime
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,dispP(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("D'"); ylabel("[]"); grid(); xlabel(xLab); 
                % - legend
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(NaN(),NaN(),".-","Color",cm(iFitSet,:));
                end
                legend(labels1,"Location","best");
                %% third row
                % - orbit
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,zz(iLab2,:,iPlane,iFitSet,iType)*1E3,".-","Color",cm(iFitSet,:));
                end
                title("z"); ylabel("[mm]"); grid(); xlabel(xLab);
                % - orbit prime
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitRanges(iPlane)
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,zp(iLab2,:,iPlane,iFitSet,iType)*1E3,".-","Color",cm(iFitSet,:));
                end
                title("pz"); ylabel("[mrad]"); grid(); xlabel(xLab);

                %% general
                linkaxes(ax,"x");
                if ( length(labels2)>1 )
                    sgtitle(sprintf("%s - %s - %s plane - %s - %s",myTit,myMon,planeLabs(iPlane),labels2(iLab2),LabelMe(labelsType(iType))));
                else
                    sgtitle(sprintf("%s - %s - %s plane - %s",myTit,myMon,planeLabs(iPlane),LabelMe(labelsType(iType))));
                end
                
                %% save figure
                if ( exist('outName','var') )
                    if ( strlength(outName)>0 )
                        if ( iLab2>1 )
                            myOutName=sprintf("%s_%s_fittedOptics_%s_%s_%s.fig",outName,myMon,labelsType(iType),planeLabs(iPlane),labels2(iLab2)); 
                        else
                            myOutName=sprintf("%s_%s_fittedOptics_%s_%s.fig",outName,myMon,labelsType(iType),planeLabs(iPlane)); 
                        end
                        savefig(myOutName);
                        fprintf("...saving to file %s ...\n",myOutName);
                    end
                end
    
            end
        end
    end
end
