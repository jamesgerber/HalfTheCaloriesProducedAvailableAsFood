
load intermediatedatafiles/SortedCropNames2020 Top50WorkingCropsSortedByCalories2020
croplist=Top50WorkingCropsSortedByCalories2020;


CaloriesInDiet=2700;

for j=1:50
    cropname=croplist{j};
    b=readgenericcsv(['CalorieUtilization/CalorieUtilization_c_2010' cropname '.csv'],1,',',1);
    a=readgenericcsv(['CalorieUtilization/CalorieUtilization_c_2020' cropname '.csv'],1,',',1);

    idx=strmatch('World',a.ISO);
    a=subsetofstructureofvectors(a,setdiff(1:numel(a.ISO),idx)); % get rid of ISO='World'
    idx=strmatch('World',b.ISO);
    b=subsetofstructureofvectors(b,setdiff(1:numel(b.ISO),idx)); % get rid of ISO='World'

     % a=subsetofstructureofvectors(a,strmatch('USA',a.ISO));
     % b=subsetofstructureofvectors(b,strmatch('USA',b.ISO));


    a.FractionDirectFood(isnan(a.FractionDirectFood))=0;
    a.FractionFood(isnan(a.FractionFood))=0;
    a.FractionFeed(isnan(a.FractionFeed))=0;
    a.FractionFood(isnan(a.FractionFood))=0;
    a.FractionNonFood(isnan(a.FractionNonFood))=0;
    a.FractionDirectFood(isnan(a.FractionDirectFood))=0;
    
    
    b.FractionDirectFood(isnan(b.FractionDirectFood))=0;
    b.FractionFeed(isnan(b.FractionFeed))=0;
    b.FractionFood(isnan(b.FractionFood))=0;
    b.FractionNonFood(isnan(b.FractionNonFood))=0;
    b.FractionDirectFood(isnan(b.FractionDirectFood))=0;
    
    if j==1
        Cals2020=a.TotalCalories;
        Food2020=a.TotalCalories.*a.FractionFood;
        DirectFood2020=a.TotalCalories.*a.FractionDirectFood;
        Feed2020=a.TotalCalories.*a.FractionFeed;
        NonFood2020=a.TotalCalories.*a.FractionNonFood;
        Area2020=a.Area;


        Cals2010=b.TotalCalories;
        Food2010=b.TotalCalories.*b.FractionFood;
        DirectFood2010=b.TotalCalories.*b.FractionDirectFood;
        Feed2010=b.TotalCalories.*b.FractionFeed;
        NonFood2010=b.TotalCalories.*b.FractionNonFood;
        Area2010=b.Area;
    else
        Cals2020=Cals2020+a.TotalCalories;
        Food2020=Food2020+a.TotalCalories.*a.FractionFood;
        Feed2020=Feed2020+a.TotalCalories.*a.FractionFeed;
        NonFood2020=NonFood2020+a.TotalCalories.*a.FractionNonFood;
        DirectFood2020=DirectFood2020+a.TotalCalories.*a.FractionDirectFood;
Area2020=Area2020+a.Area;


        Cals2010=Cals2010+b.TotalCalories;
        Food2010=Food2010+b.TotalCalories.*b.FractionFood;
        DirectFood2010=DirectFood2010+b.TotalCalories.*b.FractionDirectFood;
        Feed2010=Feed2010+b.TotalCalories.*b.FractionFeed;
        NonFood2010=NonFood2010+b.TotalCalories.*b.FractionNonFood;
        Area2010=Area2010+b.Area;
    end

