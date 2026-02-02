a=readgenericcsv('intermediatedatafiles/DietShiftCalcsnq.txt',1,tab,1)
b=readgenericcsv('inputdata/LIFDCs.csv')
y = importUNRegionData("inputdata/UNSD — Methodology.xlsx", "Sheet1", [2, Inf]);

cl=load('intermediatedatafiles/calorielayersc_202050_crops')

sfd=load('output/figures/Total_calorie_production_50crops_crops_c_2020_SavedFigureData.mat')
tcp=sfd.OS.Data;
%sum(nansum(tcp.*fma*1e6))  % sanity check - getting the right numbers.

%ii=find(a.Country_is_high_income==1 & isfinite(a.Excess_Beef));

jj=1:numel(a.Country_is_high_income);  % legacy code for limiting table.

clear DS

for j=1:numel(jj)

    m=jj(j);

M49Code=a.Area_Code_M49(m);

try

    idx=find(M49Code==y.M49Code);
    ISO=y.ISOalpha3Code{idx}
    [g0,ii,countryname,ISO]=getgeo41_g0(ISO);
catch
ISO='XXX';
    ii=[];
end

    DS(j).Area=strrep(a.Area(m),',',' ');
    DS(j).Areagadm=strrep(countryname,',',' ');
    DS(j).ISO=ISO;
    DS(j).AreaCodeM49=a.Area_Code_M49(m);
    DS(j).BovineMeat=a.Bovine_Meat(m); 
    DS(j).ExcessBeef=a.Excess_Beef(m)/1e3;
    DS(j).ExcessBeefPerCapita=a.Excess_Beef(m)/ a.Population(m);
    EB=a.Excess_Beef(m);

    EBFoodCals=EB*1.591e3;    %calories per kg beef, source FAO Food Balance Sheets

    EBFeedCalories=EBFoodCals/0.0308*(1-0.15);

    ChickenFeedCals=EBFoodCals/0.1178;


    DS(j).ExcessBeefFeedCalories=EBFeedCalories;
    DS(j).ExcessBeefAsChickenCalories=ChickenFeedCals;
    DS(j).SavedCaloriesIfChicken=EBFeedCalories-ChickenFeedCals;
    DS(j).TotalCalories=nansum(cl.caloriesavailablemap(ii));
    DS(j).TotalFeedCalories=nansum(cl.feedcaloriemapavg(ii));
    DS(j).TotalNonFoodCalories=nansum(cl.nonfoodcaloriemapavg(ii));
    DS(j).TotalDirectFoodCalories=nansum(cl.directfoodcaloriemapavg(ii));
    DS(j).TotalCaloriesProcessCheckCalculation=nansum(tcp(ii).*fma(ii))*1e6;

end

% now some sorting

DQ=[DS.TotalCaloriesProcessCheckCalculation]./[DS.TotalCalories];

DQflag=DQ>0.98;

D=vos2sov(DS);
D.DQflag=DQflag;

G=subsetofstructureofvectors(D,D.DQflag==1);

[~,iisort]=sort(G.ExcessBeefPerCapita,'descend');

Gsort=subsetofstructureofvectors(G,iisort);
Gsort=rmfield(Gsort,'DQflag');

sov2csv(Gsort,'output/LivestockCalories.csv')

    