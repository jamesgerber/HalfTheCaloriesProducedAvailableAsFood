function [shp0, Raster0, shp1, Raster1, shp2, Raster2, shp3, Raster3, UniqueCountryRaster]=...
    getSHPfiles;


persistent  storestruct

if isempty(storestruct)
    
    PCUconstants
    %if isempty(shp0)
    
    x=load([SAGEAdminRastersDir '/Admin0.mat']);
    Raster0=x.Raster1;
    shp0=x.shp0;
    for j=1:numel(shp0)
        shp0(j).SAGE3=shp0(j).SAGEADMCDE(1:3);
    end
    
    x=load([SAGEAdminRastersDir '/Admin1.mat']);
    Raster1=x.Raster1;
    shp1=x.shp1;
    for j=1:numel(shp1)
        shp1(j).SAGE3=shp1(j).SAGEADMCDE(1:3);
    end
    
    
    x=load([SAGEAdminRastersDir '/Admin2.mat']);
    Raster2=x.Raster2;
    shp2=x.shp2;
    for j=1:numel(shp2)
        shp2(j).SAGE3=shp2(j).SAGEADMCDE(1:3);
    end
    
    x=load([SAGEAdminRastersDir '/Admin3.mat']);
    Raster3=x.Raster1;
    shp3=x.shp3;
    for j=1:numel(shp3)
        shp3(j).SAGE3=shp3(j).SAGEADMCDE(1:3);
    end
    
    %% some raster pre-processing
    % make a new raster that has a unique country ID for every country
    % also add a field to shapefile
    %list of countries
    CountryList=unique({shp0.SAGE3});
    
    UniqueCountryRaster=datablank;
    
    for jcountry=1:numel(CountryList);
        SAGE3=CountryList{jcountry};
        idx=strmatch(SAGE3,{shp0.SAGE3});
        
        for m=1:numel(idx)
            
            shp0(idx(m)).UniqueRasterNo=jcountry;
            
            ii=Raster0==shp0(idx(m)).UniqueIDShape;
            UniqueCountryRaster(ii)=jcountry;
        end
    end
    
    storestruct.shp0=shp0;
    storestruct.Raster0=Raster0;
    storestruct.shp1=shp1;
    storestruct.Raster1=Raster1;
    storestruct.shp2=shp2;
    storestruct.Raster2=Raster2;
    storestruct.shp3=shp3;
    storestruct.Raster3=Raster3;
    storestruct.UniqueCountryRaster=UniqueCountryRaster;
    
else
    
    expandstructure(storestruct)
end



%end