function [CommodityList,IsRoot,CommoditykcalOverGramFactors,datainferredflag,CommoditykcalOverGramFactorsNCT]=prepforSUAfoodfeed(cropname);
% [CommodityList,IsRoot,CommoditykcalOverGramFactors]=prepforSUAfoodfeed(cropname);
%
% useful syntax of sorts:
% for j=1:40
%     prepforSUAfoodfeed(outercroplist{j});
% end
%
% This code works with the Supply Utilization Accounts data from Oct 5,
% 2024 - it will likely break with the next update from FAO (for example, I
% have hard coded some things like "Cake of  soya beans" (two spaces))
%
% [CommodityList,IsRoot,CommoditykcalOverGramFactors,datainferredflag,CommoditykcalOverGramFactorsNCT]=prepforSUAfoodfeed(cropname);


SUA=ReturnSupplyUtilizationAccountsData;
SUA=subsetofstructureofvectors(SUA,SUA.Year==2020);
SUAWorld=subsetofstructureofvectors(SUA,strmatch('World',SUA.Area));

persistent a
if isempty(a)

    a=readgenericcsv('intermediatedatafiles/SheetO3FromNutrientConversionTablenq.txt',0,tab,0);

    a.commoditycals=str2double(a.EDIBLE).*str2double(a.ENERC);
end


