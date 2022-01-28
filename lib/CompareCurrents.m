function CompareCurrents(Is,indices,LGENscanned,appValsLPOWMon,LGENsLPOWMon,allLGENs,scannedIsTM,cyProgsMeas,cyProgsLPOWMon)
    fprintf("comparing currents: excel sheet vs LPOW log...\n");
    nLGENsAll=length(allLGENs);
        
    figure();
    cm=colormap(parula(nLGENsAll));
    % align currents from excel to those from LPOW mon based on cyProgs
    % NB: we are using cyProgs from beam data (use CAMeretta data)!
    xlsCurrs=Is(indices(1,1):indices(1,2));
    measCyProgs=str2double(cyProgsMeas(indices(2,1):indices(2,2)));

    % selected LGEN
    subplot(1,2,1);
    tmpIndices=(LGENsLPOWMon==LGENscanned);
    tmpCyProgs=cyProgsLPOWMon(tmpIndices);
    tmpAppliedVals=appValsLPOWMon(tmpIndices);
    [vals,ia,ib]=intersect(measCyProgs,tmpCyProgs);
    plot(measCyProgs(ia),xlsCurrs(ia),"k*"); hold on;
    ii=find(strcmpi(allLGENs,LGENscanned)); % ii is used to select the correct color in the color map
    plot(tmpCyProgs(ib),tmpAppliedVals(ib),".-","Color",cm(end-(ii-1),:));
    grid on; xlabel("cyProgs []"); ylabel("I [A]"); title(LabelMe(LGENscanned));
    legend("LPOW log","xls","Location","best");

    % all other LGENs
    subplot(1,2,2);
    myLeg=[];
    for ii=1:nLGENsAll
        if ( strcmpi(allLGENs(ii),LGENscanned) ), continue; end
        if ( length(myLeg)>0 ), hold on; end
        tmpIndices=(LGENsLPOWMon==allLGENs(ii));
        tmpCyProgs=cyProgsLPOWMon(tmpIndices);
        tmpAppliedVals=appValsLPOWMon(tmpIndices);
        [vals,ia,ib]=intersect(measCyProgs,tmpCyProgs);
        if ( length(vals)==0 )
            warning("...no data available in LPOWmon log for %s - going with TM values",allLGENs(ii));
            Xs=measCyProgs;
            Ys=scannedIsTM(:,ii);
            myLeg=[myLeg sprintf("%s - TM",allLGENs(ii))];
        else
            Xs=tmpCyProgs(ib);
            Ys=tmpAppliedVals(ib);
        end
        plot(Xs,Ys,".-","Color",cm(end-(ii-1),:));
        myLeg=[myLeg allLGENs(ii)];
    end
    grid on; xlabel("cyProgs []"); ylabel("I [A]"); title("All other LGEN of interest");
    legend(myLeg,"Location","best");

    fprintf("...end.\n");
end
