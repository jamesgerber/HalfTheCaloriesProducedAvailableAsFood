% makemapoffoodvsfeedSUA_trackcalories
%
% this code:
%     * reads in layers of crop production
%     * for each year, crop, country
%        * assesses where that production goes in terms of
%            - direct food
%            - indirect food
%            - feed
%            - non-food (i.e. biofuels)
%     * creates layers of calories allocated.
%
%    The allocation results in these layers being saved:
% availablecalsmap - this is 'produced - seed'
% losscaloriemap - this is 'loss'
% directfoodcaloriemap - this is '(produced - seed)*directfoodfraction
% nonfoodcaloriemap - (produced - seed)*nonfoodfraction
% feedcaloriemap - (produced - seed)*feedfraction
% indirectfoodcaloriemap -
% FigString (useful text for confirming crop, years associated with layers)
% areamap

% lossareamap
% indirectfoodareamap
% feedareamap
% foodareamap
% seedareamap
% directfoodareamap
% nonfoodareamap
%
%  This code initially written so that it can sum and allocate calories
%  from all crops at once.  I don't know that this functionality still
%  works, since I now sum those later.
%
%  saved filename something like this:
%    'matfilesCGRevC/maize_w_Livestock_Conv_2019.mat'
%
%  Note that Vdom below is called Udom in the publication9

PCUconstants
cd(workingdirectory)


load intermediatedatafiles/SortedCropNames2020 Top50WorkingCropsSortedByCalories2020
outercroplist=Top50WorkingCropsSortedByCalories2020

yearcaselist=[2]

runvalidationset=0;
if runvalidationset==1
    NASSCropList= {'maize', 'wheat', 'soybean', 'rice',...
        'barley', 'oats', 'cotton', 'groundnut', 'sorghum', ...
        'rapeseed','potato','rye','sugarcane','sweetpotato'};

    IBGECropList  = {'cotton', 'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
        'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
        'sorghum', 'tomato', 'wheat', 'triticale'};

    MoreDataCrop=union(NASSCropList,IBGECropList);

    ii=ismember(outercroplist,MoreDataCrop);
    validatecroplist=outercroplist(ii);
    outercroplist=validatecroplist;

    yearcaselist=10;

end


IGNORETRADE=2;  % this is now hardwired - earlier versions had this for sensitivity
FEEDFOODCONVERSION=1; % this is now hardwired - earlier versions had this for sensitivity


clear CSS
CSScount=0;

fid=fopen('diagnostics.csv','w');
fprintf(fid,'cropname,ISO,Country,Root crop processed,sum of derived calories, ratio\n');

for yearcase=[yearcaselist]% 1 2]
    % note this case statement exists in multiple codes, edit all of
    % them
    switch yearcase
        case 1
            YYYYvect=[2010:2012 ];%2010:2012;
            YYYYstr='c. 2010'
            areafieldname='LinearSuperposedArea2010';
            yieldfieldname='M3Yield2010_CGHybridCorrection';
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';



        case 2
            YYYYvect=[2014:2016];%2010:2012;
            YYYYstr='c. 2015';
            areafieldname='LinearSuperposedArea2015';
            yieldfieldname='M3Yield2015_CGHybridCorrection';
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';

        case 3
            YYYYvect=[2019 2020 2021];%2010:2012;
            YYYYstr='c. 2020';
            areafieldname='CropGridsArea2020';
            yieldfieldname='M3Yield2020_CGHybridCorrection';
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';

        case 7 % helpful for debugging
            YYYYvect=[2020 2020 2020];%2010:2012;
            YYYYstr='2020';
            areafieldname='CropGridsArea2020';
            yieldfieldname='M3Yield2020_CGHybridCorrection';
            matfilesdirectory='intermediatedatafiles/matfilesCropGridHybrid/';

        case 10 % validation
            YYYYvect=[2020];
            YYYYstr=[2020];
            areafieldname='validationtestarea2020';
            yieldfieldname='validationtestyield2020';
            matfilesdirectory='intermediatedatafiles/matfilesValidation/';



    end


    for YYYY=YYYYvect%  2020:2022]% 2010 2020];

        for jouter= [1:numel(outercroplist)]; % if 0 then all crops at once

            if jouter==0
                croplist=outercroplist;
                cropstring=[int2str(numel(croplist)) 'crops'];
            else
                croplist=outercroplist(jouter);
                cropstring=char(croplist);
            end

            areamap=datablank;
            availablecalsmap=datablank;
            directfoodcaloriemap=datablank;
            indirectfoodcaloriemap=datablank;
            feedcaloriemap=datablank;
            losscaloriemap=datablank;
            nonfoodcaloriemap=datablank;
            seedcaloriemap=datablank;

            % availablecalsmap - this corresponds to produced - seed
            % directfoodcaloriemap
            % indirectfoodcaloriemap
            % feedcaloriemap=datablank;
            % nonfoodcaloriemap
            % losscaloriemap
            % areamap - fractional area within gridcell.

            % directfoodareamap=datablank;
            % indirectfoodareamap=datablank;
            % feedareamap=datablank;
            % seedareamap=datablank;
            % lossareamap=datablank;
            % nonfoodareamap=datablank;
            % totalfoodareamap=datablank;
            %   foodareamap=datablank;

            for jcrop=1:numel(croplist)
                clear WeightAcrossDS
                clear NSS cmap DS CC CommodityList M Unorm Umat UF Uexp Udom Vexp Vdom Vtot
                cropname=croplist{jcrop}
                [cropname,Cropname,FBSCommodityName]=getFAOCropName(cropname);

                TradeCropName='this is a placeholder - not doing trade';

                % get factors relating commodity name to calorie density
                [CommodityList,IsRoot,CommoditykcalOverGramFactors]=prepforSUAfoodfeed(cropname);
                idx=IsRoot==1;
                RootkcalOverGram=CommoditykcalOverGramFactors(idx);


