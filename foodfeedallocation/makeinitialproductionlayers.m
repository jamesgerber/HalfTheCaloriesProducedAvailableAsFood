% script to make production layers

outercroplist=CropListForProcessing;


areafieldname='CropGridsArea2020';
yieldfieldname='M3Yield2020_CGHybridCorrection';

for jcrop=1:numel(outercroplist);
    cropstring=outercroplist{jcrop};
    disp(cropstring)
    cropname=cropstring;
    [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname);
end



areafieldname='LinearSuperposedArea2010';
yieldfieldname='M3Yield2010_CGHybridCorrection';

for jcrop=1:numel(outercroplist);
    cropstring=outercroplist{jcrop};
    disp(cropstring)
    cropname=cropstring;
    [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
end



areafieldname='LinearSuperposedArea2015';
yieldfieldname='M3Yield2015_CGHybridCorrection';

for jcrop=1:numel(outercroplist);
    cropstring=outercroplist{jcrop};
    disp(cropstring)
    cropname=cropstring;
    [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
end



NASSCropList= {'maize', 'wheat', 'soybean', 'rice',...
    'barley', 'oats', 'cotton', 'groundnut', 'sorghum', ...
    'rapeseed','potato','rye','sugarcane','sweetpotato'};

IBGECropList  = {'cotton', 'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
    'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
    'sorghum', 'tomato', 'wheat', 'triticale'};

MoreDataCrop=union(NASSCropList,IBGECropList);

ii=ismember(outercroplist,MoreDataCrop);
validatecroplist=outercroplist(ii);


for jcrop=1:numel(validatecroplist);
    cropstring=validatecroplist{jcrop};
    disp(cropstring)
    cropname=cropstring;
    % areafieldname='validationtestarea2019';
    % yieldfieldname='validationtestyield2019';
    % [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
    areafieldname='validationtestarea2020';
    yieldfieldname='validationtestyield2020';
    [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
    % areafieldname='validationtestarea2021';
    % yieldfieldname='validationtestyield2021';
    % [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
     areafieldname='validationtestarea2000';
     yieldfieldname='validationtestyield2000';
    % [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,0);
end