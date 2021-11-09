function ExportData(Is,currNData,FWHMs,BARs,INTs,nData,indices,outNames)
    fprintf("exporting data...\n");
    header={"ID curr" , "I [A]" , ...
        "ID CAM", "FWHM_x [mm]", "FWHM_y [mm]", "x [mm]", "y [mm]", "INT_x []", "INT_y []", ...
        "ID DDS", "FWHM_x [mm]", "FWHM_y [mm]", "x [mm]", "y [mm]", "INT_x []", "INT_y []" };
    nScans=size(Is,2);
    nPoints=max(size(Is,1),size(FWHMs,1));
    nColumns=size(header,2);
    for ii=1:nScans
        val=max(indices(:,1,ii));   % highest min
        C=cell(nPoints+1,nColumns);
        C(1,:)=header;
        iAdd=val-indices(3,1,ii);
        iCol=1;      C(2+iAdd:currNData(ii)+1+iAdd,iCol)=num2cell(1:currNData(ii))';
        iCol=iCol+1; C(2+iAdd:currNData(ii)+1+iAdd,iCol)=num2cell(Is(1:currNData(ii),ii));
        for jj=1:2 % CAMeretta,DDS
            iAdd=val-indices(jj,1,ii);
            iCol=iCol+1; C(2+iAdd:nData(jj,ii)+1+iAdd,iCol)=num2cell(1:nData(jj,ii))';
            for kk=1:3 % FWHM,BAR,INT
                switch kk
                    case 1
                        whatToShow=FWHMs;
                    case 2
                        whatToShow=BARs;
                    case 3
                        whatToShow=INTs;
                end
                for ll=1:2 % Hor,Ver
                    iCol=iCol+1; C(2+iAdd:nData(jj,ii)+1+iAdd,iCol)=num2cell(whatToShow(1:nData(jj,ii),ll,jj,ii));
                end
            end
        end
        outName=sprintf("%s.xlsx",outNames);
        fprintf("...writing to file %s ...\n",outName);
        writecell(C,outName,'Sheet',"Standard");
    end
    fprintf("...done.\n");
end