% load a Cnew to get a list of countries to limit to (this will be too many
% countries for the validation case, but don't really care, since USA and
% BRA are most of the admin units)

                switch FEEDFOODCONVERSION
                    case 0
                        error('this should not be called any longer')
                        FigString=[cropstring ' no Livestock Conv ' int2str(YYYY)];
                    case 1
                        FigString=[cropstring ' w/ Livestock Conv ' int2str(YYYY) ];
                end

                savefilename=[matfilesdirectory makesafestring(FigString) '.mat'];

clear CalorieExportData


                if exist(savefilename)==2 & ForceRedo==0;
                    disp(['already have ' savefilename])
                else


                    [croplandraster,pastureraster]=get2015croppasturearea;

                    % good place to redefine ISOlist for debugging

                        shallowrasterlayerfilename=['shallowrasterlayers/' cropname '_' areafieldname '_' yieldfieldname '.mat'];

                        load(shallowrasterlayerfilename,'ymaptemp','amaptemp');
                        ymaptemp(isnan(ymaptemp))=0;
                        amaptemp(isnan(amaptemp))=0;
                        ymaptemp(isinf(ymaptemp))=0;
                        amaptemp(isinf(amaptemp))=0;

                        ymaptempstash=ymaptemp;
                        amaptempstash=amaptemp;


                    if runvalidationset==1
                        ISOlist={'BRA','USA'}
                    else
                        load([GeoDatabaseDirectory '/MonfredaCGHybrid/CDSRev' CreateHybridGDBRev '_FAOaligned' cropname '_withGADM0field_2000_pm2.mat'],'Cnew');
                        ISOlist=unique({Cnew.GADM3});
                        ISOlist=RemoveNonstandardISOs(ISOlist);

                    end


                    for jISO=1:numel(ISOlist);

                        ISO=ISOlist{jISO};
                        Country=ISOtoFAOName(ISO);
                        disp(Country);

                        clear DS
                        for m=1:numel(CommodityList)
                            [UF,Mflat,M,W,Mfields,Ufields,RFVNdom,RFVNworld]=GetUtilizationFractionsLivestockSUA(Country,CommodityList{m},TradeCropName,YYYY,IGNORETRADE,ISO);
                            DS(m).UF=UF;
                            DS(m).M=M;
                            DS(m).Mflat=Mflat; % averaged for trade.
                            DS(m).W=W;
                            DS(m).Commodity=CommodityList{m};
                            DS(m).IsRoot=IsRoot(m);
                            DS(m).kcalsOverGram=CommoditykcalOverGramFactors(m);
                        end


