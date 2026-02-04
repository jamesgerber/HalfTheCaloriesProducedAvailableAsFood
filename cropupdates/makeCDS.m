%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE CDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code takes the raw CDS files - which have all of the data we could
% pull in from the underlying geodatabase and the Monfreda yield/area
% rasters - and determines the best fit set of administrative areas.  Since
% the raw CDS files contain allocation of yield/area to admin levels
% 0,1,2,3 this code has to look at every admin level to assess what makes
% the most sense.  in most cases this is very straightforward, but in some
% cases there are discrepancies, such as area and yield data being at
% different admin levels, or if there is no clear admin level to which the
% data should be cast.
%
% output of this goes to CleanGEOUnits.m
%
% logic flow notes:
% for each crop
%  for each country
%    What is admin level of the data?
%     for each shapefile admin unit within the country at that admin level
%      get empirical yield
%      get empirical area
%      Are there admin units that didn't get incorporated?
%        If yes, create them.
%  add stricter conditions on when to make an additional admin unit (example,
%  australia barley ... first iteration made an admin unit from a smattering of
%  boundary points that weren't even continuous.  now only have those extra points
%  into a synthetic admin unit if they comprise more than 2.5 percent of a country.

%% setup

PCUconstants;   % version strings,  directory locations, etc
cd(workingdirectory)
croplist=CropListForProcessing;  % allows me to set 1 or two crops for development, then put in a bunch

fivemingrid=fma;

% these are the old admin units, but Monfreda data uses these.
[shp0, Raster0, shp1, Raster1, shp2, Raster2, shp3, Raster3, UniqueCountryRaster]=...
    getSHPfiles;

%%

% for each crop
%  for each country
%    What is admin level of the data?
%     for each shapefile admin unit within the country at that admin level
%      get empirical yield
%      get empirical area
%      Are there admin units that didn't get incorporated?
%        If yes, create them.



for jcrop=1:numel(croplist)
    cropname=croplist{jcrop};


    savefilename=['GeodatabaseFiles/MonfredaUpdate/CDSRev' makeCDSOutputRev '_' cropname '.mat'];
    if exist(savefilename)==2
        disp(['already have ' savefilename]);
    else
        disp(['working on ' cropname ' in ' mfilename]);
        load(['GeodatabaseFiles/MonfredaUpdate/CDS_Raw_Rev' CDSRawOutputRev '_' cropname ],'CDSvect','map0','map1','map2','areamap0','areamap1','areamap2','areamap3','map3',...
            'IndicesOfAreaElementsThatHadYield');

        clear Cnewvect

        % this gets monfreda data
        [CropStruct,area,yield]=getdata(cropname);


        %% Prep to compare with FAO Production

        % first confirm that we have the correct coverage within each country


        totalmap=datablank;

        SAGE3List=unique({CDSvect.SAGE3})

        % Remove COD from SAGE3 list - it's Admin 0, will get put in
        % artificially subsequently.  has some issue.
        SAGE3List=setdiff(SAGE3List,{'COD'})

        %%
        Cnewcounter=0;
        for jSAGE3=1:numel(SAGE3List)
            clear DataType
            jSAGE3
            SAGE3=SAGE3List{jSAGE3}
            ii=strmatch(SAGE3,{CDSvect.SAGE3});

            C=CDSvect(ii);


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Calculate coverage maps  %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Admin 0

            ii=find([C.AdminLevel]==0);
            iicountry=[];
            for m=1:numel(ii);
                iicountry=union(C(ii(m)).indices,iicountry);
            end
            DataCoveragemap0=datablank;
            DataCoveragemap0(iicountry)=1;

            % Admin 1

            ii=find([C.AdminLevel]==1);
            iicountry=[];
            for m=1:numel(ii);
                iicountry=union(C(ii(m)).indices,iicountry);
            end
            DataCoveragemap1=datablank;
            DataCoveragemap1(iicountry)=1;


            % Admin 2

            ii=find([C.AdminLevel]==2);
            iicountry=[];
            for m=1:numel(ii);
                iicountry=union(C(ii(m)).indices,iicountry);
            end
            DataCoveragemap2=datablank;
            DataCoveragemap2(iicountry)=1;

            % Admin 3

            ii=find([C.AdminLevel]==3);
            iicountry=[];
            for m=1:numel(ii);
                iicountry=union(C(ii(m)).indices,iicountry);
            end
            DataCoveragemap3=datablank;
            DataCoveragemap3(iicountry)=1;


            % Define country as overlap of all indices
            iicountry=[];
            for m=1:numel(C);
                iicountry=union(C(m).indices,iicountry);
            end
            map=datablank;
            map(iicountry)=1;


            % what is Earthstat Area, Yield?

            f=fma(iicountry);

            jj=isfinite(area(iicountry).*yield(iicountry).*f);

            MonfredaProd=sum(area(iicountry(jj)).*yield(iicountry(jj)).*f(jj));
            MonfredaTotalArea=sum(area(iicountry(jj)).*f(jj));
            MonfredaYield=MonfredaProd./MonfredaTotalArea;

















            % now put together under assumptions of admin0 through admin 3

            map0=datablank;
            map1=datablank;
            map2=datablank;
            map3=datablank;

            idx=strmatch(SAGE3,{shp0.SAGE3});
            for j=1:numel(idx);
                map0=map0 | Raster0==shp0(idx(j)).UniqueIDShape;
            end

            idx=strmatch(SAGE3,{shp1.SAGE3});
            for j=1:numel(idx);
                map1=map1 | Raster1==shp1(idx(j)).UniqueIDShape;
            end

            idx=strmatch(SAGE3,{shp2.SAGE3});
            for j=1:numel(idx);
                map2=map2 | Raster2==shp2(idx(j)).UniqueIDShape;
            end

            idx=strmatch(SAGE3,{shp3.SAGE3});
            for j=1:numel(idx);
                map3=map3 | Raster3==shp3(idx(j)).UniqueIDShape;
            end

            % % %         Value of 1: county level census data
            % % %         Value of 0.75: state level census data
            % % %         Value of 0.5: interpolated with census data from within 2 degrees latitude/longitude
            % % %         Value of 0.25: country level census data
            % % %         Value of 0: missing census data
            % is this country's yield allocated at 0,1,2 or 3?
            DQAflag=CropStruct.Data(:,:,3);
            DQYflag=CropStruct.Data(:,:,4);
            AllocationFlagYield=DQYflag(map0);
            AllocationFlagArea=DQAflag(map0);

            % limit to values within bounds
            AllocationFlagYield=AllocationFlagYield(AllocationFlagYield<9e9);
            AllocationFlagArea=AllocationFlagArea(AllocationFlagArea<9e9);

            AFy= unique(AllocationFlagYield);
            AFa=unique(AllocationFlagArea);


            % figure out yield allocation flag then area allocation flag

            switch numel(AFy)
                case 0
                    DataTypeY=-2;
                case 1
                    DataTypeY=AFy;
                otherwise
                    [N,x]=hist(AllocationFlagYield,AFy);
                    [val,idx]=max(N);
                    DataTypeY=x(idx);

                    N(idx)=0;
                    if max(N)/val > .25
                        DataTypeY=-1;
                    end
            end

            switch numel(AFa)
                case 0
                    DataTypeA=-2;
                case 1
                    DataTypeA=AFa;
                otherwise
                    [N,x]=hist(AllocationFlagArea,AFa);
                    [val,idx]=max(N);
                    DataTypeA=x(idx);

                    N(idx)=0;
                    if max(N)/val > .25
                        DataTypeA=-1;
                    end
            end

            if DataTypeA ~= DataTypeY
                disp(['DataTypeA ~= DataTypeY']);
                % ok ... discrepancy between Area and Yield data quality flags.
                % Almond in USA is a particularly good example of this


                if DataTypeA ==1 | DataTypeY==1
                    DataType=1;
                elseif DataTypeA==0.5 | DataTypeY==0.5
                    DataType=0.5
                elseif DataTypeA==-2
                    DataType=DataTypeY;
                elseif DataTypeY==-2
                    DataType=DataTypeA
                elseif numel(find(DataCoveragemap2))>100
                    % will catch this case below
                else
                    % WTF ... just make it gadm2
                    DataType=1
                end
            else
                DataType=DataTypeA;
            end


            % look for some special cases
            numel(find(DataCoveragemap2))
            if numel(find(DataCoveragemap2))>100
                % see Mexico, almond for a case where this is the right thing
                % to do
                DataType=1;
            elseif numel(find(DataCoveragemap1))>100 & DataType~=1
                DataType=0.75;
            end



            switch DataType
                case {-2}
                    % do nothing
                    ptemp=area.*yield.*fma;
                    if isfinite( nanmax(ptemp(map0)))
                        error
                    end


                case {-1,0.5}
                    % mix of datatypes.  Can we just cast everything onto
                    % states?

                    % First need to check if there is anything at admin1

                    %                if numel(find(map1)) < numel(find(map0))*0.95
                    if numel(find(DataCoveragemap1)) < numel(find(DataCoveragemap0))*0.95
                        disp([' missing some Admin1 ... just take the country '])

                        idx=find([C.AdminLevel]==0);
                        Ctemp=C(idx);


                        if numel(C) ==1

                            Cnew.indices=C.indices;
                            Cnew.AdminLevel=0;
                            Cnew.SAGE35=C.SAGE35;
                            Cnew.SAGE3=C.SAGE3;
                            Cnew.areaCensus=C.areaCensus;
                            Cnew.yieldCensus=C.yieldCensus;
                            Cnew.M3yield=C.ProdWeightedYield;
                            Cnew.M3production=C.ProdRevEng;
                            Cnew.M3area=C.ProdRevEng./C.ProdWeightedYield;



                            Cnew.M3YieldVector=yield(Cnew.indices);
                            Cnew.M3AreaVector=area(Cnew.indices);
                            Cnew.M3DQYVector=DQYflag(Cnew.indices);
                            Cnew.M3DQAVector=DQAflag(Cnew.indices);
                            Cnew.YieldDataTypeFlag=-4;
                            Cnewcounter=Cnewcounter+1;
                            Cnewvect(Cnewcounter)=Cnew;

                        else
                            % presumably an island situation.  If not, the
                            % sums won't work out and we'll get back here
                            % eventually.

                            for m=1:numel(Ctemp)
                                C=Ctemp(m);
                                Cnew.indices=C.indices;
                                Cnew.AdminLevel=0;
                                Cnew.SAGE35=C.SAGE35;
                                Cnew.SAGE3=C.SAGE3;
                                Cnew.areaCensus=C.areaCensus;
                                Cnew.yieldCensus=C.yieldCensus;
                                Cnew.M3yield=C.ProdWeightedYield;
                                Cnew.M3production=C.ProdRevEng;
                                Cnew.M3area=C.ProdRevEng./C.ProdWeightedYield;



                                Cnew.M3YieldVector=yield(Cnew.indices);
                                Cnew.M3AreaVector=area(Cnew.indices);
                                Cnew.M3DQYVector=DQYflag(Cnew.indices);
                                Cnew.M3DQAVector=DQAflag(Cnew.indices);
                                Cnew.YieldDataTypeFlag=-4;
                                Cnewcounter=Cnewcounter+1;
                                Cnewvect(Cnewcounter)=Cnew;

                            end


                        end





                    else
                        minmapdc=DataCoveragemap0&DataCoveragemap1;
                        tmp=(Raster1(minmapdc));
                        SL=unique(tmp);
                        [N,x]=hist(tmp,SL);

                        %% get list of states
                        % this is an easy way to get rid of a few outliers.
                        minmap=(map0 & map1);

                        tmp=(Raster1(minmap));
                        SL=unique(tmp);
                        [N,x]=hist(tmp,SL);

                        %%
                        % now go through states, for each one grab avg yield and
                        % area from monfreda layers.
                        for j=1:numel(SL)
                            thisState=SL(j);
                            clear Cnew
                            Cnew.indices=find(Raster1==thisState);
                            Cnew.AdminLevel=1;
                            Cnew.SAGE35=C(1).SAGE35;
                            Cnew.SAGE3=C(1).SAGE3;
                            Cnew.areaCensus=[];
                            Cnew.yieldCensus=[];


                            ii=Cnew.indices;

                            rawyield=yield(ii);
                            rawarea=area(ii);
                            rawfma=fivemingrid(ii);
                            jj=isfinite(rawyield.*rawarea);

                            pp=sum(rawyield(jj).*rawarea(jj).*rawfma(jj));

                            Cnew.M3yield=pp./sum(rawarea(jj).*rawfma(jj));
                            Cnew.M3area=sum(rawarea(jj).*rawfma(jj));
                            Cnew.M3production=pp;

                            Cnew.M3YieldVector=yield(Cnew.indices);
                            Cnew.M3AreaVector=area(Cnew.indices);
                            Cnew.M3DQYVector=DQYflag(Cnew.indices);
                            Cnew.M3DQAVector=DQAflag(Cnew.indices);
                            Cnew.YieldDataTypeFlag=DataType;
                            Cnewcounter=Cnewcounter+1;
                            Cnewvect(Cnewcounter)=Cnew;
                        end
                    end
                    %%
                case 0.25
                    % ok - country level.  A few cases:
                    % first - there is just a single census datapoint.  That's
                    % easy (First case below) just take that.
                    %
                    % Next ... there's lots of census values, but they are just
                    % the original census value repeated many times (i.e.
                    % monfreda 2008 datalayers have single value)
                    %
                    % otherwise ... put things onto the states.


                    % before get into the if /elseif / else statement below see
                    % if there's a unique yield value and datacoveragemap0
                    % covers the country

                    yieldvaluelist=nanunique(yield(logical(DataCoveragemap0)));
                    yieldvaluelist=yieldvaluelist(isfinite(yieldvaluelist));

                    idx=strmatch(SAGE3,{shp0.SAGE3})
                    urn=shp0(idx).UniqueRasterNo;

                    UniqueCountryRaster==urn;

                    N1=numel(find(UniqueCountryRaster==urn));
                    N2=numel(find(DataCoveragemap0==1));


                    if numel(yieldvaluelist)==1 & abs(N1-N2)/N2 < .0001
                        UniqueValueFlag=1;
                    else
                        UniqueValueFlag=0;
                    end



                    clear Cnew
                    if numel(C)==1
                        % this is an easy case.

                        Cnew.indices=C.indices;
                        Cnew.AdminLevel=0;
                        Cnew.SAGE35=C.SAGE35;
                        Cnew.SAGE3=C.SAGE3;
                        Cnew.areaCensus=C.areaCensus;
                        Cnew.yieldCensus=C.yieldCensus;
                        Cnew.M3yield=C.ProdWeightedYield;
                        Cnew.M3production=C.ProdRevEng;
                        Cnew.M3area=C.ProdRevEng./C.ProdWeightedYield;



                        Cnew.M3YieldVector=yield(Cnew.indices);
                        Cnew.M3AreaVector=area(Cnew.indices);
                        Cnew.M3DQYVector=DQYflag(Cnew.indices);
                        Cnew.M3DQAVector=DQAflag(Cnew.indices);
                        Cnew.YieldDataTypeFlag=DataType;




                        Cnewcounter=Cnewcounter+1;
                        Cnewvect(Cnewcounter)=Cnew;

                    elseif UniqueValueFlag==1
                        idx=find([C.AdminLevel]==0);
                        C=C(idx);

                        Cnew.indices=C.indices;
                        Cnew.AdminLevel=0;
                        Cnew.SAGE35=C.SAGE35;
                        Cnew.SAGE3=C.SAGE3;
                        Cnew.areaCensus=C.areaCensus;
                        Cnew.yieldCensus=C.yieldCensus;
                        Cnew.M3yield=C.ProdWeightedYield;
                        Cnew.M3production=C.ProdRevEng;
                        Cnew.M3area=C.ProdRevEng./C.ProdWeightedYield;



                        Cnew.M3YieldVector=yield(Cnew.indices);
                        Cnew.M3AreaVector=area(Cnew.indices);
                        Cnew.M3DQYVector=DQYflag(Cnew.indices);
                        Cnew.M3DQAVector=DQAflag(Cnew.indices);
                        Cnew.YieldDataTypeFlag=DataType;




                        Cnewcounter=Cnewcounter+1;
                        Cnewvect(Cnewcounter)=Cnew;

                    else

                        %%%%%%
                        % Country level data with multiple records
                        % copying code from DataType==-1 case
                        % see barley in China for an example of why


                        minmap=(map0 & map1);

                        tmp=(Raster1(minmap));
                        SL=unique(tmp);
                        [N,x]=hist(tmp,SL);

                        %%
                        % now go through states, for each one grab avg yield and
                        % area from monfreda layers.
                        for j=1:numel(SL)
                            thisState=SL(j);
                            clear Cnew
                            Cnew.indices=find(Raster1==thisState);
                            Cnew.AdminLevel=1;
                            Cnew.SAGE35=C(1).SAGE35;
                            Cnew.SAGE3=C(1).SAGE3;
                            Cnew.areaCensus=[];
                            Cnew.yieldCensus=[];


                            ii=Cnew.indices;

                            rawyield=yield(ii);
                            rawarea=area(ii);
                            rawfma=fivemingrid(ii);
                            jj=isfinite(rawyield.*rawarea);

                            pp=sum(rawyield(jj).*rawarea(jj).*rawfma(jj));

                            Cnew.M3yield=pp./sum(rawarea(jj).*rawfma(jj));
                            Cnew.M3area=sum(rawarea(jj).*rawfma(jj));
                            Cnew.M3production=pp;

                            Cnew.M3YieldVector=yield(Cnew.indices);
                            Cnew.M3AreaVector=area(Cnew.indices);
                            Cnew.M3DQYVector=DQYflag(Cnew.indices);
                            Cnew.M3DQAVector=DQAflag(Cnew.indices);
                            Cnew.YieldDataTypeFlag=DataType;
                            Cnewcounter=Cnewcounter+1;
                            Cnewvect(Cnewcounter)=Cnew;
                        end


                    end
                case 0.75
                    idx=find([C.AdminLevel]==1);
                    % same code here as above
                    for j=1:numel(idx)
                        clear Cnew


                        C0=C(idx(j));

                        %  Cnew=C0;
                        Cnew.indices=C0.indices;
                        Cnew.AdminLevel=C0.AdminLevel; %
                        Cnew.SAGE35=C0.SAGE35;
                        Cnew.SAGE3=C0.SAGE3;
                        Cnew.areaCensus=C0.areaCensus;
                        Cnew.yieldCensus=C0.yieldCensus;
                        Cnew.M3yield=C0.ProdWeightedYield;
                        Cnew.M3production=C0.ProdRevEng;
                        Cnew.M3area=C0.ProdRevEng./C0.ProdWeightedYield;


                        Cnew.M3YieldVector=yield(Cnew.indices);
                        Cnew.M3AreaVector=area(Cnew.indices);
                        Cnew.M3DQYVector=DQYflag(Cnew.indices);
                        Cnew.M3DQAVector=DQAflag(Cnew.indices);
                        Cnew.YieldDataTypeFlag=DataType;


                        Cnewcounter=Cnewcounter+1;
                        Cnewvect(Cnewcounter)=Cnew;

                    end
                case 1
                    % Admin Level 2

                    idx=find([C.AdminLevel]==2);


                    AdminLevel2map=datablank;

                    for j=1:numel(idx)
                        clear Cnew


                        C0=C(idx(j));

                        %  Cnew=C0;

                        AdminLevel2map(C0.indices)=1;

                        Cnew.indices=C0.indices;
                        Cnew.AdminLevel=C0.AdminLevel; %
                        Cnew.SAGE35=C0.SAGE35;
                        Cnew.SAGE3=C0.SAGE3;
                        Cnew.areaCensus=C0.areaCensus;
                        Cnew.yieldCensus=C0.yieldCensus;
                        Cnew.M3yield=C0.ProdWeightedYield;
                        Cnew.M3production=C0.ProdRevEng;
                        Cnew.M3area=C0.ProdRevEng./C0.ProdWeightedYield;

                        Cnew.M3YieldVector=yield(Cnew.indices);
                        Cnew.M3AreaVector=area(Cnew.indices);
                        Cnew.M3DQYVector=DQYflag(Cnew.indices);
                        Cnew.M3DQAVector=DQAflag(Cnew.indices);
                        Cnew.YieldDataTypeFlag=DataType;


                        Cnewcounter=Cnewcounter+1;
                        Cnewvect(Cnewcounter)=Cnew;

                    end


                    %% Check to see if there is some missing area.
                    % This could be AdminLevel1 (example: Canada Barley)
                    % or This could be AdminLevel2 (example: France Barley)

                    % first look for admin1 in a field of admin2

                    numel(find(DataCoveragemap1 & ~DataCoveragemap2))>50




                    idx=find([C.AdminLevel]==1);


                    if numel(find(DataCoveragemap1 & ~DataCoveragemap2))<50
                        % ok ... don't really care about that - just boundary
                        % slosh

                        % but check to see if there's a gap between 0 and 2
                        % AND these missing points comprise more than 2.5% of
                        % total area.  In that case, make a separate admin unit
                        % so this doesn't get lost.

                        if numel(find(DataCoveragemap0 & ~DataCoveragemap2 ))>50 & ...
                                numel(find(DataCoveragemap0 & ~DataCoveragemap2 ))/numel(find(DataCoveragemap0)) > .025;



                            idx=find([C.AdminLevel]==0);
                            for j=1:numel(idx)
                                clear Cnew
                                C0=C(idx(j));
                                ii=intersect(C0.indices,find(DataCoveragemap0 & ~DataCoveragemap2 ));
                                if numel(ii)>4

                                    Cnew.indices=ii;
                                    Cnew.AdminLevel=C0.AdminLevel; %
                                    Cnew.SAGE35=C0.SAGE35;
                                    Cnew.SAGE3=C0.SAGE3;
                                    Cnew.areaCensus=C0.areaCensus;
                                    Cnew.yieldCensus=C0.yieldCensus;

                                    ppvect=yield(ii).*area(ii).*fivemingrid(ii);
                                    jj=isfinite(ppvect);
                                    pp=sum(ppvect(jj));

                                    Cnew.M3production=pp;


                                    Cnew.M3yield=pp/sum(area(jj).*fivemingrid(jj));
                                    Cnew.M3area=sum(area(jj).*fivemingrid(jj));

                                    Cnew.M3YieldVector=yield(Cnew.indices);
                                    Cnew.M3AreaVector=area(Cnew.indices);
                                    Cnew.M3DQYVector=DQYflag(Cnew.indices);
                                    Cnew.M3DQAVector=DQAflag(Cnew.indices);
                                    Cnew.YieldDataTypeFlag=-4;


                                    Cnewcounter=Cnewcounter+1;
                                    Cnewvect(Cnewcounter)=Cnew;
                                else
                                    % ok to ignore - just boundary slosh
                                end
                            end




                        end

                    else
                        % now need code to take missing areas and make
                        % AdminLevel1maps
                        idx=find([C.AdminLevel]==1);
                        for j=1:numel(idx)
                            clear Cnew
                            C0=C(idx(j));
                            ii=intersect(C0.indices,find(DataCoveragemap1&~DataCoveragemap2));
                            if numel(ii)>4

                                Cnew.indices=ii;
                                Cnew.AdminLevel=C0.AdminLevel; %
                                Cnew.SAGE35=C0.SAGE35;
                                Cnew.SAGE3=C0.SAGE3;
                                Cnew.areaCensus=C0.areaCensus;
                                Cnew.yieldCensus=C0.yieldCensus;

                                ppvect=yield(ii).*area(ii).*fivemingrid(ii);
                                jj=isfinite(ppvect);
                                pp=sum(ppvect(jj));

                                Cnew.M3production=pp;


                                Cnew.M3yield=pp/sum(area(jj).*fivemingrid(jj));
                                Cnew.M3area=sum(area(jj).*fivemingrid(jj));

                                Cnew.M3YieldVector=yield(Cnew.indices);
                                Cnew.M3AreaVector=area(Cnew.indices);
                                Cnew.M3DQYVector=DQYflag(Cnew.indices);
                                Cnew.M3DQAVector=DQAflag(Cnew.indices);
                                Cnew.YieldDataTypeFlag=-3;


                                Cnewcounter=Cnewcounter+1;
                                Cnewvect(Cnewcounter)=Cnew;
                            else
                                % ok to ignore - just boundary slosh
                            end
                        end
                    end





                case 0
                    % do nothing - if no census data it's probably blank
                    % but first check for production
                    ptemp=area.*yield.*fma;
                    if isfinite( nanmax(ptemp(map0)))
                        error
                    end

                otherwise
                    error
            end



            % before we move on, let's make sure we aren't overcounting.

            if Cnewcounter>0
                idx=strmatch(SAGE3,{Cnewvect.SAGE3});
                coveragemap=datablank;
                for m=1:numel(idx)
                    coveragemap(Cnewvect(idx(m)).indices)=coveragemap(Cnewvect(idx(m)).indices)+1;
                end
                if max(coveragemap(:))>1
                    error
                end

            end



        end
        save(savefilename,'Cnewvect');
    end
    % testmaparea=datablank;
    % testmapyield=datablank;
    % for j=1:numel(Cnewvect)
    %     testmapyield(Cnewvect(j).indices)=Cnewvect(j).M3yield;
    % end

end


%%
makedebugplots=0
if makedebugplots==1
    nsg(map0,'caxis',[0 10])
    nsg(map1,'caxis',[0 10])
    nsg(map2,'caxis',[0 10])

    % now combine maps:

    jj=map2>0;
    kk=map2==0 & map1>0;

    newmap=map0;
    newmap(kk)=map1(kk);
    newmap(jj)=map2(jj);

    nsg(newmap,'caxis',[0 10])

    newmap(newmap<=0)=nan;
end
