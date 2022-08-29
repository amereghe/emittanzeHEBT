function ShowFittedOpticsFunctionsGrouped(beta,alpha,emiG,disp,dispP,zz,zp,xVals,xLab,labsLegend,myTitle,outName)

    nSetsPerPlot=size(beta,2);
    ff=figure();
    cm=colormap(parula(nSetsPerPlot));
    ff.Position(1:2)=[0 0]; % figure at lower-left corner of screen
    ff.Position(3:4)=ff.Position(3:4)*2; % larger figure:
    t = tiledlayout(3,3,'TileSpacing','Compact','Padding','Compact'); % minimise whitespace around plots
    ii=0;
    %% first row
    % - beta
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,beta(:,iSet),".-","Color",cm(iSet,:));
    end
    title("\beta"); ylabel("[m]"); grid(); xlabel(xLab);
    % - alpha
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,alpha(:,iSet),".-","Color",cm(iSet,:));
    end
    title("\alpha"); ylabel("[]"); grid(); xlabel(xLab);
    % - geometric emittance
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,emiG(:,iSet)*1E6,".-","Color",cm(iSet,:));
    end
    title("\epsilon"); ylabel("[\mum]"); grid(); xlabel(xLab);
    %% second row
    % - disp
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,disp(:,iSet),".-","Color",cm(iSet,:));
    end
    title("D"); ylabel("[m]"); grid(); xlabel(xLab);
    % - disp prime
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,dispP(:,iSet),".-","Color",cm(iSet,:));
    end
    title("D'"); ylabel("[]"); grid(); xlabel(xLab); 
    % - legend
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(NaN(),NaN(),".-","Color",cm(iSet,:));
    end
    legend(labsLegend(1:nSetsPerPlot),"Location","best");
    %% third row
    % - orbit
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,zz(:,iSet)*1E3,".-","Color",cm(iSet,:));
    end
    title("z"); ylabel("[mm]"); grid(); xlabel(xLab);
    % - orbit prime
    ii=ii+1; ax(ii)=nexttile; % subplot(3,3,ii);
    for iSet=1:nSetsPerPlot
        if ( iSet>1 ), hold on; end
        plot(xVals,zp(:,iSet)*1E3,".-","Color",cm(iSet,:));
    end
    title("pz"); ylabel("[mrad]"); grid(); xlabel(xLab);

    %% general
    linkaxes(ax,"x");
    sgtitle(myTitle);

    %% save figure
    if ( exist('outName','var') )
        if ( strlength(outName)>0 )
            savefig(outName);
            fprintf("...saving to file %s ...\n",outName);
        end
    end
    
end
