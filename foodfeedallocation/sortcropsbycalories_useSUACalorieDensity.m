cc=getcropcharacteristics;

croplist=cc.CROPNAME;;

CPD=ReturnCropProductionData;
CPD=subsetofstructureofvectors(CPD,CPD.Year==2020);
CPD=subsetofstructureofvectors(CPD,strmatch('World',CPD.Area));
CPD=subsetofstructureofvectors(CPD,strmatch('Production',CPD.Element));

FBS=ReturnFBSData
FBS=subsetofstructureofvectors(FBS,FBS.Year==2020);
FBS=subsetofstructureofvectors(FBS,strmatch('World',FBS.Area));
FBSProd=subsetofstructureofvectors(FBS,strmatch('Production',FBS.Element));

SUA=ReturnSupplyUtilizationAccountsData;
SUA=subsetofstructureofvectors(SUA,SUA.Year==2020);
SUA=subsetofstructureofvectors(SUA,strmatch('World',SUA.Area));
SUAProd=subsetofstructureofvectors(SUA,strmatch('Production',SUA.Element));


c=0;
for j=1:numel(croplist)
    crop=croplist{j};
    %  FAOName=FAO2023Names(crop);
    [cropname,Cropname,FAOCropName]=getFAOCropName2024(crop);


    jdx=strmatch(FAOCropName,CPD.Item,'exact');


    if numel(jdx)==1
        c=c+1;


        kdx=strmatch(crop,cc.CROPNAME,'exact');

        cropnamesave{c}=crop;
        Prod(c)=CPD.Value(jdx);

        FAOCals(c)=cc.kcals_per_ton_fao(kdx);
        TilmanCals(c)=cc.kcals_per_ton_tilman(kdx);
        % can we get calories from FBS?


        idx=strmatch(FAOCropName,SUA.Item,'exact');


        if numel(idx)==0
            cals(c)=Prod(c)*cc.kcals_per_ton_fao(kdx);
            CalVect(c)=cc.kcals_per_ton_fao(kdx);
            datasource{c}='faocals_cropnotinSUA';
        else
            % ok it exists ... is there data to get calories per ton?
            SUAtemp=subsetofstructureofvectors(SUA,idx);
            mdx=strmatch('Calories/Year',SUAtemp.Element);
            ndx=strmatch('Food supply quantity (tonnes)',SUAtemp.Element);
            if numel(mdx)==0 | numel(ndx)==0
                cals(c)=Prod(c)*cc.kcals_per_ton_fao(kdx);
                            datasource{c}='faocals_calinfonotinSUA';
            CalVect(c)=cc.kcals_per_ton_fao(kdx);

            else
               % mdx
               % ndx
                cals(c)=Prod(c)*SUAtemp.Value(mdx)/SUAtemp.Value(ndx)*1e6;
                            datasource{c}='SUA';
            CalVect(c)=SUAtemp.Value(mdx)/SUAtemp.Value(ndx)*1e6;

            end
        end

        try
            % disp(crop)
            % disp(num2str(cc.kcals_per_ton_fao(kdx)))
            % disp(num2str(SUAtemp.Value(mdx)/SUAtemp.Value(ndx)*1e6))
        catch
            'barf'
        end


        if numel(idx)>0
            InFBS(c)=1;
        else
            InFBS(c)=0;
        end
    else
        disp(['Did not find ' cropname ' in FAO data'])

    end
end


[~,ii]=sort(cals,'descend');
[~,jj]=sort(Prod,'descend');

NS.cropnames=cropnamesave(ii);
NS.Prod=Prod(ii);
NS.CalorieDensitySource=datasource(ii);
NS.cals=cals(ii);
NS.CalVect=CalVect(ii);
NS.FAOCals=FAOCals(ii);
NS.TilmanCals=TilmanCals(ii);
for j=1:numel(ii)
CC=getcropcharacteristics(cropnamesave(ii(j)));
NS.group{j}=CC.GROUP{1};
NS.legume{j}=CC.Legume{1};
NS.Ann_Per{j}=CC.Ann_Per{1};
NS.Form{j}=CC.Form{1};
end

sov2csv(NS,'intermediatedatafiles/cropcaloriefilelist.csv')

CropsSortedByCalories2020=cropnamesave(ii);
CropsSortedByProduction2020=cropnamesave(jj);
idx=strmatch('mushroom',CropsSortedByCalories2020);
Top50WorkingCropsSortedByCalories2020=CropsSortedByCalories2020(setdiff(1:51,idx));

save intermediatedatafiles/SortedCropNames2020 CropsSortedByCalories2020 Top50WorkingCropsSortedByCalories2020 CropsSortedByProduction2020

figure
plot(cumsum(NS.cals)/sum(NS.cals),'x-')
grid on
title('Cumulative calories (crops sorted by caloric production), year 2020')
%fattenplot