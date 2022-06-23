function ExportDataFWxM(tableIs,LGENnames,FWHMs,BARs,fracEst,nData,indices,myOutName,lReduced)
    if ( ~exist('lReduced','var') ), lReduced=false; end
    mons=["CAM" "DDS"];
    planes=["hor" "ver"];
    fprintf("exporting data to file %s ...\n",myOutName);
    header=CreateHeader(LGENnames,planes,fracEst,lReduced);
    nPoints=size(tableIs,1);
    nColumns=size(header,2);
    iAdds=AlignDataIndices(indices);
    for iMon=1:length(mons)
        C=cell(nPoints+1,nColumns); % do not forget the header (1st row)
        C(1,:)=header;
        C(2+iAdds(1):nPoints+1+iAdds(1),1:size(tableIs,2))=num2cell(tableIs(:,:,iMon));
        iCol=size(tableIs,2);
        iCol=iCol+1; C(1+indices(1,1):1+indices(1,2),iCol)=num2cell(1:indices(1,2)-indices(1,1)+1)';
        % FWxM
        for iDim=1:length(planes)
            for iLev=1:length(fracEst)
                iCol=iCol+1; C(2+iAdds(iMon+1):nData(iMon)+1+iAdds(iMon+1),iCol)=num2cell(FWHMs(1:nData(iMon),iDim,iMon,iLev));
            end
        end
        % BAR
        for iDim=1:length(planes)
            iCol=iCol+1; C(2+iAdds(iMon+1):nData(iMon)+1+iAdds(iMon+1),iCol)=num2cell(BARs(1:nData(iMon),iDim,iMon));
        end
        %
        writecell(C,myOutName,'Sheet',mons(iMon));
    end
    fprintf("...done.\n");
end

function header=CreateHeader(LGENnames,planes,fracEst,lReduced)
    header=strings(1,length(LGENnames)+1+(length(fracEst)+1)*length(planes));
    header(1:length(LGENnames))="I_"+LGENnames+" [A]";
    iString=length(LGENnames)+1;
    header(iString)="ID";
    % FWxM
    for iDim=1:length(planes)
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
    end
    % BAR
    for iDim=1:length(planes)
        iString=iString+1;
        header(iString)=sprintf("BAR_%s [mm]",planes(iDim));
    end
    header=cellstr(header);
end
