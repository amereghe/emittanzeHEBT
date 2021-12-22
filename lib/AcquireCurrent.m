function [Is,LGENnames]=AcquireCurrent(fileName,sheetName)
    if ( ~exist('sheetName','var') ), sheetName="Foglio1"; end
    fprintf("parsing current file %s, sheet %s ...\n",fileName,sheetName);
    C=readcell(fileName,"Sheet",sheetName,"NumHeaderLines",1);
    % storing data
    Is=cell2mat(C(:,3:end));
    LGENnames=strings(C(:,1));
    fprintf("...done.\n");
end
