function [Is]=GetCurrentsFromXLS(myLGENname,IsXLS,LGENnamesXLS)
    Is=missing(); % default: LGEN is not in XLS file of scans
    % check
    fprintf("looking for LGEN in values from XLS of scanned currents...\n");
    tmpIndices=(LGENnamesXLS==myLGENname);
    if ( ~any(tmpIndices) )
        fprintf("...NOT found!\n");
    else
        if ( sum(tmpIndices)>1 )
            fprintf("...more than an occurrence found! using last one...\n");
            tmpIndices=tmpIndices(end);
        end
        Is=IsXLS(:,tmpIndices);
        fprintf("...found %d values;\n",size(Is,1));
    end
    fprintf("...done.\n");
end