switch cropname
    case 'barley'
        CommodityList = { ...
            'Barley', ...
            'Barley flour and grits', ...
            'Barley, pearled', ...
            'Beer of barley, malted', ...
            'Bran of barley', ...
            'Pot barley' ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;
    case 'bean'
        CommodityList = { 'Beans, dry'};
        IsRoot(1)=1;

    case 'pigeonpea'
        CommodityList = { 'Pigeon peas, dry'};
        IsRoot(1)=1;

    case 'mushroom'
        CommodityList={...
            'Mushrooms and truffles', ...
            'Dried mushrooms', ...
           'Canned mushrooms'};
        IsRoot=[1 0 0]


    case 'cassava'
        CommodityList = { ...
            'Cassava, fresh', ...
            'Cassava leaves', ...
            'Cassava, dry', ...
            'Flour of cassava', ...
            'Starch of cassava', ...
            'Tapioca of cassava' ...
            };

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;
    case 'coconut'
        CommodityList = {'Coconuts, in shell','Coconuts, desiccated', ...
            'Coconut oil'};

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;



    case 'maize'
        CommodityList={'Maize (corn)','Beer of maize, malted',...
            'Bran of maize'  ,'Cake of maize'  ,'Flour of maize' ...
            'Germ of maize'  , 'Green corn (maize)'  ,  'Maize gluten', ...
            'Oil of maize'  , 'Starch of maize' };

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'millet'
        CommodityList={ ...
            'Millet', ...
            'Beer of millet, malted', ...
            'Bran of millet', ...
            'Flour of millet', ...
            };

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'oats'
        CommodityList={ ...
            'Oats' , ...
            'Bran of oats' ,'Oats, rolled'};

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;



    case 'potato'
        CommodityList = { ...
            'Potatoes', ...
            'Flour, meal, powder, flakes, granules and pellets of potatoes', ...
            'Potatoes, frozen', ...
            'Starch of potatoes', ...
            'Sweet potatoes', ...
            'Tapioca of potatoes', ...
            'Vegetables, pulses and potatoes, preserved by vinegar or acetic acid' ...
            };

        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;


    case 'rapeseed'
        CommodityList={'Rape or colza seed','Rapeseed or canola oil, crude','Cake of rapeseed'};
        IsRoot=[1 0 0];

    case 'sorghum'
        CommodityList={'Sorghum','Beer of sorghum, malted',    'Bran of sorghum'    'Flour of sorghum'                         };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'soybean'
        CommodityList={'Soya beans','Soya bean oil','Soya curd','Soya paste','Soya sauce','Cake of  soya beans'};
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;
    case 'wheat'
        CommodityList={'Wheat','Bran of wheat','Germ of wheat',...
            'Starch of wheat','Wheat and meslin flour',...
            'Wheat gluten','Wheat-fermented beverages'};
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;
    case 'rice'
        CommodityList = { ...
            'Rice', ...
            'Bran of rice', ...
            'Cake of rice bran', ...
            'Communion wafers, empty cachets of a kind suitable for pharmaceutical use, sealing wafers, rice paper and similar products.', ...
            'Flour of rice', ...
            'Husked rice', ...
            'Oil of rice bran', ...
            'Rice, broken', ...
            'Rice, gluten', ...
            'Rice, milled', ...
            'Rice, milled (husked)', ...
            'Rice-fermented beverages', ...
            'Starch of rice' ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'oilpalm'
        CommodityList = { ...
            'Oil palm fruit', ...
            'Cake of palm kernel', ...
            'Oil of palm kernel', ...
            'Palm kernels', ...
            'Palm oil' ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;
    case 'sugarcane'
        CommodityList = { ...
            'Sugar cane', ...
            'Cane sugar, non-centrifugal' , ...
            'Raw cane or beet sugar (centrifugal only)'  ,...
            'Refined sugar' ,...
            'Sugar and syrups n.e.c.' , ...
            'Sugar confectionery' };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'sugarbeet'
        CommodityList = { ...
            'Sugar beet', ...
            'Refined sugar' ,...
            'Raw cane or beet sugar (centrifugal only)'  ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'sunflower'
        CommodityList = { ...
            'Sunflower seed' , ...
            'Cake of sunflower seed' , ...
            'Sunflower-seed oil, crude'  ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;

    case 'cocoa'
        CommodityList = { ...
            'Cocoa beans' , ...   
            'Cocoa butter, fat and oil',...
            'Cocoa husks and shells'       ,...
            'Cocoa paste not defatted'         ,...
            'Cocoa powder and cake'  ...
            };
        IsRoot(1)=1;
        IsRoot(numel(CommodityList))=0;



    case 'yam'
        CommodityList = { 'Yams'};
        IsRoot(1)=1;

    case 'sweetpotato'
        CommodityList = { 'Sweet potatoes'};
        IsRoot(1)=1;

    case 'banana'
        CommodityList = { 'Bananas'};
        IsRoot(1)=1;

    case 'vegetablenes'
        CommodityList = {'Other vegetables, fresh n.e.c.'};
        IsRoot(1)=1;

    case 'tropicalnes'
        CommodityList =  {'Other tropical fruits, n.e.c.' ,...
            'Other tropical fruit, dried'};
        IsRoot=[1 0];


    case 'tangetc'
        CommodityList =  {'Tangerines, mandarins, clementines' ,...
            'Juice of tangerine'};
        IsRoot=[1 0];

    case 'cucumberetc'
        CommodityList =  {'Cucumbers and gherkins'};
        IsRoot=[1];



    case 'watermelon'
        CommodityList = {'Watermelons'};
        IsRoot(1)=1;


    case 'fruitnes'
        CommodityList = {'Other fruits, n.e.c.','Other fruit n.e.c., dried'};
        IsRoot(1)=1;
        IsRoot(2)=0;



    case 'cerealnes'
        CommodityList = {'Cereals n.e.c.',...
            'Bran of cereals n.e.c.',...
            'Flour of cereals n.e.c.' };
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'chickpea'
        CommodityList = {'Chick peas, dry'};
        IsRoot(1)=1;

    case 'carrot'
        CommodityList = {'Carrots and turnips'};
        IsRoot(1)=1;

    case 'taro'
        CommodityList = {'Taro'};
        IsRoot(1)=1;

    case 'date'
        CommodityList = {'Dates'};
        IsRoot(1)=1;

    case 'ginger'
        CommodityList = {'Ginger, raw'};
        IsRoot(1)=1;

    case 'cabbage'
        CommodityList = {'Cabbages'};
        IsRoot(1)=1;


    case 'pea'
        CommodityList = {'Peas, dry'};
        IsRoot(1)=1;

    case 'garlic'
        CommodityList = {'Green garlic'};
        IsRoot(1)=1;

    case 'plantain'
        CommodityList = {'Plantains and cooking bananas'};
        IsRoot(1)=1;

    case 'cowpea'
        CommodityList = {'Cow peas, dry'};
        IsRoot(1)=1;

    case 'lentil'
        CommodityList = {'Lentils, dry'};
        IsRoot(1)=1;

    case 'mango'
        CommodityList = {'Mangoes, guavas and mangosteens',...
            'Juice of mango' ,...
            'Mango pulp'         };
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'onion'
        CommodityList = {'Onions and shallots, green','Onions and shallots, dry (excluding dehydrated)'};
        IsRoot(2)=1;
        IsRoot(1)=0;


    case 'triticale'
        CommodityList = {'Triticale','Flour of triticale','Bran of triticale'};
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'linseed'
        CommodityList = {'Linseed','Cake of  linseed','Oil of linseed'};
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'groundnut'
        CommodityList = {'Groundnuts, shelled',...
            'Groundnut oil'  ,...
            'Cake of groundnuts',...
            'Groundnuts, excluding shelled'  ,...
            'Prepared groundnuts' };
        IsRoot=[1 0 0 0 0];


    case 'rye'
        CommodityList = {'Rye','Flour of rye','Bran of rye'};
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'apple'
        CommodityList = {'Apples','Apple juice','Apple juice, concentrated'};
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'orange'
        CommodityList = {'Oranges','Orange juice','Orange juice, concentrated'};
        IsRoot(1)=1;
        IsRoot(3)=0;


    case 'olive'
        CommodityList = {'Olives' ,'Oil of olive residues', ...
            'Olive oil' , ...
            'Olives preserved' };
        IsRoot(1)=1;
        IsRoot(4)=0;
    case 'grape'
        CommodityList = {'Grapes',...
            'Must of grape', ...
            'Grape juice' , ...
            'Vermouth and other wine of fresh grapes flavoured with plats or aromatic substances'};
        IsRoot(1)=1;
        IsRoot(4)=0;

    case 'sesame'
        CommodityList = {'Sesame seed','Oil of sesame seed','Cake of sesame seed'};
        IsRoot(1)=1;
        IsRoot(3)=0;

    case 'pulsenes'
        CommodityList = {'Other pulses n.e.c.','Flour of pulses','Bran of pulses'};
        IsRoot(1)=1;
        IsRoot(3)=0;


    case 'broadbean'
        CommodityList = {'Broad beans and horse beans, dry','Broad beans and horse beans, green'};
        IsRoot(1)=1;
        IsRoot(2)=0;


    case 'tomato'
        CommodityList = {'Tomatoes',...
            'Paste of tomatoes',
            'Tomato juice',...
            'Tomatoes, peeled (o/t vinegar)' };
        IsRoot(1)=1;
        IsRoot(4)=0;

    case 'cattlemeat'
        CommodityList={'Meat of cattle with the bone, fresh or chilled'};
        IsRoot(1)=1;

    case 'pigmeat'
        CommodityList={'Meat of pig with the bone, fresh or chilled'};
        IsRoot(1)=1;

    case 'chicken'
        CommodityList={'Meat of chickens, fresh or chilled'};
        IsRoot(1)=1;

    case 'milk'
        CommodityList={'Raw milk of cattle'};
        IsRoot(1)=1;

    case 'eggs'
        CommodityList={'Hen eggs in shell, fresh'};
        IsRoot(1)=1;

    otherwise
        disp(['found nothing for ' cropname])
        return
end


for j=1:numel(CommodityList);

    comm=CommodityList{j};

    SUA=subsetofstructureofvectors(SUAWorld,strmatch(comm,SUAWorld.Item,'exact'));

    ii_kcals=strmatch('Calories/Year',SUA.Element);
    ii_g=strmatch('Food supply quantity (tonnes)',SUA.Element);
    if isempty(ii_kcals) | isempty(ii_g)
        kcals2tons=nan;
        datainferredflag(j)=0;
    else
        kcals2tons=SUA.Value(ii_kcals)./SUA.Value(ii_g);
        datainferredflag(j)=1;
    end


    CommoditykcalOverGramFactors(j)=kcals2tons;

    % code to get kcals2tons from NutrientConversionTable
    s=unique(SUA.Item_Code_CPC);
    s=char(s);
    s=strrep(s,"'",'');
    idx=strmatch(s,a.Code);
    if numel(idx)==1
        CommoditykcalOverGramFactorsNCT(j)=a.commoditycals(idx)/100;
    else
        CommoditykcalOverGramFactorsNCT(j)=nan;
    end
end
% can we infer a value from NutrientConversionTable



% now maybe some overrides:

switch cropname
    % debugging code - lentil good to work with.
    % case 'lentil'
    %     CommoditykcalOverGramFactors=1;
    %     warndlg('messed with prepforSUAfoodfeed for lentil')
    case 'soybean'
        % source https://www.feedipedia.org/node/674

        idx=strmatch('Cake of  soya beans',CommodityList);
        CommoditykcalOverGramFactors(idx)=19.7/4.184*.88; % 4.7084, 4.1434

    case 'rapeseed'
        % source https://www.feedipedia.org/node/52
        idx=strmatch('Cake of rapeseed',CommodityList);

        CommoditykcalOverGramFactors(idx)=19.3/4.184*.89; % 4.7084, 4.1434

    case 'sesame'
        % SAME AS RAPESEED
        idx=strmatch('Cake of sesame seed',CommodityList);

        CommoditykcalOverGramFactors(idx)=19.3/4.184*.89; % 4.7084, 4.1434


    case 'rice'
        % source https://www.feedipedia.org/node/750
        idx=strmatch('Cake of rice bran',CommodityList);

        CommoditykcalOverGramFactors(idx)=20.5/4.184*.90; % 4.7084, 4.1434

        idx=strmatch('Rice, gluten',CommodityList);
        % using value for maize gluten
        % source: https://www.feedipedia.org/node/12288
        CommoditykcalOverGramFactors(idx)=23.1/4.184*.90; % 4.7084, 4.1434



    case 'oilpalm'
        % source https://www.feedipedia.org/node/43
        idx=strmatch('Cake of palm kernel',CommodityList);;
        CommoditykcalOverGramFactors(idx)=20.1/4.184*.912; % 4.7084, 4.1434
        % source https://www.feedipedia.org/node/15405
        idx=strmatch('Palm kernels',CommodityList);
        CommoditykcalOverGramFactors(idx)=28.4/4.184*.918; % 4.7084, 4.1434

        idx=strmatch('Oil palm fruit',CommodityList);
        CommoditykcalOverGramFactors(idx)=1.580000; % 4.7084, 4.1434
        %source: FAO numbers from Emily worksheet. (note that Tilman number
        %different - I suspect that Tilman number is one of the others.


    case 'barley'
        % source https://www.feedipedia.org/node/4266
        % used values for Malt distillers dark grains, dried
        idx=strmatch('Bran of barley',CommodityList);

        CommoditykcalOverGramFactors(idx)=21.3/4.184*.907; % 4.7084, 4.1434

    case 'millet'
        idx=strmatch('Bran of millet',CommodityList);
        % source: assume same as bran of barley
        CommoditykcalOverGramFactors(idx)=21.3/4.184*.907; % 4.7084, 4.1434

    case 'sunflower'
        idx=strmatch('Cake of sunflower seed',CommodityList);
        % source: https://www.feedipedia.org/node/732
        CommoditykcalOverGramFactors(idx)=19.4/4.184*.89; % 4.7084, 4.1434

    case 'oats'
        idx=strmatch('Bran of oats',CommodityList);
        % source: https://www.feedipedia.org/node/707
        CommoditykcalOverGramFactors(idx)=18.4/4.184*.903; % 4.7084, 4.1434

    case 'maize'
        idx=strmatch('Bran of maize',CommodityList);
        % source: https://www.feedipedia.org/node/712
        CommoditykcalOverGramFactors(idx)=18.5/4.184*.887; % 4.7084, 4.1434

        idx=strmatch('Cake of maize',CommodityList);
        % source: https://www.feedipedia.org/node/712
        CommoditykcalOverGramFactors(idx)=18.5/4.184*.887; % 4.7084, 4.1434

        idx=strmatch('Maize gluten',CommodityList);
        % source: https://www.feedipedia.org/node/12288
        CommoditykcalOverGramFactors(idx)=23.1/4.184*.90; % 4.7084, 4.1434

        

    case 'triticale'
        idx=strmatch('Bran of triticale',CommodityList);
        %  SAME AS MAIZE
        CommoditykcalOverGramFactors(idx)=18.5/4.184*.887; % 4.7084, 4.1434

    case 'cerealnes'
        idx=strmatch('Bran of cereals n.e.c.',CommodityList);
        %  SAME AS MAIZE
        CommoditykcalOverGramFactors(idx)=18.5/4.184*.887; % 4.7084, 4.1434


    case 'linseed'
        %source https://www.feedipedia.org/node/735
        idx=strmatch('Cake of  linseed',CommodityList);
        CommoditykcalOverGramFactors(idx)=20.7/4.184*.906; % 4.7084, 4.1434

    case 'pulsenes'
        % source - assume lentils:  https://www.feedipedia.org/node/12246
        idx=strmatch('Bran of pulses',CommodityList);
        CommoditykcalOverGramFactors(idx)=18.6/4.184*.889; % 4.7084, 4.1434

    case 'groundnut'
        % source - assume bambara groundnut https://www.feedipedia.org/node/531
        idx=strmatch('Cake of groundnuts',CommodityList);
        CommoditykcalOverGramFactors(idx)=17.2/4.184*.913; % 4.7084, 4.1434

    otherwise

end


% clear up ... anything that isnan gets booted.

ii=isfinite(CommoditykcalOverGramFactors);
CommoditykcalOverGramFactors=CommoditykcalOverGramFactors(ii);
%disp(['Omitting ' CommodityList{~ii}])
CommodityList=CommodityList(ii);
IsRoot=IsRoot(ii);
datainferredflag=datainferredflag(ii);
if sum(IsRoot)~=1
    error
end
