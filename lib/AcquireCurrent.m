function Is=AcquireCurrent(fileName,LGENname,sheetName)
    if ( ~exist('sheetName','var') ), sheetName="Foglio1"; end
    fprintf("parsing current file %s, sheet %s ...\n",fileName,sheetName);
    C=readcell(fileName,"Sheet",sheetName,"NumHeaderLines",1);
    fprintf("...looking for LGEN %s...\n",LGENname);
    switch sum(C(:,1)==LGENname)
        case 0
            error("...not found!");
        case 1
            iLines=(C(:,1)==LGENname);
            Is=cell2mat(C(iLines,3:end))';
        otherwise
            error("...non-uniqe entry found in sheet!");
    end
    fprintf("...done.\n");
end
