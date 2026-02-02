
PCUconstants
cd(workingdirectory)

load intermediatedatafiles/SortedCropNames2020 Top50WorkingCropsSortedByCalories2020

outercroplist=Top50WorkingCropsSortedByCalories2020;

metacroplist=outercroplist(1:50);


fid=fopen('intermediatedatafiles/calorieflowdiagnostics.csv','w')


for jcroploop=[0];

    switch jcroploop
        case 0
            cropstr='50 crops'
            outercroplist=metacroplist(1:50);
            yearcaselist=[ 3 2 1];
        case -1
            cropstr='USA validation set, 13 crops'
            outercroplist={'maize', 'wheat', 'soybean', 'rice',...
                'barley', 'oats', 'groundnut', 'sorghum', ...
                'rapeseed','potato','rye','sugarcane','sweetpotato'};
            yearcaselist=10;
        case -2
            cropstr='Brasil validation set, 16 crops'
            outercroplist={'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
                'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
                'sorghum', 'tomato', 'wheat', 'triticale'};
            yearcaselist=10;
        case -3
            cropstr='USA comparison set, 13 crops'
            outercroplist={'maize', 'wheat', 'soybean', 'rice',...
                'barley', 'oats', 'groundnut', 'sorghum', ...
                'rapeseed','potato','rye','sugarcane','sweetpotato'};
            yearcaselist=11;
        case -4
            cropstr='Brasil comparison set, 16 crops'
            outercroplist={'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
                'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
                'sorghum', 'tomato', 'wheat', 'triticale'};
            yearcaselist=11;

        otherwise
            outercroplist=metacroplist(jcroploop);
            cropstr=outercroplist{1};
            yearcaselist=[3 1 2 ]
    end


    makeplots=1;

    for yearcase=[yearcaselist]% 1 2]% 3 2]

        switch yearcase
            % note this case statement exists in multiple codes, edit all of
            % them
            case 1
                YYYYvect=[2010 2011 2012];%2010:2012;
                YYYYstr='c. 2010';
                areafieldname='LinearSuperposedArea2010';
                yieldfieldname='M3Yield2010_CGHybridCorrection';
                AvgMethod=1; % linear trend over 2010:2012, but use 2010 value
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';

            case 2
                YYYYvect=[2014:2016];%2010:2012;
                YYYYstr='c. 2015';
                areafieldname='LinearSuperposedArea2015';
                yieldfieldname='M3Yield2015_CGHybridCorrection';
                AvgMethod=0;
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';

            case 3
                YYYYvect=[2019 2020 2021];%2010:2012;
                YYYYstr='c. 2020';
                areafieldname='CropGridsArea2020';
                yieldfieldname='M3Yield2020_CGHybridCorrection';
                AvgMethod=0;
                matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';
  
            case 7 % helpful for debugging
            YYYYvect=[2020 2020 2020];%2010:2012;
            YYYYstr='2020';
            areafieldname='CropGridsArea2020';
            yieldfieldname='M3Yield2020_CGHybridCorrection';
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';


            case 10 % validation
                YYYYvect=[2020];
                YYYYstr=['2020'];
                areafieldname='validationtestarea2020';
                yieldfieldname='validationtestyield2020';
                matfilesdirectory='intermediatedatafiles/matfilesValidation/';
                AvgMethod=0;

            case 11 % validation
                YYYYvect=[2020];
                YYYYstr=['2020'];
                areafieldname='CropGridsArea2020';
                yieldfieldname='M3Yield2020_CGHybridCorrection';
                matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';
                 AvgMethod=0;

        end

        
        [croplandraster,pastureraster]=get2015croppasturearea;


        fprintf(fid,['cropname,year,SUA primary crop calories,ratio of "fao" calories,ratio of "tilman" calories,'...
            'FAOStat Crop Tons,Ratio of hybrid layer crop tons,ratio of reconstructed from SUA\n']);

        indirectfoodcaloriemapsumacrosscrops=datablank;
        directfoodcaloriemapsumacrosscrops=datablank;
        nonfoodcaloriemapsumacrosscrops=datablank;
        feedcaloriemapsumacrosscrops=datablank;
        seedcaloriemapsumacrosscrops=datablank;
        areamapsumacrosscrops=datablank;

        for jcrop=1:numel(outercroplist);

            cropstring=outercroplist{jcrop};
            disp(cropstring)

            cropname=cropstring;
            ForceRedo=0;

            [ymaptemp,amaptemp]=caloriemapslayergateway(cropname,areafieldname,yieldfieldname,ForceRedo);

            % calories - get from SUA balance sheets
            [CommodityList,IsRoot,CommoditykcalOverGramFactors]=prepforSUAfoodfeed(cropname);
            idx=IsRoot==1;
            CalsPerGramSUA=CommoditykcalOverGramFactors(idx);
            CalsPerTonSUA=CommoditykcalOverGramFactors(idx)*1e6;

            productionperpixel=ymaptemp.*amaptemp.*fma;
            ThisCropCalMap=productionperpixel*CalsPerTonSUA;
            ThisCropCalMap(~isfinite(ThisCropCalMap))=0;

            areaperpixel=amaptemp.*fma;
            fracareaperpixel=amaptemp;
            % lets do some diagnostics / sanity checks.

            % what are the different ways of calculating calories?
            cc=getcropcharacteristics(cropname);
            CalsPerTon_fao=cc.kcals_per_ton_fao;
            CalsPerTon_tilman=cc.kcals_per_ton_tilman;

            % now code to write out the three different measures of calories per gram

            % also ... three different ways of getting total production

            %TonsProduction
            TonsProduction_hybridrasters_2020=sum(nansum(productionperpixel));
            [AY,AA]=GetAverageFAOData('world',cropname,0,2020,2);
            TonsProduction_CPD_2020=AY*AA;

            % (1) from FAO CPD
            % (2) from production rasters
            % (3) from SUA rasters below
            %



            % I need to include loss and seed when doing the normalization below.


            for jyearcount=1:numel(YYYYvect);
                jlayer=jyearcount;
                YYYY=YYYYvect(jyearcount);
                
                fprintf(fid,'%s,%d,%f,%f,%f,',cropname,YYYY,CalsPerTonSUA,CalsPerTon_fao./CalsPerTonSUA,CalsPerTon_tilman./CalsPerTonSUA);

                FigString=[cropstring ' w/ Livestock Conv ' int2str(YYYY) ];

                x=load([matfilesdirectory makesafestring(FigString)],'losscaloriemap','seedcaloriemap',...
                    'producedcalsmap','producedcalsmapnoloss','producedcalsmapnolossnoseed',...
                    'directfoodcaloriemap','areamap','nonfoodcaloriemap','indirectfoodcaloriemap','feedcaloriemap','FigString'...
                    );


                x.indirectfoodcaloriemap(isnan(x.indirectfoodcaloriemap))=0;
                x.directfoodcaloriemap(isnan(x.directfoodcaloriemap))=0;
                x.feedcaloriemap(isnan(x.feedcaloriemap))=0;
                x.nonfoodcaloriemap(isnan(x.nonfoodcaloriemap))=0;
                x.losscaloriemap(isnan(x.losscaloriemap))=0;
                x.seedcaloriemap(isnan(x.seedcaloriemap))=0;
                x.areamap(isnan(x.areamap))=0;

                x.indirectfoodcaloriemap(isinf(x.indirectfoodcaloriemap))=0;
                x.directfoodcaloriemap(isinf(x.directfoodcaloriemap))=0;
                x.feedcaloriemap(isinf(x.feedcaloriemap))=0;
                x.nonfoodcaloriemap(isinf(x.nonfoodcaloriemap))=0;
                x.losscaloriemap(isinf(x.losscaloriemap))=0;
                x.seedcaloriemap(isinf(x.seedcaloriemap))=0;
                x.areamap(isinf(x.areamap))=0;



                % construct this here so code is more readable (since
                % everything is in x structure, and some data conditioning
                % steps will all look the same)
                x.totalcalsmap=x.directfoodcaloriemap+x.feedcaloriemap+x.nonfoodcaloriemap+x.losscaloriemap;

                utilizedcaloriesfromSUA=1e6*(x.directfoodcaloriemap+...
                    x.feedcaloriemap+x.nonfoodcaloriemap);

                % this represents estimate of calories produced (including
                % seed)
                producedcaloriesfromSUA=(x.directfoodcaloriemap+...
                    x.feedcaloriemap+x.nonfoodcaloriemap+x.seedcaloriemap);
                allcaloriesmap=producedcaloriesfromSUA/1e6;

                productioninferredfromSUA=producedcaloriesfromSUA./CalsPerGramSUA/1e6;

                % this is per pixel

                TonsProduction_InferredFromSUA=sum(productioninferredfromSUA(:));

                if isinf(TonsProduction_InferredFromSUA)
                    keyboard
                end

                %% section to test how close production inferred from SUA is to production from crop map.


                fprintf(fid,'%f,%f,%f\n',TonsProduction_CPD_2020,TonsProduction_hybridrasters_2020/TonsProduction_CPD_2020,TonsProduction_InferredFromSUA/TonsProduction_CPD_2020);


                % Now we have passed (or ignored) the tests.  Now create some
                % per-pixel maps where we take the fractions from x, and apply
                % those fractions to the perturbed data (productionperpixel)
                %%  calorie section start
                RemoveSeedFraction=1- ...
                    x.seedcaloriemap ./ ...
                    (x.directfoodcaloriemap+x.feedcaloriemap+x.nonfoodcaloriemap+x.seedcaloriemap+x.losscaloriemap);

                rastercroplayertotalcalories=productionperpixel*CalsPerGramSUA*1e6.*RemoveSeedFraction;

                % reminder of what is going on here.  productionperpixel is actual
                % spatialized production of this crop.  Now we are going to construct
                % various layers by multiplying by fractions.
                %
                % Intrinsic to the method:
                %     the sum of (directfoodcaloriemap+feedcaloriemap+nonfoodcaloriemap) is
                %     "1" in some sense.
                %

                Denominator=(x.directfoodcaloriemap+x.feedcaloriemap+x.nonfoodcaloriemap);

                directfoodcaloriemapconstructed=...
                    rastercroplayertotalcalories.*x.directfoodcaloriemap./Denominator;
                feedcaloriemapconstructed=...
                    rastercroplayertotalcalories.*x.feedcaloriemap./Denominator;
                nonfoodcaloriemapconstructed=...
                    rastercroplayertotalcalories.*x.nonfoodcaloriemap./Denominator;
                seedcaloriemapconstructed=...
                    rastercroplayertotalcalories.*x.seedcaloriemap./Denominator;
                indirectfoodcaloriemapconstructed=...
                    rastercroplayertotalcalories.*x.indirectfoodcaloriemap./Denominator;

                % need to confirm that x.totalcalsmap == allcaloriesmap

                % remove nans ... these were introduced with 0/0 above
                indirectfoodcaloriemapconstructed(isnan(indirectfoodcaloriemapconstructed))=0;
                directfoodcaloriemapconstructed(isnan(directfoodcaloriemapconstructed))=0;
                nonfoodcaloriemapconstructed(isnan(nonfoodcaloriemapconstructed))=0;
                feedcaloriemapconstructed(isnan(feedcaloriemapconstructed))=0;
                seedcaloriemapconstructed(isnan(seedcaloriemapconstructed))=0;

                % make cumulative maps
                indirectfoodcaloriemapsumacrosscrops=indirectfoodcaloriemapsumacrosscrops+indirectfoodcaloriemapconstructed;
                directfoodcaloriemapsumacrosscrops=directfoodcaloriemapsumacrosscrops+directfoodcaloriemapconstructed;
                nonfoodcaloriemapsumacrosscrops=nonfoodcaloriemapsumacrosscrops+nonfoodcaloriemapconstructed;
                feedcaloriemapsumacrosscrops=feedcaloriemapsumacrosscrops+feedcaloriemapconstructed;
                seedcaloriemapsumacrosscrops=seedcaloriemapsumacrosscrops+seedcaloriemapconstructed;
                areamapsumacrosscrops=areamapsumacrosscrops+x.areamap;

                % make three-layer maps.  This will allow me to do some detrending
                if jcrop==1
                    indmatrix(:,:,jlayer)=indirectfoodcaloriemapconstructed;
                    directfoodmatrix(:,:,jlayer)=directfoodcaloriemapconstructed;
                    nonfoodmatrix(:,:,jlayer)=nonfoodcaloriemapconstructed;
                    feedmatrix(:,:,jlayer)=feedcaloriemapconstructed;
                    seedmatrix(:,:,jlayer)=seedcaloriemapconstructed;
                    areamatrix(:,:,jlayer)=x.areamap;
                else
                    indmatrix(:,:,jlayer)=indmatrix(:,:,jlayer)+indirectfoodcaloriemapconstructed;
                    directfoodmatrix(:,:,jlayer)=directfoodmatrix(:,:,jlayer)+directfoodcaloriemapconstructed;
                    nonfoodmatrix(:,:,jlayer)=nonfoodmatrix(:,:,jlayer)+nonfoodcaloriemapconstructed;
                    feedmatrix(:,:,jlayer)=feedmatrix(:,:,jlayer)+feedcaloriemapconstructed;
                    seedmatrix(:,:,jlayer)=seedmatrix(:,:,jlayer)+seedcaloriemapconstructed;
                    areamatrix(:,:,jlayer)=areamatrix(:,:,jlayer)+x.areamap;
                end
                %% calorie section end





                % should make sure that the reconstructed maps add up to
                % x.allcals



                test1=directfoodcaloriemapconstructed-indirectfoodcaloriemapconstructed+...
                    nonfoodcaloriemapconstructed+feedcaloriemapconstructed;

                test2=x.totalcalsmap; % from SUA
                %%  area section start
                rasterarealayer=fracareaperpixel;

                maxdebug=0;
                if maxdebug==1
                    % would need 'nsg' plotting package to make this work
                    clear NSS
                    NSS.filename='maxdebugfigs/';
                    NSS.title=[cropname ' relative difference between reconstructed SUA and Crop Layer calories'];
                    NSS.caxis=[-.5 .5];
                    NSS.DisplayNotes={['Ratio reconstructed cals =' num2str(TonsProduction_hybridrasters_2020/TonsProduction_CPD_2020,3)]};
                    nsg((test1-test2*1e6)./test2/1e6,NSS)
                end

                allcalsperpixel=directfoodcaloriemapsumacrosscrops+feedcaloriemapsumacrosscrops+nonfoodcaloriemapsumacrosscrops;
                allcalsperha=allcalsperpixel./fma;

                alldiets=allcalsperha/2700/365;
                if maxdebug==1
                    % would need 'nsg' plotting package to make this work
                    clear NSS
                    NSS.filename='debugfigs/';
                    NSS.title=[int2str(jcrop) 'crops  (latest=' cropname ')'];
                    NSS.cmap='yield';
                    NSS.caxis=[0 10]
                    nsg(alldiets,NSS);
                end
                productioninferredfromallcals=allcalsperpixel/CalsPerGramSUA;

                productionfromhybriddatalayers=productionperpixel;

                TonsProduction_afterSUAcalcs=sum(productioninferredfromallcals(:));

            end
        end


        if AvgMethod==0
            indirectfoodcaloriemapavg=indirectfoodcaloriemapsumacrosscrops/numel(YYYYvect);
            directfoodcaloriemapavg=directfoodcaloriemapsumacrosscrops/numel(YYYYvect);
            feedcaloriemapavg=feedcaloriemapsumacrosscrops/numel(YYYYvect);
            seedcaloriemapavg=seedcaloriemapsumacrosscrops/numel(YYYYvect);
            nonfoodcaloriemapavg=nonfoodcaloriemapsumacrosscrops/numel(YYYYvect);
            areamapavg=areamapsumacrosscrops/numel(YYYYvect);
        else
            N=AvgMethod;
            indirectfoodcaloriemapavg=detrendaverage(indmatrix,N);
            directfoodcaloriemapavg=detrendaverage(directfoodmatrix,N);
            nonfoodcaloriemapavg=detrendaverage(nonfoodmatrix,N);
            feedcaloriemapavg=detrendaverage(feedmatrix,N);
            seedcaloriemapavg=detrendaverage(seedmatrix,N);
            areamapavg=detrendaverage(areamatrix,N);
        end


        %%
         caloriesavailablemap=directfoodcaloriemapavg+nonfoodcaloriemapavg+feedcaloriemapavg;
        % areasavailablemap=directfoodareamapavg+nonfoodareamapavg+feedareamapavg;
        % %allcaloriemap=foodcaloriemapavg+nonfoodcaloriemapavg+feedcaloriemapavg;
          totalfoodfractionmap=(directfoodcaloriemapavg+indirectfoodcaloriemapavg)./caloriesavailablemap;

         directfoodvsnotfood=(directfoodcaloriemapavg)./(feedcaloriemapavg+nonfoodcaloriemapavg);
         % 
         caloriesgrownperha=caloriesavailablemap./fma;
         totalfoodcaloriesperha=(directfoodcaloriemapavg+indirectfoodcaloriemapavg)./fma;
        % 

        % save(['calorierasters/caloriesrastersyearflag' int2str(yearcase)],'caloriesavailablemap','directfoodcaloriemap','nonfoodcaloriemapavg','feedcaloriemapavg','CalsPerTonSUA');
        % save(['arearasters/arearastersyearflag' int2str(yearcase)],'areasavailablemap','directfoodcaloriemap','nonfoodareamapavg','feedareamapavg');

        %% code to make table


        clear DS
        for j=0:263
            if j==0
                ii=landmasklogical;
                ISO='World';
                Name='World';
            else
                [g0,ii,countryname]=getgeo41_g0(j);
                ISO= g0.gadm0codes{1};
                Name=g0.namelist0{1};
            end

            [FAOyield2020,FAOarea2020]=GetAverageFAOData(ISO,cropname,0,2020,2);
            FAOCalories=FAOyield2020*FAOarea2020*CalsPerGramSUA*1e6;

            DS(j+1).ISO=ISO;
            DS(j+1).Name=strrep(Name,',','');
            DS(j+1).TotalCalories=sum(caloriesavailablemap(ii));
            DS(j+1).FAOCalories=FAOCalories;
            DS(j+1).FractionDirectFood=sum(directfoodcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).FractionNonFood=sum(nonfoodcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).FractionFeed=sum(feedcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).FractionFood=sum(directfoodcaloriemapavg(ii)+indirectfoodcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).IndirectFood=sum(indirectfoodcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).Seed=sum(seedcaloriemapavg(ii))/sum(caloriesavailablemap(ii));
            DS(j+1).CalsPerGramSUA=CalsPerGramSUA;
            DS(j+1).Area=nansum(areamapavg(ii).*fma(ii));
        end

 %       warndlg('turrned of calorieutilization.csv, since code broken.')
        sov2csv(vos2sov(DS),['CalorieUtilization/CalorieUtilization_' makesafestring(YYYYstr) cropstr '.csv']);


        if jcroploop<=0
            
