function [currentTable]=BuildCurrentTable(cyCodesDesired,cyProgsDesired,allLGENs,IsXLS,LGENnamesXLS,psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices)
    fprintf("building table of currents based on LPOW error log, XLS of scans and TM values...\n");
    nCurrs=max(size(IsXLS,1),length(cyCodesDesired));
    nGens=length(allLGENs);
    if ( exist('indices','var') )
        iAdds=AlignDataIndices(indices);
    else
        iAdds=zeros(3,1);
    end
    currentTable=NaN(nCurrs+max(iAdds),nGens,2);
    monNames=["CAMeretta" "DDS"];
    for iLGEN=1:nGens
        fprintf("looking for LGEN %s current values used for measurements...\n",allLGENs(iLGEN));
        for iMon=1:2
            fprintf("...detector %s...\n",monNames(iMon));
            if ( ~ismissing(LGENsLPOWMon) )
                [Is,comCyProgs,iDesired]=GetCurrentsFromLPOWMon(allLGENs(iLGEN),cyProgsDesired(:,iMon),LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon);
                if ( ~ismissing(Is) )
                    currentTable(iDesired+iAdds(iMon),iLGEN,iMon)=Is;
                    continue
                end
            end
            [Is]=GetCurrentsFromXLS(allLGENs(iLGEN),IsXLS,LGENnamesXLS);
            if ( ~ismissing(Is) )
                currNData=length(Is);
                currentTable(1+iAdds(3):currNData+iAdds(3),iLGEN,iMon)=Is;
                continue
            end
            [Is,comCyCodes,iDesired]=GetCurrentsFromTM(allLGENs(iLGEN),cyCodesDesired(:,iMon),psNamesTM,cyCodesTM,currentsTM);
            if ( ~ismissing(Is) )
                currentTable(iDesired+iAdds(iMon),iLGEN,iMon)=Is;
                continue
            end
            warning("...unable to find appropriate currents for LGEN %s!",allLGENs(iLGEN));
        end
    end
    fprintf("...done.\n");
end
