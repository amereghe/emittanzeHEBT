function CompareCurrents(Is,indices,LGENscanned,appValsLPOWMon,LGENsLPOWMon,allLGENs,scannedIsTM,cyProgsMeas,cyProgsLPOWMon)
    fprintf("comparing currents: excel sheet vs LPOW log...\n");
    nLGENsAll=length(allLGENs);
        
    figure();
    cm=colormap(parula(nLGENsAll));
    % align currents from excel to those from LPOW mon based on cyProgs
    % NB: we are using cyProgs from beam data (use CAMeretta data)!
    xlsCurrs=Is(indices(1,1):indices(1,2),allLGENs==LGENscanned);
    measCyProgs=cyProgsMeas(indices(2,1):indices(2,2));

    % selected LGEN
    subplot(1,2,1);
    plot(str2double(measCyProgs),xlsCurrs,"k*"); % xls data
    tmpIndices=(LGENsLPOWMon==LGENscanned);
    tmpCyProgs=cyProgsLPOWMon(tmpIndices);
    tmpAppliedVals=appValsLPOWMon(tmpIndices);
    [vals,ia,ib]=intersect(measCyProgs,tmpCyProgs);
    if ( ~isempty(vals) )
        ii=find(strcmpi(allLGENs,LGENscanned)); % ii is used to select the correct color in the color map
        hold on ; plot(str2double(tmpCyProgs(ib)),tmpAppliedVals(ib),".-","Color",cm(end-(ii-1),:));
        legend("xls","LPOW log","Location","best");
    else
        warning("...no data available in LPOWmon log for %s",LGENscanned);
        legend("xls","Location","best");
    end
    grid on; xlabel("cyProgs []"); ylabel("I [A]"); title(LabelMe(LGENscanned));

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
            Ys=scannedIsTM(indices(1,1):indices(1,2),ii);
            myLeg=[myLeg sprintf("%s - TM",allLGENs(ii))];
        else
            Xs=tmpCyProgs(ib);
            Ys=tmpAppliedVals(ib);
            myLeg=[myLeg allLGENs(ii)];
        end
        plot(str2double(Xs),Ys,".-","Color",cm(end-(ii-1),:));
    end
    grid on; xlabel("cyProgs []"); ylabel("I [A]"); title("All other LGEN of interest");
    legend(myLeg,"Location","best");

    fprintf("...end.\n");
end