CalorieExportData.ISOlist{jISO}=ISO;
CalorieExportData.RFVNdomlist{jISO}=RFVNdom;
CalorieExportData.RFVNworldlist{jISO}=RFVNworld;



                        %%

                        % Calculation of Vdom.  earlier versions of this code
                        % calculated Udom, where Udom is normalized to 1.  By
                        % contrast V will have the property that summing will give
                        % total calories.
                        %
                        %  Fields of U were 'food' 'feed' 'non-food'
                        %
                        %  Fields of V are
                        % 'food - direct'
                        % 'food - indirect'
                        % 'feed'
                        % 'non-food'
                        % 'loss'
                        % 'seed'

                        clear Vmat ExportQuantityVector ImportQuantityVectorkcals DomesticSupplyVectorkcals
                        N=numel(CommodityList);
                        for j=1:N;
                            M=DS(j).M;
                            Vmat(1,j)=M(6,1)+M(8,1); % food ('food' + 'tourist consump')
                            Vmat(2,j)=M(11,1); % food (indirect)
                            Vmat(3,j)=M(2,1); % feed
                            Vmat(4,j)=M(4,1); % non-food
                            Vmat(5,j)=M(13,1); % loss
                            Vmat(6,j)=M(3,1); % seed
                            % now multiply by calorie factor
                            Vmat(:,j)=Vmat(:,j)*DS(j).kcalsOverGram;
                            ExportQuantityVector(j)=M(9,1); % 'Export Quantity'
                            ExportQuantityVectorkcals(j)=M(9,1)*DS(j).kcalsOverGram;; % 'Export Quantity'
                            ImportQuantityVectorkcals(j)=M(10,1)*DS(j).kcalsOverGram;; % 'Import Quantity'
                            DomesticSupplyVectorkcals(j)=M(1,1)*DS(j).kcalsOverGram;
                        end

                        % will need these later
                        exportcalories=sum(ExportQuantityVectorkcals);
                        importcalories=sum(ImportQuantityVectorkcals);
                        domesticcalories=sum(DomesticSupplyVectorkcals);


                        Vdom=Vmat;

                        Vdomcolnorm=sum(Vdom,2);
                        Vdomcolnorm=Vdomcolnorm/sum(Vdomcolnorm([1 3 4]));

                        % now calculation of Vexp
                        %
                        % Here is how these are combined.   We calculated total
                        % exported calories above in ExportQuantityVectorkcals.
                        % Vexp will have total calories ... we'll normalize Vexp so
                        % that total calories equals the sum of
                        % ExportQuantityVectorkcals.
                        %
                        % At the same time, we have to ignore the imported calorie
                        % fraction of Vdom (otherwise we would be double counting
                        % them).  We do this by multiplying by a factor eta, where
                        % eta = (Domestic Supply )/(Domestic Supply+Imports)
                        %
                        % note that eta is the same for every commodity derived from a given crop.
                        % This is because commodities can be transformed into different commodities
                        % and re-exported - choosing simplicity over some possibly misleading
                        % attempt at sophistication
                        %
                        %  In other words the equation for eta could be written like  this:
                        % eta = sum(Domestic Supply all calories for crop C )/sum(Domestic Supply+Imports all calories crop C)

                        eta=(nansum(DomesticSupplyVectorkcals))/...
                            (nansum(DomesticSupplyVectorkcals)+nansum(ImportQuantityVectorkcals));

                        if eta<0
                            eta=0;
                        end

                        if ~isfinite(eta)
                            eta=0;
                        end

                        clear Vmat M
                        N=numel(CommodityList);
                        for j=1:N;
                            [UF,Mflat,M,W,Mfields,Ufields,~,~]=GetUtilizationFractionsLivestockSUA('World',CommodityList{m},TradeCropName,YYYY,IGNORETRADE,'World');

                            M=DS(j).M;
                            Vmat(1,j)=M(6,2)+M(8,2); % food ('food' + 'tourist consump')
                            Vmat(2,j)=M(11,2); % food (indirect)
                            Vmat(3,j)=M(2,2); % feed
                            Vmat(4,j)=M(4,2); % non-food
                            Vmat(5,j)=M(13,2); % loss
                            Vmat(6,j)=M(3,2); % seed
                            % now multiply by calorie factor
                            Vmat(:,j)=Vmat(:,j)*DS(j).kcalsOverGram;
                        end
                        Vexp=Vmat;



                        % now combine Vexp and Vdom

                        % first get rid of nan

                        Vexp(~isfinite(Vexp))=0;
                        Vdom(~isfinite(Vdom))=0;


                        totalexportedcalories=sum(ExportQuantityVectorkcals);

                        %%  Vexpnorm=Vexp*totalexportedcalories/sum(Vexp(:));
                        Vexpcolnorm=sum(Vexp,2);
                        Vexpcolnorm=Vexpcolnorm/sum(Vexpcolnorm([1 3 4]));


                        if ~isfinite(Vexpcolnorm)
                            keyboard
                        end

                        a=(domesticcalories-exportcalories+importcalories);
                        b=exportcalories;
                        Vtotnormcol=(a*Vdomcolnorm+b*Vexpcolnorm )/(a+b);

                        Weight_Dom_Exported=[a b];

                      %  warndlg('ignoring exports');
                      %  Vtotnormcol=Vdomcolnorm;

