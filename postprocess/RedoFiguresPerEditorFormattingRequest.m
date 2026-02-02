% this script remakes figures from combinecaloriemaps_MultiplyFractions.m
% with slightly different wording.



%!open output/figures/Total_calorie_production_50_crops_c_2020.png
load output/figures/Total_calorie_production_50_crops_c_2020_SavedFigureData.mat

NSS.titlestring='Total calorie production';
NSS.MakePlotDataFile='off';
NSS.filename='output/figuresRevised/'
nsg(OS.Data,NSS);
NSS.filename='temp';
DataToDrawdownFigures(OS.Data,NSS,'totalcalorieproduction','output/figuresRevised/')



load output/figures/Percentage_of_production_available_as_food_50_crops_c_2020_SavedFigureData.mat

NSS.titlestring='Percentage of calorie production available as food';
NSS.MakePlotDataFile='off';
NSS.filename='output/figuresRevised/'
nsg(OS.Data,NSS);
NSS.filename='temp';
DataToDrawdownFigures(OS.Data,NSS,'PercentageCalProdAvailFood','output/figuresRevised/')
%!open output/figures/People_fed_on_calorie_production_available_as_food_50_crops_c_2020.png

%!open output/figures/People_fed_on_total_calories_production_50_crops_c_2020.png


load output/figures/People_fed_on_calorie_production_available_as_food_50_crops_c_2020_SavedFigureData
NSS.titlestring='People fed on calorie production available as food';
NSS.MakePlotDataFile='off';
NSS.filename='output/figuresRevised/'
nsg(OS.Data,NSS);
NSS.filename='temp';
NSS.filename='temp';
DataToDrawdownFigures(OS.Data,NSS,'peoplefedoncalorieproductionavailasfood','output/figuresRevised/')


load output/figures/People_fed_on_total_calories_production_50_crops_c_2020_SavedFigureData
NSS.titlestring='People fed on total calorie production';
NSS.MakePlotDataFile='off';
NSS.filename='output/figuresRevised/'
nsg(OS.Data,NSS);
NSS.filename='temp';
DataToDrawdownFigures(OS.Data,NSS,'peoplefedontotalcalorieproduction','output/figuresRevised/')


