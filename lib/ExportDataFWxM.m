function ExportDataFWxM(tableIs,LGENnames,FWHMs,BARs,INTs,fracEst,nData,indicesMon,indicesCur,myOutName,lReduced)
    if ( ~exist('lReduced','var') ), lReduced=false; end
    mons=["CAM" "DDS"];
    planes=["hor" "ver"];
    fprintf("exporting data to file %s ...\n",myOutName);
    header=CreateHeader(LGENnames,planes,fracEst,lReduced);
    nPoints=size(tableIs,1);
    nColumns=size(header,2);
    for iMon=1:length(mons)
        myIndices=[indicesCur(iMon,:,:);indicesMon(iMon,:,:)];
        iAdds=AlignDataIndices(myIndices,true);
        C=cell(nPoints+1,nColumns); % do not forget the header (1st row)
        C(1,:)=header;
        C(2+iAdds(1,1):nPoints+1+iAdds(1,1),1:size(tableIs,2))=num2cell(tableIs(:,:,iMon));
        iCol=size(tableIs,2);
        for iPlane=1:length(planes)
            % IDs
            iCol=iCol+1; C(1+indicesCur(iMon,1,iPlane):1+indicesCur(iMon,2,iPlane),iCol)=num2cell(1:indicesCur(iMon,2,iPlane)-indicesCur(iMon,1,iPlane)+1)';
            % INTs
            iCol=iCol+1; C(2+iAdds(2,iPlane):nData(iMon)+1+iAdds(2,iPlane),iCol)=num2cell(INTs(1:nData(iMon),iPlane,iMon));
            % FWxM
            for iLev=1:length(fracEst)
                iCol=iCol+1; C(2+iAdds(2,iPlane):nData(iMon)+1+iAdds(2,iPlane),iCol)=num2cell(FWHMs(1:nData(iMon),iPlane,iMon,iLev));
            end
            % BAR
            iCol=iCol+1; C(2+iAdds(2,iPlane):nData(iMon)+1+iAdds(2,iPlane),iCol)=num2cell(BARs(1:nData(iMon),iPlane,iMon));
        end
        %
        writecell(C,myOutName,'Sheet',mons(iMon));
    end
    fprintf("...done.\n");
end

function header=CreateHeader(LGENnames,planes,fracEst,lReduced)
    header=strings(1,length(LGENnames)+2+(length(fracEst)+1)*length(planes));
    header(1:length(LGENnames))="I_"+LGENnames+" [A]";
    iString=length(LGENnames);
    for iDim=1:length(planes)
        % IDs
        iString=iString+1; header(iString)=sprintf("ID_%s",planes(iDim));
        % INTs
        iString=iString+1; header(iString)=sprintf("INT_%s",planes(iDim));
        % FWxM
        for iLev=1:length(fracEst)
            iString=iString+1;
            if ( lReduced )
                header(iString)=sprintf("sig_%.3fM_%s [mm]",...
                    fracEst(iLev),planes(iDim));
            else
                header(iString)=sprintf("FW_%.3fM_%s [mm]",...
                    fracEst(iLev),planes(iDim));
            end
        end
        % BAR
        iString=iString+1;
        header(iString)=sprintf("BAR_%s [mm]",planes(iDim));
    end
    header=cellstr(header);
end
