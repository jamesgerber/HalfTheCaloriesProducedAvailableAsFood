PCUconstants
cd(workingdirectory)
ISO='world';
YYYY=2015;


[IndirectCalfactor,TonsMeatVector, TonsFeedVector,RFVNWorld]=CalculateIndirectCalories('World',YYYY);

CPD=ReturnCropProductionData;
CD=subsetofstructureofvectors(CPD,CPD.Year==YYYY);
%CD=subsetofstructureofvectors(CD,strmatch('United States of America',CD.Area));
%CDyield=subsetofstructureofvectors(CD,strmatch('Yield',CD.Element))
%CDarea=subsetofstructureofvectors(CD,strmatch('Area h',CD.Element))

load intermediatedatafiles/SortedCropNames2020.mat CropsSortedByCalories2020 Top50WorkingCropsSortedByCalories2020
outercroplist=Top50WorkingCropsSortedByCalories2020;
%outercroplist={'maize'};
% [CommodityList,IsRoot,cattlekcalovergram,datainferredflag]=prepforSUAfoodfeed('cattlemeat');
%
% [CommodityList,IsRoot,pigkcalovergram,datainferredflag]=prepforSUAfoodfeed('pigmeat');
% [CommodityList,IsRoot,chickenkcalovergram,datainferredflag]=prepforSUAfoodfeed('chicken');
% [CommodityList,IsRoot,eggskcalovergram,datainferredflag]=prepforSUAfoodfeed('eggs');
% [CommodityList,IsRoot,milkkcalovergram,datainferredflag]=prepforSUAfoodfeed('milk');
cc_beef=0.0308; % calorie conversion
cc_pork=0.1043;
cc_chicken=0.1178;
cc_eggs=0.2207;
cc_dairy=0.4025;


DirectFoodCaloriesSum=0;
IndirectFoodCaloriesSum=0;
NonFoodCaloriesSum=0;
FeedCaloriesSum=0;
FoodCaloriesSum=0;
BeefCalsLostSum=0;
PorkCalsLostSum=0;
ChixCalsLostSum=0;
EggsCalsLostSum=0;
MilkCalsLostSum=0;

BeefCalsSum=0;
PorkCalsSum=0;
ChixCalsSum=0;
EggsCalsSum=0;
MilkCalsSum=0;

AreaToNonFoodSum=0;
AreaToFeedSum=0;
AreaToBeefSum=0;
AreaSum=0;



for j=1:numel(outercroplist)
    cropname=outercroplist{j};
    a=readgenericcsv(['CalorieUtilization/CalorieUtilization_c_' int2str(YYYY) cropname '.csv']);

    % World is first, remove
    if isequal(a.ISO{1},'World')
        a=subsetofstructureofvectors(a,2:numel(a.ISO));
    else
        error
    end


    % need to get weights for reconstructing lost calories, etc:
    FigString=[cropname ' w/ Livestock Conv ' int2str(YYYY) ];
    matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';
    x=load([matfilesdirectory makesafestring(FigString)],'CalorieExportData')



    ISOlist=unique(a.ISO);

    % % a=subsetofstructureofvectors(a,242)
    % % ISOlist=a.ISO;
%ISOlist={'USA'}
    for m=1:numel(ISOlist);
        ISO=ISOlist{m};
        if isequal(lower(ISO),'world')
            error
        end
        try
            [IndirectCalfactor,TonsMeatVector, TonsFeedVector,RFVN]=CalculateIndirectCalories(ISO,YYYY);
        catch
            RFVN=[-1 -1 -1 -1 -1]*0;
        end

% Correct RFVN
CED=x.CalorieExportData;
idx=strmatch(ISO,CED.ISOlist);

if numel(idx)==1
RFVNdom=CED.RFVNdomlist{idx};
RFVNexp=CED.RFVNworldlist{idx};
aa=CED.a(idx);
bb=CED.b(idx);
RFVN;
RFVN=(aa*RFVNdom+bb*RFVNexp)/(aa+bb);
else
    RFVN=[0 0 0 0 0];