end
ISOvect=a.ISO;
[ISOGroupList,ISOGroupName]=GetRegionLists(ISOvect);
%ISOGroupList=ISOvect;
%ISOGroupName=ISOvect;
clear DS
for j=1:numel(ISOGroupList);

    clear Production2020 PercentNonFood2020 PercentFood2020 PercentFeed2020 ICF2020 
    clear Production2010 PercentNonFood2010 PercentFood2010 PercentFeed2010 ICF2010
    clear PercentDirectFood2020 PercentDirectFood2010

    ISOList=ISOGroupList{j};
    jj=ismember(a.ISO,ISOList);
    ii=Cals2020>0 & jj;
    Production2020(j)=sum(Cals2020(ii));
    PercentFood2020(j)=sum(Food2020(ii))/Production2020(j);
    PercentDirectFood2020(j)=sum(DirectFood2020(ii))/Production2020(j);
    PercentFeed2020(j)=sum(Feed2020(ii))/Production2020(j);
    PercentNonFood2020(j)=sum(NonFood2020(ii))/Production2020(j);
    ICF2020(j)= (sum(Food2020(ii))-sum(DirectFood2020(ii)))/sum(Feed2020(ii));

    Food2020group(j)=sum(Food2020(ii));
    NonFood2020group(j)=sum(NonFood2020(ii));
    Feed2020group(j)=sum(Feed2020(ii));
    DirectFood2020group(j)=sum(DirectFood2020(ii));
    Area2020group(j)=sum(Area2020(ii));

    Production2010(j)=sum(Cals2010(ii));
    PercentFood2010(j)=sum(Food2010(ii))/Production2010(j);
    PercentDirectFood2010(j)=sum(DirectFood2010(ii))/Production2010(j);
    PercentFeed2010(j)=sum(Feed2010(ii))/Production2010(j);
    PercentNonFood2010(j)=sum(NonFood2010(ii))/Production2010(j);
    ICF2010(j)= (sum(Food2010(ii))-sum(DirectFood2010(ii)))/sum(Feed2010(ii));

    Food2010group(j)=sum(Food2010(ii));
    DirectFood2010group(j)=sum(DirectFood2010(ii));
    NonFood2010group(j)=sum(NonFood2010(ii));
    Feed2010group(j)=sum(Feed2010(ii));
    Area2010group(j)=sum(Area2010(ii));

    DS.Geography{j}=ISOGroupName{j};
    DS.Production2020(j)=Production2020(j);
    DS.PercentDirectFood2020(j)=PercentDirectFood2020(j);
    DS.PercentFeed2020(j)=PercentFeed2020(j);
    DS.PercentNonFood2020(j)=PercentNonFood2020(j);
    DS.DietsPerHa2020Produced(j)=Production2020(j)/365/CaloriesInDiet/Area2020group(j);
    DS.DietsPerHa2020Food(j)=Food2020group(j)/365/CaloriesInDiet/Area2020group(j);

    DS.ICF2020(j)=ICF2020(j);


    % DS.FractionProductionChange2010to2020(j)=Production2020(j)/Production2010(j)-1;
    % DS.FractionFoodGrowth2010to2020(j)=Food2020(j)/Food2010(j)-1;
    % DS.FractionFeedGrowth2010to2020(j)=Feed2020(j)/Feed2010(j)-1;
    % DS.FractionNonFoodGrowth2010to2020(j)=NonFood2020(j)/NonFood2010(j)-1;


    DS.Production2010(j)=Production2010(j);
    DS.PercentDirectFood2010(j)=PercentDirectFood2010(j);
    DS.PercentFeed2010(j)=PercentFeed2010(j);
    DS.PercentNonFood2010(j)=PercentNonFood2010(j);
    DS.DietsPerHa2010Produced(j)=Production2010(j)/365/CaloriesInDiet/Area2010group(j);
    DS.DietsPerHa2010Food(j)=Food2010group(j)/365/CaloriesInDiet/Area2010group(j);

    DS.ICF2010(j)=ICF2010(j);

%    DS.FractionFoodFractionChange2010to2020(j)=PercentFood2020(j)/PercentFood2010(j)-1;
%    DS.FractionFeedFractionChange2010to2020(j)=PercentFeed2020(j)/PercentFeed2010(j)-1;
%    DS.FractionNonFoodFractionChange2010to2020(j)=PercentNonFood2020(j)/PercentNonFood2010(j)-1;
%    DS.FractionICFChange(j)=ICF2020(j)/ICF2010(j)-1;
end

sov2csv(DS,['Table2AllCountries_SensivityStudy_Diet' int2str(CaloriesInDiet) 'Calories.csv']);
