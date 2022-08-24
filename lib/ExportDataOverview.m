function ExportDataOverview(tableIs,LGENnames,FWHMs,BARs,INTs,nData,indicesMon,indicesCur,myOutName)
    mons=["CAM" "DDS"];
    planes=["hor" "ver"];
    fprintf("exporting data to file %s ...\n",myOutName);
    header=CreateHeader(LGENnames,planes);
    nPoints=size(tableIs,1);
    nColumns=size(header,2);
    for iMon=1:length(mons)
        myIndices=[indicesCur(iMon,:,:);indicesMon(iMon,:,:)];
        iAdds=AlignDataIndices(myIndices);
        C=cell(nPoints+1,nColumns); % do not forget the header (1st row)
        C(1,:)=header;
        C(2+iAdds(1,1):nPoints+1+iAdds(1,1),1:size(tableIs,2))=num2cell(tableIs(:,:,iMon));
        iCol=size(tableIs,2);
        for iPlane=1:length(planes) % Hor,Ver
            if ( size(indicesCur,3)==1 )
                iCol=iCol+1; C(1+indicesCur(iMon,1):1+indicesCur(iMon,2),iCol)=num2cell(1:indicesCur(iMon,2)-indicesCur(iMon,1)+1)';
            else
                iCol=iCol+1; C(1+indicesCur(iMon,1,iPlane):1+indicesCur(iMon,2,iPlane),iCol)=num2cell(1:indicesCur(iMon,2,iPlane)-indicesCur(iMon,1,iPlane)+1)';
            end
            for kk=1:3 % FWHM,BAR,INT
                switch kk
                    case 1
                        whatToShow=FWHMs;
                    case 2
                        whatToShow=BARs;
                    case 3
                        whatToShow=INTs;
                end
                iCol=iCol+1; C(2+iAdds(2,1):nData(iMon)+1+iAdds(2,1),iCol)=num2cell(whatToShow(1:nData(iMon),iPlane,iMon));
            end
        end
        writecell(C,myOutName,'Sheet',mons(iMon));
    end
    fprintf("...done.\n");
end

function header=CreateHeader(LGENnames,planes)
    whatLabels=[ "FWHM" "BAR" "INT" ];
    whatUnits=[ "mm" "mm" "" ];
    header=strings(1,length(LGENnames)+2+length(whatLabels)*length(planes));
    header(1:length(LGENnames))="I_"+LGENnames+" [A]";
    iString=length(LGENnames);
    for iDim=1:length(planes)
        iString=iString+1; 
        header(iString)=sprintf("ID_%s",planes(iDim));
        for iWhat=1:length(whatLabels)
            iString=iString+1;
            header(iString)=sprintf("%s_%s [%s]",...
                whatLabels(iWhat),planes(iDim),whatUnits(iWhat));
        end
    end
    header=cellstr(header);
end
