

load intermediatedatafiles/SortedCropNames2020 Top50WorkingCropsSortedByCalories2020
outercroplist=Top50WorkingCropsSortedByCalories2020

for jouter=[1 2 3]
    switch jouter
        case 1
            YYYYstr='2010'
        case 2
            YYYYstr='2015'
        case 3
            YYYYstr='2020'
    end

    fidout2=fopen(['intermediatedatafiles/CalorieUtilizationGlobalSummaryOutput' YYYYstr '.csv'],'w');
    %fidout2=fopen(['summaryoutput' YYYYstr 'Tons.csv'],'w');

    for j=1:numel(outercroplist)
        cropname=outercroplist{j};
        %%
        [CommodityList,IsRoot,CommoditykcalOverGramFactors]=prepforSUAfoodfeed(cropname);
        idx=IsRoot==1;
        CalsPerGramSUA=CommoditykcalOverGramFactors(idx);
        CalsPerTonSUA=CommoditykcalOverGramFactors(idx)*1e6;


        %%
        fid=fopen(['CalorieUtilization/CalorieUtilization_c_' YYYYstr  cropname '.csv']);
        x=fgetl(fid);

        if j==1
            %        fprintf(fidout,'crop,%s\n',x);
            fprintf(fidout2,'crop,%s,%s\n',x,'CalsPerTon');

        end
        x=fgetl(fid);

        %    fprintf(fidout,'%s,%s\n',cropname,x);
        fprintf(fidout2,'%s,%s,%f\n',cropname,x,CalsPerTonSUA);

        fclose(fid);
    end
    %fclose(fidout);
    fclose(fidout2);



end

CombineCalorieUtilizationFilesAcrossCrops