save(['intermediatedatafiles/calorielayers' makesafestring([YYYYstr cropstr])],'caloriesavailablemap','directfoodcaloriemapavg', ...
    'indirectfoodcaloriemapavg','feedcaloriemapavg','nonfoodcaloriemapavg','areamapavg')

        end


        % make table
        %no maps if release=2025
        verdata=ver;
        if isequal(verdata(1).Release,'(R2025a)')
           disp(['no plots ... 2025a'])
            makeplots=0;
        end
        if makeplots==1 %& jcroploop<=0;
            % Total Calorie production
            clear NSS
            NSS.title=['Total calorie production. ' cropstr ' ' YYYYstr];
            NSS.filename='output/figures/';
            NSS.caxis=[0 8];
            NSS.froufrou=[0 1];
            NSS.units='million calories per hectare';
            NSS.cmap='dark_blues_deep';
            NSS.logicalinclude=caloriesgrownperha>0;
            NSS.logicalinclude=areafilter(areamapsumacrosscrops,areamapsumacrosscrops,.99);
            NSS.MakePlotDataFile='on';
            nsg(caloriesgrownperha/1e6,NSS);
            %
            % Fraction of food available
            clear NSS
            NSS.title=['Percentage of production available as food. ' cropstr ' ' YYYYstr];
            NSS.filename='output/figures/';
            NSS.caxis=[0 100];
            NSS.cmap='purple_white_green_deep';
            NSS.MakePlotDataFile='on';
            NSS.units='%';
            NSS.logicalinclude=areafilter(areamapsumacrosscrops,areamapsumacrosscrops,.99);
            nsg(100*totalfoodfractionmap,NSS);

            %% people fed on calories produced

            clear NSS
            NSS.caxis=[0 10];
            NSS.cmap='yield';
            NSS.title=['People fed on total calories production ' cropstr ' ' YYYYstr];
            NSS.units='number of people fed per ha'
            NSS.filename='output/figures/';
            NSS.MakePlotDataFile='on';

            NSS.logicalinclude=caloriesgrownperha>0;
            NSS.logicalinclude=areafilter(areamapsumacrosscrops,areamapsumacrosscrops,.99);
            nsg(caloriesgrownperha/2700/365,NSS);



            clear NSS
            NSS.caxis=[0 10];
            NSS.cmap='yield';
            NSS.title=['People fed on calorie production available as food ' cropstr ' ' YYYYstr];
            NSS.units='number of people fed per ha'
            NSS.filename='output/figures/';
            NSS.MakePlotDataFile='on';

            NSS.logicalinclude=caloriesgrownperha>0;
            NSS.logicalinclude=areafilter(areamapsumacrosscrops,areamapsumacrosscrops,.99);
            nsg(totalfoodcaloriesperha/2700/365,NSS);

           % % direct food vs not food
           % clear NSS
           % NSS.caxis=[0 2];
           % NSS.cmap='red_white_blue_deep';
           % NSS.title=['Ratio of direct food to feed and non-food' int2str(numel(outercroplist)) ' crops. ' YYYYstr];
           % NSS.logicalinclude=caloriesgrownperha>0;
           % NSS.logicalinclude=areafilter(areamapsumacrosscrops,areamapsumacrosscrops,.99);
           % 
           % NSS.filename='finalfigs/'
           % nsg(directfoodvsnotfood,NSS)

        end % makeplots
    end
end

% save(['calorierasters/caloriesrastersyearflag' int2str(yearcase)],...
%     'caloriesavailablemap','directfoodcaloriemap','foodcaloriemapavg','nonfoodcaloriemapavg',...
%     'feedcaloriemapavg','CalsPerTonSUA');
% save(['arearasters/arearastersyearflag' int2str(yearcase)],'areasavailablemap','indirectfoodareamapavg','directfoodareamap','nonfoodareamapavg','feedareamapavg');

fclose(fid)
