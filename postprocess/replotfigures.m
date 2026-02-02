% replotfigures



%Validation figures - percentage
x1=load('output/figures/Percentage_of_production_available_as_food_Brasil_validation_set_16_crops_2020_SavedFigureData');
x2=load('output/figures/Percentage_of_production_available_as_food_Brasil_comparison_set_16_crops_2020_SavedFigureData');

NSS=x1.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Percentage of production available as food. ',...
    'Validation (IBGE), 16 crops 2020'};
NSS.mappingtoolbox='off'
MakeNiceRegionalFigs(x1.OS.Data,'BRA',NSS,'fraccaloriprodBRAIBGE');

NSS=x2.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Percentage of production available as food. ',...
    'Comparison (Present method), 16 crops 2020'};
NSS.mappingtoolbox='off'


MakeNiceRegionalFigs(x2.OS.Data,'BRA',NSS,'fraccaloriprodBRAIBGECompareCrops');

%% Validation figures - total calorie prod
x1=load('output/figures/Total_calorie_production_Brasil_validation_set_16_crops_2020_SavedFigureData');
x2=load('output/figures/Total_calorie_production_Brasil_comparison_set_16_crops_2020_SavedFigureData');

NSS=x1.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude');
NSS.mappingtoolbox='off'
NSS.titlestring= {'Total calorie production ',...
    'Validation (IBGE), 16 crops 2020'}
MakeNiceRegionalFigs(x1.OS.Data,'BRA',NSS,'totcaloriprodBRAIBGE');

NSS=x2.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Total calorie production ',...
    'Comparison  (Present method), 16 crops 2020'};
NSS.mappingtoolbox='off'


MakeNiceRegionalFigs(x2.OS.Data,'BRA',NSS,'totcaloriprodBRAIBGECompareCrops');


%%
%Validation figures - percentage
x1=load('output/figures/Percentage_of_production_available_as_food_USA_validation_set_13_crops_2020_SavedFigureData');
x2=load('output/figures/Percentage_of_production_available_as_food_USA_comparison_set_13_crops_2020_SavedFigureData');

NSS=x1.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Percentage of production available as food. ',...
    'Validation (NASS), 13 crops 2020'};
NSS.mappingtoolbox='off'
MakeNiceRegionalFigs(x1.OS.Data,'USA',NSS,'fraccaloriprodUSANASS');

NSS=x2.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Percentage of production available as food. ',...
    'Comparison (Present method), 13 crops 2020'};
NSS.mappingtoolbox='off'


MakeNiceRegionalFigs(x2.OS.Data,'USA',NSS,'fraccaloriprodUSANASSCompareCrops');

% Validation figures - total calorie prod
x1=load('output/figures/Total_calorie_production_USA_validation_set_13_crops_2020_SavedFigureData');
x2=load('output/figures/Total_calorie_production_USA_comparison_set_13_crops_2020_SavedFigureData');

NSS=x1.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude');
NSS.mappingtoolbox='off'
NSS.titlestring= {'Total calorie production ',...
    'Validation (NASS), 13 crops 2020'}
MakeNiceRegionalFigs(x1.OS.Data,'USA',NSS,'totcaloriprodUSANASS');

NSS=x2.NSS;
NSS.MakePlotDataFile='off';
NSS=rmfield(NSS,'logicalinclude')
NSS.titlestring= {'Total calorie production ',...
    'Comparison  (Present method), 13 crops 2020'};
NSS.mappingtoolbox='off'


MakeNiceRegionalFigs(x2.OS.Data,'USA',NSS,'totcaloriprodUSANASSCompareCrops');
