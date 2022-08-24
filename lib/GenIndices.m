function [indicesMon,indicesCur]=GenIndices(indicesIn,iCurr2mon,lMon2Curr)
    if ( ~exist("lMon2Curr","var") ), lMon2Curr=true; end
    if ( lMon2Curr )
        indicesMon=indicesIn;
        indicesCur=indicesMon;
        for ii=1:length(iCurr2mon)
            indicesCur(ii,:)=indicesCur(ii,:)-iCurr2mon(ii);
        end
    else
        indicesCur=indicesIn;
        indicesMon=indicesCur;
        for ii=1:length(iCurr2mon)
            indicesMon(ii,:)=indicesMon(ii,:)+iCurr2mon(ii);
        end
    end
end
