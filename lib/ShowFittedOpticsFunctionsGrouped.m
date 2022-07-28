function ShowFittedOpticsFunctionsGrouped(beta,alpha,emiG,disp,dispP,zz,zp,xVals,xLab,planeLabs,labels1,labels2,myTit,labelsType)

    nFitSets=size(beta,4);
    
    for iPlane=1:length(planeLabs)
        for iType=1:length(labelsType)
            for iLab2=1:length(labels2)
                figure();
                cm=colormap(parula(nFitSets));
                ii=0;
                %% first row
                % - beta
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,beta(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("\beta"); ylabel("[m]"); grid(); xlabel(xLab);
                % - alpha
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,alpha(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("\alpha"); ylabel("[]"); grid(); xlabel(xLab);
                % - geometric emittance
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,emiG(iLab2,:,iPlane,iFitSet,iType)*1E6,".-","Color",cm(iFitSet,:));
                end
                title("\epsilon"); ylabel("[\mum]"); grid(); xlabel(xLab);
                %% second row
                % - disp
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,disp(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("D"); ylabel("[m]"); grid(); xlabel(xLab);
                % - disp prime
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,dispP(iLab2,:,iPlane,iFitSet,iType),".-","Color",cm(iFitSet,:));
                end
                title("D'"); ylabel("[]"); grid(); xlabel(xLab); 
                % - legend
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(NaN(),NaN(),".-","Color",cm(iFitSet,:));
                end
                legend(labels1,"Location","best");
                %% third row
                % - orbit
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,zz(iLab2,:,iPlane,iFitSet,iType)*1E3,".-","Color",cm(iFitSet,:));
                end
                title("z"); ylabel("[mm]"); grid(); xlabel(xLab);
                % - orbit prime
                ii=ii+1; ax(ii)=subplot(3,3,ii);
                for iFitSet=1:nFitSets
                    if ( iFitSet>1 ), hold on; end
                    plot(xVals,zp(iLab2,:,iPlane,iFitSet,iType)*1E3,".-","Color",cm(iFitSet,:));
                end
                title("pz"); ylabel("[mrad]"); grid(); xlabel(xLab);

                %% general
                linkaxes(ax,"x");
                if ( length(labels2)>1 )
                    sgtitle(sprintf("%s - %s plane - %s - %s",myTit,planeLabs(iPlane),labels2(iLab2),LabelMe(labelsType(iType))));
                else
                    sgtitle(sprintf("%s - %s plane - %s",myTit,planeLabs(iPlane),LabelMe(labelsType(iType))));
                end
            end
        end
    end
end
