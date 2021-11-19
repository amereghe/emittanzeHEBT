function CompareCurrents(Is,indices,LGENnames,appValsLPOWMon,LGENsLPOWMon,allLGENs,cyProgsSumm,cyProgsLPOWMon)
    fprintf("comparing currents: excel sheet vs LPOW log...\n");
    nScans=size(Is,2);
    nLGENsAll=length(allLGENs);
    for iScan=1:nScans
        
        figure();
        cm=colormap(parula(nLGENsAll));
        % align currents from excel to those from LPOW mon based on cyProgs
        % NB: we are using cyProgs from beam data!
        xlsCurrs=Is(indices(3,1,iScan):indices(3,2,iScan),iScan);
        xlsCyProgs=str2double(cyProgsSumm(indices(1,1,iScan):indices(1,2,iScan),iScan));
        
        % selected LGEN
        subplot(1,2,1);
        ii=find(strcmpi(allLGENs,LGENnames(iScan)));
        currIndices=(LGENsLPOWMon==allLGENs(ii));
        currCyProgs=cyProgsLPOWMon(currIndices);
        currAppliedVals=appValsLPOWMon(currIndices);
        [vals,ia,ib]=intersect(xlsCyProgs,currCyProgs);
        plot(xlsCyProgs,xlsCurrs,"k*"); hold on;
        plot(currCyProgs(ib),currAppliedVals(ib),".-","Color",cm(end-(ii-1),:));
        grid on; xlabel("cyProgs []"); ylabel("I [A]"); title(LabelMe(LGENnames(iScan)));
        legend("LPOW log","xls","Location","best");
        
        % all currents
        subplot(1,2,2);
        myLeg=[];
        for ii=1:nLGENsAll
            if ( strcmpi(allLGENs(ii),LGENnames(iScan)) ), continue; end
            if ( length(myLeg)>0 ), hold on; end
            currIndices=(LGENsLPOWMon==allLGENs(ii));
            currCyProgs=cyProgsLPOWMon(currIndices);
            currAppliedVals=appValsLPOWMon(currIndices);
            [vals,ia,ib]=intersect(xlsCyProgs,currCyProgs);
            if ( length(vals)==0 )
                warning("...no data available in LPOWmon log for %s!",allLGENs(ii));
                continue
            end
            plot(currCyProgs(ib),currAppliedVals(ib),".-","Color",cm(end-(ii-1),:));
            myLeg=[myLeg allLGENs(ii)];
        end
        grid on; xlabel("cyProgs []"); ylabel("I [A]"); title("All other LGEN of interest");
        legend(myLeg,"Location","best");

    end
    fprintf("...end.\n");
end
