function [ReducedFWxM]=GetReducedFWxM(FWxM,fracEst)
    ReducedFWxM=FWxM;
    for iLev=1:length(fracEst)
        ReducedFWxM(:,:,:,iLev)=ReducedFWxM(:,:,:,iLev)/(2*sqrt(2*log(1/fracEst(iLev))));
    end
end