end


        idx=strmatch(ISO,a.ISO);
        a.Year(idx)=YYYY;
        a.CropName{idx}=cropname;
        a.hbeef(idx)=RFVN(1); % eta beef - fraction of feed calories that went to beef
        a.hpork(idx)=RFVN(2);
        a.hchix(idx)=RFVN(3);
        a.heggs(idx)=RFVN(4);
        a.hmilk(idx)=RFVN(5);
        a.beefcals(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(1)*cc_beef;
        a.porkcals(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(2)*cc_pork;
        a.chixcals(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(3)*cc_chicken;
        a.eggscals(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(4)*cc_eggs;
        a.dairycals(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(5)*cc_dairy;
        a.beefcalslost(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(1)*(1-cc_beef);
        a.porkcalslost(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(2)*(1-cc_pork);
        a.chixcalslost(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(3)*(1-cc_chicken);
        a.eggscalslost(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(4)*(1-cc_eggs);
        a.dairycalslost(idx)=a.TotalCalories(idx).*str2double(a.FractionFeed(idx)).*RFVN(5)*(1-cc_dairy);

        a.TotalCaloriesReconstructedInLoop(idx)=a.TotalCalories(idx);
    end

    disp('temp taking out csv')
    %     sov2csv(a,['CalUtilization_WithAnimalProducts' cropname '.csv']);

    %b=sov2vos(a);
    %b(243) % usa

    % for this crop let's get total food calories:

    DirectFoodCalories=nansum(a.TotalCalories.*str2double(a.FractionDirectFood));
    NonFoodCalories=nansum(a.TotalCalories.*str2double(a.FractionNonFood));
    FeedCalories=nansum(a.TotalCalories.*str2double(a.FractionFeed));
    FoodCalories=nansum(a.TotalCalories.*str2double(a.FractionFood));
    IndirectFoodCalories=nansum(a.TotalCalories.*str2double(a.IndirectFood));
  %  IndirectFoodCalories=nansum(a.TotalCalories(idx).*str2double(a.IndirectFood(idx)));

    BeefCals=nansum(a.beefcals);
    PorkCals=nansum(a.porkcals);
    ChixCals=nansum(a.chixcals);
    EggsCals=nansum(a.eggscals);
    MilkCals=nansum(a.dairycals);
    BeefCalsLost=nansum(a.beefcalslost);
    PorkCalsLost=nansum(a.porkcalslost);
    ChixCalsLost=nansum(a.chixcalslost);
    EggsCalsLost=nansum(a.eggscalslost);
    MilkCalsLost=nansum(a.dairycalslost);


    DirectFoodCaloriesSum=DirectFoodCaloriesSum+DirectFoodCalories
    IndirectFoodCaloriesSum=IndirectFoodCaloriesSum+IndirectFoodCalories
    NonFoodCaloriesSum=NonFoodCaloriesSum+NonFoodCalories
    FeedCaloriesSum=FeedCaloriesSum+FeedCalories
    FoodCaloriesSum=FoodCaloriesSum+FoodCalories

    
    BeefCalsLostSum=BeefCalsLostSum+BeefCalsLost
    PorkCalsLostSum=PorkCalsLostSum+PorkCalsLost
    ChixCalsLostSum=ChixCalsLostSum+ChixCalsLost
    EggsCalsLostSum=EggsCalsLostSum+EggsCalsLost
    MilkCalsLostSum=MilkCalsLostSum+MilkCalsLost




    BeefCalsSum=BeefCalsSum+BeefCals;
    PorkCalsSum=PorkCalsSum+PorkCals;
    ChixCalsSum=ChixCalsSum+ChixCals;
    EggsCalsSum=EggsCalsSum+EggsCals;
    MilkCalsSum=MilkCalsSum+MilkCals;



    % need to relate calories to land.
    [CommodityList,IsRoot,CommoditykcalOverGramFactors]=prepforSUAfoodfeed(cropname);
    idx=IsRoot==1;
    CalsPerGramSUA=CommoditykcalOverGramFactors(idx);
    CalsPerTonSUA=CommoditykcalOverGramFactors(idx)*1e6;
    [FAOyield,FAOarea]=GetAverageFAOData(ISO,cropname,0,YYYY,0);

    TotalCalories(j)=sum(a.TotalCalories);
    AreaToNonFood(j)=FAOarea*nansum(str2double(a.FractionNonFood));
    AreaToFeed(j)=FAOarea*nansum(str2double(a.FractionFeed));
    AreaToBeef(j)=FAOarea*nansum(str2double(a.FractionFeed)*str2double(a.hbeef));
    AreaToFood(j)=FAOarea*nansum(str2double(a.FractionDirectFood));
    Area(j)=FAOarea;
;

    % AreaToNonFoodSum=AreaToNonFoodSum+AreaToNonFood;
    % AreaToFeedSum=AreaToFeedSum+AreaToFeed;
    % AreaToBeefSum=AreaToBeefSum+AreaToBeef;
    % AreaSum=AreaSum+Area;

end

% nansum(Area)/1e6
% nansum(AreaToNonFood)
% nansum(AreaToFeed)
% nansum(AreaToBeef)
% 
% nansum(Area)./nansum(Area)
% nansum(AreaToNonFood)./nansum(Area)
% nansum(AreaToFeed)./nansum(Area)
% nansum(AreaToBeef)./nansum(Area)
% nansum(AreaToFood)/nansum(Area)
% 
% 



BarData0=[DirectFoodCaloriesSum FeedCaloriesSum NonFoodCaloriesSum];
BarData1=[DirectFoodCaloriesSum IndirectFoodCaloriesSum (FeedCaloriesSum-IndirectFoodCaloriesSum) NonFoodCaloriesSum];
BarData2=[DirectFoodCaloriesSum BeefCalsSum PorkCalsSum ChixCalsSum EggsCalsSum MilkCalsSum BeefCalsLostSum PorkCalsLostSum ChixCalsLostSum EggsCalsLostSum MilkCalsLostSum NonFoodCaloriesSum];

%figure,barh(1,BarData1,'stacked')
%legend('direct food cals','indirect food','feed "lost"','lost cals')

save(['intermediatedatafiles/horizontalbarchartdata' int2str(YYYY)],'BarData0','BarData1','BarData2');

%
% BarData2=[]
%

percentoflostcaloriesfromBeef=BeefCalsLostSum/sum([BeefCalsLostSum PorkCalsLostSum ChixCalsLostSum EggsCalsLostSum MilkCalsLostSum ])

[BeefCalsLostSum PorkCalsLostSum ChixCalsLostSum EggsCalsLostSum MilkCalsLostSum NonFoodCaloriesSum]/...
    sum([BeefCalsLostSum PorkCalsLostSum ChixCalsLostSum EggsCalsLostSum MilkCalsLostSum NonFoodCaloriesSum])


% total food cals




