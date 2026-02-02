
clear DS
for jouter=[1:3]
    switch jouter
        case 1
            YYYYstr='2010'
        case 2
            YYYYstr='2015'
        case 3
            YYYYstr='2020'
    end

    a=readgenericcsv(['intermediatedatafiles//CalorieUtilizationGlobalSummaryOutput' YYYYstr '.csv']);

    DS(jouter).Year=YYYYstr;
    DS(jouter).Region='World'
    DS(jouter).TotalCalories=sum(a.TotalCalories);
    DS(jouter).TotalDirectFoodCalories=sum(a.TotalCalories.*a.FractionDirectFood);
    DS(jouter).TotalNonFoodCalories=sum(a.TotalCalories.*a.FractionNonFood);
    DS(jouter).TotalFeedCalories=sum(a.TotalCalories.*a.FractionFeed);
    DS(jouter).TotalIndirectFoodCalories=sum(a.TotalCalories.*a.IndirectFood);
    DS(jouter).TotalFoodCalories=sum(a.TotalCalories.*a.FractionFood);
    DS(jouter).PercentCaloriesToFeed=100*DS(jouter).TotalFeedCalories/DS(jouter).TotalCalories;
    DS(jouter).PercentCaloriesToNonFood=100*DS(jouter).TotalNonFoodCalories/DS(jouter).TotalCalories;
    DS(jouter).PercentCaloriesToIndFood=100*DS(jouter).TotalIndirectFoodCalories/DS(jouter).TotalCalories;
    DS(jouter).AvgConversionOfIndirectFood=100*DS(jouter).TotalIndirectFoodCalories/DS(jouter).TotalFeedCalories;
   
    
    % percent cals lost to animal conversion = (feed - indirectfood) / total calories
    DS(jouter).PercentCalsLostToAnimalConversion=100*...
        (DS(jouter).TotalFeedCalories-DS(jouter).TotalIndirectFoodCalories)/DS(jouter).TotalCalories;


    % percent call to all non-food = (nonfood + feed- indirectfood) / total
    % calories
    DS(jouter).PercentCalsToAllNonFood=100*...
        (DS(jouter).TotalNonFoodCalories+DS(jouter).TotalFeedCalories-DS(jouter).TotalIndirectFoodCalories)...
        /DS(jouter).TotalCalories;

end
    sov2csv(vos2sov(DS),'intermediatedatafiles/CalorieUtilizationUberSummary.csv');
    