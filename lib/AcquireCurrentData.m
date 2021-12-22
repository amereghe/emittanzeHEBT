function [Is,LGENnames,nData]=AcquireCurrentData(fileName,sheetName)
    if ( ~exist('sheetName','var') ), sheetName="Foglio1"; end
    fprintf("parsing current file %s, sheet %s ...\n",fileName,sheetName);
    C=readcell(fileName,"Sheet",sheetName,"NumHeaderLines",1);
    % storing data
    Is=cell2mat(C(:,3:end))';
    LGENnames=string(C(:,1));
    nData=size(Is,1);
    fprintf("...acquired %d current values;\n",nData);
end
