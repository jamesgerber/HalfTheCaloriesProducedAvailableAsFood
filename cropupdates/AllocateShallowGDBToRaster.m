function [ymap,amap]=AllocateShallowGDBToRaster(CDS,allcropcultivatedarea,areafieldname,yieldfieldname);
% allocateShallowtoRaster allocate a GDB Structure to a raster
%
%  [ymap,amap]=AllocateShallowGDBToRaster(CDS,allcropcultivatedarea,areafieldname,yieldfieldname);
%
% "Shallow" because the yield and area fields aren't hidden inside a
% structure.
%

if nargin==0
    help(mfilename);
    return
end

fiveminareas=fma;

ymap=datablank;
amap=datablank;
testmap=datablank;
for j=1:numel(CDS);

    C=CDS(j);
    ii=GADMCodeToIndices(C.GADMCode);
%    ii=GADMCodeToIndicesHash(fasthash(C.GADMCode));


    testmap(ii)=testmap(ii)+1;
    ymap(ii)=C.(yieldfieldname);
    totalharvestedHAvector=fiveminareas(ii).*allcropcultivatedarea(ii);
    totalharvestedHAsum=sum(fiveminareas(ii).*allcropcultivatedarea(ii));
    cropharvestedHAvector=totalharvestedHAvector*C.(areafieldname)/totalharvestedHAsum;
    cropharvestedfracareavector=cropharvestedHAvector./fiveminareas(ii);
    amap(ii)=cropharvestedfracareavector;
  end

1==1;  % could pause here