CalorieExportData.Weight_Dom_Exported{jISO}=[a b];
CalorieExportData.a(jISO)=a;
CalorieExportData.b(jISO)=b;



                        % now calculate the fractions. Note that Vcol is
                        % the utilization amounts after correcting for
                        % trade.
                        directfoodfraction=Vtotnormcol(1);
                        feedfraction=Vtotnormcol(3);
                        nonfoodfraction=Vtotnormcol(4);


                        % subset of GDB
              %          ii=strmatch(ISO,{Cnew.GADM3});
              %          CC=Cnew(ii);
                        %    s onto map
                        tic

        
                        ymaptemp=ymaptempstash;
                        amaptemp=amaptempstash;

                        [g0,ii]=getgeo41_g0(ISO);

                        aa=datablank;
                        yy=datablank;
                        yy(ii)=ymaptemp(ii);
                        aa(ii)=amaptemp(ii);
                        ymaptemp=yy;
                        amaptemp=aa;
                        ymaptemp(isnan(ymaptemp))=0;
                        amaptemp(isnan(amaptemp))=0;


                        %  end



                        jj=ymaptemp>0 | amaptemp>0;

                        % now add the calories to the calorie map.   We have
                        % calculated the total amount of calories we need to add
                        % (foodcals, feedcals, nonfoodcals) - we need to normalize
                        % so these are spread out according to where the production
                        % of the crop is.
                        % % Vmat(1,j)=M(6,2)+M(8,2); % food ('food' + 'tourist consump')
                        % %       Vmat(2,j)=M(11,2); % food (indirect)
                        % %       Vmat(3,j)=M(2,2); % feed
                        % %       Vmat(4,j)=M(4,2); % non-food
                        % %       Vmat(5,j)=M(13,2); % loss
                        % %       Vmat(6,j)=M(3,2); % seed
                        % %

                        directfoodfrac=Vtotnormcol(1);
                        indirectfoodfrac=Vtotnormcol(2);
                        feedfrac=Vtotnormcol(3);
                        nonfoodfrac=Vtotnormcol(4);
                        lossfrac=Vtotnormcol(5);
                        seedfrac=Vtotnormcol(6);



                        productionsum=sum(ymaptemp(jj).*amaptemp(jj).*fma(jj));

                        availablecals=productionsum*(1-seedfrac)*RootkcalOverGram*1e6;



                        losscaloriemap(jj)=losscaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*lossfrac*availablecals/productionsum;
                        seedcaloriemap(jj)=seedcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*seedfrac*availablecals/productionsum;
                        indirectfoodcaloriemap(jj)=indirectfoodcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*indirectfoodfrac*availablecals/productionsum;
                        directfoodcaloriemap(jj)=directfoodcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*directfoodfrac*availablecals/productionsum;
                        %foodcaloriemap(jj)=foodcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*foodcals/productionsum;
                        feedcaloriemap(jj)=feedcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*feedfrac*availablecals/productionsum;
                        nonfoodcaloriemap(jj)=nonfoodcaloriemap(jj)+ymaptemp(jj).*amaptemp(jj).*fma(jj).*nonfoodfrac*availablecals/productionsum;

                        % total area map
                        areamap(jj)=areamap(jj)+amaptemp(jj);
                        %


                    end

                    producedcalsmap=directfoodcaloriemap+feedcaloriemap+nonfoodcaloriemap+losscaloriemap+seedcaloriemap;
                    producedcalsmapnoloss=directfoodcaloriemap+feedcaloriemap+nonfoodcaloriemap+seedcaloriemap;
                    producedcalsmapnolossnoseed=directfoodcaloriemap+feedcaloriemap+nonfoodcaloriemap;

                    %               directfoodcaloriemap=foodcaloriemap-indfoodcaloriemap;

                    save(savefilename,'producedcalsmap','producedcalsmapnoloss','producedcalsmapnolossnoseed','losscaloriemap','directfoodcaloriemap',...
                        'areamap','nonfoodcaloriemap','feedcaloriemap','indirectfoodcaloriemap','seedcaloriemap','FigString',...
                        'CalorieExportData');
                    %                 save(['CSSVectors/CSSVector' makesafestring(FigString)],'CSS');

                    nansum(seedcaloriemap(:))+...
                        nansum(losscaloriemap(:))+...
                        nansum(directfoodcaloriemap(:))+...
                        nansum(nonfoodcaloriemap(:))+...
                        nansum(feedcaloriemap(:))
                end
            end
        end
    end
end

