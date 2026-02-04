function [GADM3]=SAGE3ToGADM3(SAGE3);

% SAGE3 to GADM3 utility.  Note GADM3 can be returned as a vector of
% countries (for example, 'SMN' goes to Serbia, Montenegro, and Kosovo)



persistent gadmgeo0 shp0 Raster0
if isempty(gadmgeo0)
    gadmgeo0=load([iddstring '/AdminBoundary2020/gadm36_level0raster5minVer0.mat']);
    
    [shp0, Raster0, shp1, Raster1, shp2, Raster2, shp3, Raster3, UniqueCountryRaster]=...
        getSHPfiles;
    
end




%for jcountry=1:numel(SAGE3list);
%    SAGE3=SAGE3list{jcountry};



switch SAGE3
    
    case 'ROM'
        GADM3='ROU';
    case 'ZAR'
        GADM3='COD';
    case 'SMN'
        GADM3={'MNE','SRB','XKO'}
    otherwise
        
        idx=strmatch(SAGE3,gadmgeo0.gadm0codes);
        
        if numel(idx)==1
            GADM3=SAGE3;
            %  disp(['good ' SAGE3])
        else
            
            idx=strmatch(SAGE3,{shp0.SAGE3});
            
            UniqueRasterNo=unique([shp0(idx).UniqueRasterNo]);
            
            iisage=find(UniqueCountryRaster==UniqueRasterNo);
            
            
            gadmrastervals=gadmgeo0.raster0(iisage);
            
            x=unique(gadmrastervals);
            
            [N,x]=hist(gadmrastervals,x);
            
            [maxval,idx]=max(N);
            
            
            gadmgeo0.namelist0(x(idx))
            gadmgeo0.gadm0codes(x(idx))
            
            
            disp(['bad ' SAGE3]);
            keyboard
        end
        
end
