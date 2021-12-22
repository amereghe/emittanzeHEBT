function [Is,comCyCodes,iDesired]=GetCurrentsFromTM(myLGENname,cyCodesDesired,psNamesTM,cyCodesTM,currentsTM)
    Is=missing(); comCyCodes=missing(); iDesired=missing(); % default: LGEN is not in TM
    % check
    fprintf("looking for LGEN in TM values...\n");
    tmpLGENIndices=(psNamesTM==myLGENname);
    if ( ~any(tmpLGENIndices) )
        fprintf("...NOT found!\n");
    else
        if ( sum(tmpLGENIndices)>1 )
            fprintf("...more than an occurrence found! using last one...\n");
            tmpLGENIndices=tmpLGENIndices(end);
        end
        [rangeCodes,partCodes]=DecodeCyCodes(cyCodesDesired);
        [~,tmpCyCodesIndices]=ismember(rangeCodes,cyCodesTM);
        Is=currentsTM(tmpCyCodesIndices(tmpCyCodesIndices>0),tmpLGENIndices);
        comCyCodes=cyCodesTM(tmpCyCodesIndices(tmpCyCodesIndices>0));
        iDesired=find(tmpCyCodesIndices>0);
        fprintf("...filled in %d values;\n",size(Is,1));
    end
    fprintf("...done.\n");
end
