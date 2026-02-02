load intermediatedatafiles/horizontalbarchartdata2010
BD0_2010=BarData0;
BD1_2010=BarData1;
BD2_2010=BarData2;
load intermediatedatafiles/horizontalbarchartdata2020
BD0_2020=BarData0;
BD1_2020=BarData1;
BD2_2020=BarData2;


y=[BD0_2020;BD0_2010];
x=[2020 2010];
figure
h=barh(x,y,'stacked')
axis('ij')
legend('direct food','feed','non-food')
xlabel('calories')
reallyfattenplot
grid on
h(1).LineWidth=0.01;
h(2).LineWidth=0.01;
h(3).LineWidth=0.01;
outputfig('Force','output/figures/Fig1_HorizontalBarChartFoodFeedNonfoodCalories')


%% 
y=[BD2_2020;BD2_2010];
x=[2020 2010];
figure('position',[316   689   929   446])
h=barh(x,y,'stacked')
axis('ij')
legend('direct food','beef cals','pork cals','chix cals','egg cals','milk cals'...
    ,'beef cals lost','pork cals lost','chix cals lost','egg cals lost ','milk cals lost ','non-food',...
      'location','southoutside')
xlabel('calories')
reallyfattenplot
grid on

colorlist={[0 0.4470 0.7410],...
    [1 0 0],...
    [.9 0 0], [.8 0 0],[.7 0 0],[.6 0 0]...
    [0 1 0],[0 .9 0],[0 .8 0],[0 .7 0],[0 .6 0],...
    [0.9290 0.6940 0.1250]};

for j=1:12
h(j).LineWidth=0.01;
h(j).FaceColor=colorlist{j};
end
outputfig('Force','output/figures/FigX_HorizontalBarChartFoodFeedNonfoodCalories_CalsLost')


%%  figure of justcalories

BD2_2010=BD2_2010(2:end-1);
BD2_2020=BD2_2020(2:end-1);

y=[BD2_2020/sum(BD2_2020);BD2_2010/sum(BD2_2010)]*100;
x=[2020 2010];
figure('position',[316   689   929   446])
h=barh(x,y,'stacked')
axis('ij')
legend('beef cals','pork cals','chix cals','egg cals','milk cals'...
    ,'beef cals lost','pork cals lost','chix cals lost','egg cals lost ','milk cals lost ',...
    'location','southoutside')
uplegend
uplegend
uplegend
uplegend
xlabel('% calories')
zeroxlim(0,100)
reallyfattenplot
grid on

colorlist={...
    [1 0 0],...
    [.9 0 0], [.8 0 0],[.7 0 0],[.6 0 0]...
    [0 1 0],[0 .9 0],[0 .8 0],[0 .7 0],[0 .6 0]};

for j=1:10
h(j).LineWidth=0.01;
h(j).FaceColor=colorlist{j};
end
outputfig('Force','output/figures/JustFeedCalories')
