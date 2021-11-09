function [Is,nData]=AcquireCurrentData(currPaths,LGENnames)
    fprintf("acquiring data...\n");
    nPaths=length(currPaths);
    Is=zeros(1,nPaths);
    nData=zeros(nPaths,1);
    for ii=1:nPaths
        % acquire currents
        tmpIs=AcquireCurrent(currPaths(ii),LGENnames(ii));
        nData(ii)=length(tmpIs);
        Is(1:nData(ii),ii)=tmpIs;
        fprintf("...acquired %d current values;\n",nData(ii));
    end
    fprintf("...done.\n");
end

