function ExportDataOverview(tableIs,LGENnames,FWHMs,BARs,INTs,nData,indices,outName)
    myOutName=sprintf("%s_overview.xlsx",outName);
    mons=["CAM" "DDS"];
    planes=["hor" "ver"];
    fprintf("exporting data to file %s ...\n",myOutName);
    header=CreateHeader(LGENnames,planes);
    nPoints=size(tableIs,1);
    nColumns=size(header,2);
    iAdds=AlignDataIndices(indices);
    for jj=1:length(mons)
        C=cell(nPoints+1,nColumns); % do not forget the header (1st row)
        C(1,:)=header;
        C(2+iAdds(3):nPoints+1+iAdds(3),1:size(tableIs,2))=num2cell(tableIs(:,:,jj));
        iCol=size(tableIs,2);
        iCol=iCol+1; C(1+indices(3,1):1+indices(3,2),iCol)=num2cell(1:indices(3,2)-indices(3,1)+1)';
        for kk=1:3 % FWHM,BAR,INT
            switch kk
                case 1
                    whatToShow=FWHMs;
                case 2
                    whatToShow=BARs;
                case 3
                    whatToShow=INTs;
            end
            for ll=1:length(planes) % Hor,Ver
                iCol=iCol+1; C(2+iAdds(jj):nData(jj)+1+iAdds(jj),iCol)=num2cell(whatToShow(1:nData(jj),ll,jj));
            end
        end
        writecell(C,myOutName,'Sheet',mons(jj));
    end
    fprintf("...done.\n");
end

function header=CreateHeader(LGENnames,planes)
    whatLabels=[ "FW" "BAR" "INT" ];
    whatUnits=[ "mm" "mm" "" ];
    header=strings(1,length(LGENnames)+1+length(whatLabels)*length(planes));
    header(1:length(LGENnames))="I_"+LGENnames+" [A]";
    iString=length(LGENnames)+1;
    header(iString)="ID";
    for iWhat=1:length(whatLabels)
        for iDim=1:length(planes)
            iString=iString+1;
            header(iString)=sprintf("%s_%s [%s]",...
                whatLabels(iWhat),planes(iDim),whatUnits(iWhat));
        end
    end
    header=cellstr(header);
end
