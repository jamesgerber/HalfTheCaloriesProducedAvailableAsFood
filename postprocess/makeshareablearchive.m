% this is the very last code that needs to be run, it takes the outputs as
% I have stored them for working and makes .tifs and shapefiles for
% sharing.


% %first the datalayers
% 
% load intermediatedatafiles/SortedCropNames2020.mat Top50WorkingCropsSortedByCalories2020
% 
% for j=1:50
%     cropname=Top50WorkingCropsSortedByCalories2020{j};
% 
%     a=dir(['shallowrasterlayers/' cropname '*']);
% 
%     for m=1:3
%         x=load(['shallowrasterlayers/' a(m).name]);
%         namebase=strrep(a(m).name,'.mat','');
%         globalarray2geotiff( x.ymaptemp,['output/archive/datalayers/' namebase '_yield.tif']);
%         globalarray2geotiff( x.amaptemp,['output/archive/datalayers/' namebase '_area.tif']);
%     end
% end

% now the figures
% 
%  load intermediatedatafiles/SortedCropNames2020.mat Top50WorkingCropsSortedByCalories2020
% % 
%  for j=1:50
%      cropname=Top50WorkingCropsSortedByCalories2020{j};
% 
%      unix(['cp output/figures/*' cropname '*.png output/archive/figures/']);
%  end


%Shapefiles


a=dir('GeodatabaseFiles/IBGE/*.mat')
for j=1:numel(a);
   x= load(['GeodatabaseFiles/IBGE/' a(j).name]);
end
