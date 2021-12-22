function [Is,comCyProgs,iDesired]=GetCurrentsFromLPOWMon(myLGENname,cyProgsDesired,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon)
    Is=missing(); comCyProgs=missing(); iDesired=missing(); % default: LGEN is not in LPOW error log
    % check
    fprintf("looking for LGEN in values for LPOW monitor...\n");
    tmpIndices=(myLGENname==LGENsLPOWMon);
    if ( ~any(tmpIndices) )
        fprintf("...NOT found!\n");
    else
        tmpCyProgs=cyProgsLPOWMon(tmpIndices);
        tmpIs=appValsLPOWMon(tmpIndices);
        [tmpComCyProgs,ia,ib]=intersect(cyProgsDesired,tmpCyProgs);
        if ( isempty(tmpComCyProgs) )
            fprintf("...found NO values;\n");
        else
            Is=tmpIs(ib);
            comCyProgs=tmpComCyProgs;
            iDesired=ia;
            fprintf("...found %d values;\n",size(Is,1));
        end
    end
    fprintf("...done.\n");
end
