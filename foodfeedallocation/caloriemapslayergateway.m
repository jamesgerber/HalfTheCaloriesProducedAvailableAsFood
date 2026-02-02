function [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,ForceRedoInput)
% caloriemapslayergateway - utility to read in or allocate calorie maps
%
%   [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname)
PCUconstants

if nargin==4
    % want to be able to overrdie PCUconstants
    ForceRedo=ForceRedoInput;
end

cropCDSbasedir=[base 'GeodatabaseFiles/'];


if ~isequal(areafieldname(1:10),'validation');

    shallowrasterlayerfilename=['shallowrasterlayers/' cropname '_' areafieldname '_' yieldfieldname '.mat'];
    if exist(shallowrasterlayerfilename)==2 & ForceRedo==0
        load(shallowrasterlayerfilename,'ymaptemp','amaptemp');
    else
        [croplandraster,pastureraster]=get2015croppasturearea;

         load([cropCDSbasedir 'MonfredaCGHybrid/CDSRev' CreateHybridGDBRev '_FAOaligned' cropname '_withGADM0field_2000_pm2.mat'],'Cnew');
        CC=Cnew;
        [FAOyield2020,FAOarea2020]=GetAverageFAOData('world',cropname,0,2020,2);
%        FAOyield2020*FAOarea2020
%        nansum([Cnew.M3AreaPerturbedTo2020].*[Cnew.M3YieldPerturbedTo2020])
%        nansum([Cnew.CropGridsArea2020].*[Cnew.M3Yield2020_CGHybridCorrection])

        disp(['allocating ...'])
        tic
        [ymaptemp,amaptemp]=AllocateShallowGDBToRaster(CC,croplandraster,areafieldname,yieldfieldname);
        toc
        productionperpixel=ymaptemp.*amaptemp.*fma;
        TonsProduction_hybridrasters_2020=sum(nansum(productionperpixel));

        save(shallowrasterlayerfilename,'ymaptemp','amaptemp');
    end

else

    disp(['Entering validity test section of ' mfilename])

    % USA Crops
    NASSCropList= {'maize', 'wheat', 'soybean', 'rice',...
        'barley', 'oats', 'cotton', 'groundnut', 'sorghum', ...
        'rapeseed','potato','rye','sugarcane','sweetpotato'};

    IBGECropList  = {'cotton', 'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
        'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
        'sorghum', 'tomato', 'wheat', 'triticale'}


    shallowrasterlayerfilename=['shallowrasterlayers/' cropname '_' areafieldname '_' yieldfieldname '.mat'];
    if exist(shallowrasterlayerfilename)==2 & ForceRedo==0
        load(shallowrasterlayerfilename,'ymaptemp','amaptemp');
    else
        [croplandraster,pastureraster]=get2015croppasturearea;
       load([cropCDSbasedir '/ValidationCDS/CDS_' cropname ],'Cval');

        CC=Cval;

        disp(['allocating ...'])
        tic
        [ymaptemp,amaptemp]=AllocateShallowGDBToRaster(CC,croplandraster,areafieldname,yieldfieldname);
        toc
        productionperpixel=ymaptemp.*amaptemp.*fma;
        TonsProduction_hybridrasters_2020=sum(nansum(productionperpixel));

        save(shallowrasterlayerfilename,'ymaptemp','amaptemp');
    end

end



