function [ii,AdminLevel]=SAGE_ADM_codeToIndices(SAGE35)
%

% persistent sc rastermap
%
% if isempty(sc)
%
%     sc=readgenericcsv('~/Public/ionedata/AdminBoundary2005/Raster_NetCDF/3_M3lcover_5min/admincodes.csv');
%     load ~/Public/ionedata/AdminBoundary2005/Raster_NetCDF/3_M3lcover_5min/ncmat/admin_5min.mat
%
%     rastermap=DS.Data;
% end
%
%
% idx=strmatch(SAGE35,sc.SAGE_ADMIN);
%
% if numel(idx)~=1
%     disp(['problem for ' SAGE35])
%     ii=[];
%     return
% end
%
% sageVal=sc.Value_in_5min_bdry_file(idx);
%
% ii=find(rastermap==sageVal);
%
%     disp(['NO problem for ' SAGE35])
%%
PCUconstants


persistent shp0 shp1 shp2 shp3 Raster0 Raster1 Raster2 Raster3
if isempty(shp0)
    x=load([SAGEAdminRastersDir '/Admin0.mat']);
    Raster0=x.Raster1;
    shp0=x.shp0;
    
    x=load([SAGEAdminRastersDir '/Admin1.mat']);
    Raster1=x.Raster1;
    shp1=x.shp1;
    
    
    x=load([SAGEAdminRastersDir '/Admin2.mat']);
    Raster2=x.Raster1;
    shp2=x.shp2;
    
    x=load([SAGEAdminRastersDir '/Admin3.mat']);
    Raster3=x.Raster1;
    shp3=x.shp3;
    
end



idx=strmatch(SAGE35,{shp0.SAGEADMCDE});

if numel(idx)>=1
    
    
    ii=[];
    for m=1:numel(idx);
        UniqueID=shp0(idx(m)).UniqueIDShape;
        ii=union(ii,find(Raster0==UniqueID));
    end
    
    
    AdminLevel=0;
    
    
else
    idx=strmatch(SAGE35,{shp1.SAGEADMCDE});
    
    if numel(idx)>=1
        
        ii=[];
        for m=1:numel(idx);
            UniqueID=shp1(idx(m)).UniqueIDShape;
            ii=union(ii,find(Raster1==UniqueID));
        end
        
        AdminLevel=1;
        
    else
        idx=strmatch(SAGE35,{shp2.SAGEADMCDE});
        
        
        
        
        
        if numel(idx)>=1
            
            ii=[];
            for m=1:numel(idx);
                UniqueID=shp2(idx(m)).UniqueIDShape;
                ii=union(ii,find(Raster2==UniqueID));
            end
            
            AdminLevel=2;
            
            
        else
            disp(['level 3.  oops'])
            ii=[];
            AdminLevel=3;
            idx=strmatch(SAGE35,{shp3.SAGEADMCDE});
            
            if numel(idx)>=1
                
                ii=[];
                for m=1:numel(idx);
                    UniqueID=shp3(idx(m)).UniqueIDShape;
                    ii=union(ii,find(Raster3==UniqueID));
                end
                AdminLevel=3;
                
                
            else
                disp(['problem with ' SAGE35 ]);

            ii=[];
            AdminLevel=-1;
            end
        end
    end
end




%% Code used to generate unique ID numbers for the polygons.
if 0==1   
    base=    '/Users/jsgerber/sandbox/jsg184_MonfredaRasters_To_DataStructures/SecondDownloadFromJulie/ChadCropmaps/Global/admin/';
    
    shp0=shaperead([base '/admin0/global_ad0.shp']);
    shp1=shaperead([base '/admin1/global_ad1.shp']);
    shp2=shaperead([base '/admin2/global_ad2.shp']);
    shp3=shaperead([base '/admin3/global_ad3.shp']);
    
    
    
    
    % here is some preliminary stuff / hopefully never need to do it again
    
    %%
    for j=1:numel(shp0)
        shp0(j).UniqueIDShape=1000+j;
    end
    [Long,Lat,Raster1]=ShapeFileToRaster(shp0,'UniqueIDShape');
    [Long,Lat,Raster2]=ShapeFileToRaster(shp0(end:-1:1),'UniqueIDShape');
    save(['AdminRasters/Admin0'],'Raster1','Raster2','shp0');
    
    %%
    for j=1:numel(shp1)
        shp1(j).UniqueIDShape=30000+j;
    end
    [Long,Lat,Raster1]=ShapeFileToRaster(shp1,'UniqueIDShape');
    [Long,Lat,Raster2]=ShapeFileToRaster(shp1(end:-1:1),'UniqueIDShape');
    save(['AdminRasters/Admin1'],'Raster1','Raster2','shp1');
    
    %%
    for j=1:numel(shp2)
        shp2(j).UniqueIDShape=100000+j;
    end
    [Long,Lat,Raster1]=ShapeFileToRaster(shp2,'UniqueIDShape');
    save(['AdminRasters/Admin2'],'Raster1','shp2');
    [Long,Lat,Raster2]=ShapeFileToRaster(shp2(end:-1:1),'UniqueIDShape');
    save(['AdminRasters/Admin2'],'Raster1','Raster2','shp2');
    %%
    for j=1:numel(shp3)
        shp3(j).UniqueIDShape=5000000+j;
    end
    [Long,Lat,Raster1]=ShapeFileToRaster(shp3,'UniqueIDShape');
    save(['AdminRasters/Admin3'],'Raster1','shp3');
    [Long,Lat,Raster2]=ShapeFileToRaster(shp3(end:-1:1),'UniqueIDShape');
    save(['AdminRasters/Admin3'],'Raster1','Raster2','shp3');
    
end