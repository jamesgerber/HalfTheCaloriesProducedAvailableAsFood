function [harvarea5min,croparea5min,version]=getCropGridsArea(cropname);
%[harvareamap,cropareamap,version]=getCropGridsArea(cropname);


version='CROPGRIDSv1.08, downloaded Oct 17, 2024'; 

DS=opengeneralnetcdf(['/Users/jsgerber/DataProducts/ext/CropGrids/CROPGRIDSv1.08_NC_maps/CROPGRIDSv1.08_' cropname '.nc']);

harvarea=DS(3).Data(:,end:-1:1);
croparea=DS(4).Data(:,end:-1:1);
set=DS(6).Data(:,end:-1:1);

harvarea(harvarea<0)=0;
harvarea5min=aggregate_quantity(disaggregate_quantity(harvarea,3),5)./fma;

croparea(croparea<0)=0;
croparea5min=aggregate_quantity(disaggregate_quantity(croparea,3),5)./fma;

