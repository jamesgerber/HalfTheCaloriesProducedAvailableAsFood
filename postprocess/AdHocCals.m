% BarData0=[DirectFoodCaloriesSum FeedCaloriesSum NonFoodCaloriesSum];
% BarData1=[DirectFoodCaloriesSum IndirectFoodCaloriesSum (FeedCaloriesSum-IndirectFoodCaloriesSum) NonFoodCaloriesSum];
% BarData2=[DirectFoodCaloriesSum BeefCalsSum PorkCalsSum ChixCalsSum EggsCalsSum MilkCalsSum BeefCalsLostSum PorkCalsLostSum ChixCalsLostSum EggsCalsLostSum MilkCalsLostSum NonFoodCaloriesSum];

x2010=load(['intermediatedatafiles/horizontalbarchartdata' int2str(2010)],'BarData0','BarData1','BarData2');
x2020=load(['intermediatedatafiles/horizontalbarchartdata' int2str(2020)],'BarData0','BarData1','BarData2');

TotalLivestockFeedCals2020=x2020.BarData2(2:6)+x2020.BarData2(7:11);
TotalLivestockFeedCals2010=x2010.BarData2(2:6)+x2010.BarData2(7:11);
TotalLivestockFoodCals2020=x2020.BarData2(2:6);
TotalLivestockFoodCals2010=x2010.BarData2(2:6);
TotalLivestockLostCals2020=x2020.BarData2(7:11);
TotalLivestockLostCals2010=x2010.BarData2(7:11);

BeefCalShare2020= TotalLivestockFeedCals2020(1)/sum(TotalLivestockFeedCals2020)
BeefCalShare2010= TotalLivestockFeedCals2010(1)/sum(TotalLivestockFeedCals2010)
PorkCalShare2020= TotalLivestockFeedCals2020(2)/sum(TotalLivestockFeedCals2020)
PorkCalShare2010= TotalLivestockFeedCals2010(2)/sum(TotalLivestockFeedCals2010)


x1=100*TotalLivestockFeedCals2010/sum(TotalLivestockFeedCals2010)
x2=100*TotalLivestockFeedCals2020/sum(TotalLivestockFeedCals2020)

Del=TotalLivestockFeedCals2020-TotalLivestockFeedCals2010


percentfeedcalsavailasfood2010=sum(TotalLivestockFoodCals2010)/sum(TotalLivestockFeedCals2010)
percentfeedcalsavailasfood2020=sum(TotalLivestockFoodCals2020)/sum(TotalLivestockFeedCals2020)
