[nassCropNames,faoCropNames]=NASSCropNameList;

% RevC - using a perturbation method within states.

[g0,g1,g2,g3,g]=getgeo41;

% statenames
ii=strmatch('USA',g1.gadm0codes);
g1USA=subsetofstructureofvectors(g1,ii);
statenames=g1.namelist1(ii);
ii=strmatch('USA',g2.gadm0codes);
g2USA=subsetofstructureofvectors(g2,ii);


for jcropno=1:numel(nassCropNames);
    spare g1USA g2USA jcropno faoCropNames nassCropNames g0 g1 g2 g3
    cropname=lower(faoCropNames{jcropno})
    disp(['loading raw CDSfiles'])
       load(['CDSfiles/CDSrawNASS' cropname '.mat'],'CDSvect');
      Xstate=load(['CDSfiles/CDSrawNASS' cropname '_state.mat'],'CDSvect');
    CDSvectState=Xstate.CDSvect
    clear Cnewvect Cnewnewvect

    %% list of states
    statelist1={};
    for j=1:numel(CDSvectState);
        statelist1{j}=char(CDSvectState(j).sharedlabels.state_name);
    end

    statelist2={};
    for j=1:numel(CDSvect);
        statelist2{j}=char(CDSvect(j).sharedlabels.state_name);
        CDSvect(j).state_name=char(CDSvect(j).sharedlabels.state_name);
        CDSvect(j).county_name=char(CDSvect(j).sharedlabels.county_name);
    end

    statelist=union(statelist1,statelist2);

    %%


    Cnewvect='';
    for jstate=1:numel(statelist)

        STATE=statelist{jstate};
        idx=strmatch(STATE,{CDSvectState.state_name});
        CState=CDSvectState(idx);

        kdx=find(CState.NASSdataRaw.year==2000);
        metastatearea(jstate)=sum(CState.NASSdataRaw.area(kdx));


        jdx=strmatch(STATE,{CDSvect.state_name});
        CC=CDSvect(jdx);



        %%%%%%%%
        %  reconcile state and county level data
        %     if there is a state and no county data (e.g. connecticut, maize) it's
        %     easy, although need to denote appropriately
        %
        %     if state and county don't agree,
        %%%%%%%%

        if isempty(jdx)
            % only state data

            % add GADM tags
            CState.NASSdataStateNormed=CState.NASSdataRaw;
            CState.gadmLevel=1;
            CState.county_name='';
            CState.NASSHybridData=CState.NASSdataRaw;
            CState.NASSPerturbeddata=[];

            if isempty(Cnewvect)
                Cnewvect=CState;
            else
                Cnewvect(end+1)=CState;
            end


        elseif isempty(idx)
            disp(' really strange - have county but not state')
            keyboard
        else
            if ~isequal(CState.NASSdataRaw.year,CC(1).NASSdataRaw.year)
                disp([' different years for state and county level data. ' STATE])
                disp([int2str(CState.NASSdataRaw.year(1)) ' ...' int2str(CState.NASSdataRaw.year(end))])
                disp([int2str(CC(1).NASSdataRaw.year(1)) ' ...' int2str(CC(1).NASSdataRaw.year(end))])
                %%%%%%
                % Categorize state as follows:
                %   should only use state data (either because there is no county data, or
                %   county data only exists before year 2000


                % years where there are both state and county data
                yrvect=intersect(CState.NASSdataRaw.year,CC(1).NASSdataRaw.year);

                if max(yrvect) < 2000;
                    % just use state data for everything
                    ONLYSTATE=1;
                else
                    ONLYSTATE=0;
                end



                % years where we will perturb state to county
                %        perturbyears=setdi


            end



            for jyr=1:numel(yrvect);
                YYYY=yrvect(jyr);
                clear avect yvect
                % state yield and area data
                idx=find(CState.NASSdataRaw.year==YYYY);
                astate=CState.NASSdataRaw.area(idx);
                ystate=CState.NASSdataRaw.yield(idx);



                for m=1:numel(CC)
                    jdx=find(CC(m).NASSdataRaw.year==YYYY);

                    if numel(jdx)==1
                        avect(m)=CC(m).NASSdataRaw.area(jdx);
                        yvect(m)=CC(m).NASSdataRaw.yield(jdx);
                    elseif numel(jdx)>1
                        keyboard
                    else
                        avect(m)=0;
                        yvect(m)=0;
                    end
                end

                % now remove the "other" categories, then reconcile sum of
                % non-other counties to state
                %

                iother=strmatch('OTHER',{CC.county_name});

                anoOther=avect;
                anoOther(iother)=0;

                CorrectToStateAreaFactor=astate/sum(anoOther);

                if isempty(CorrectToStateAreaFactor)
                    CorrectToStateAreaFactor=1;
                end

                for m=1:numel(CC);
                    CC(m).NASSdataStateNormed.area(jyr)=anoOther(m)*CorrectToStateAreaFactor;
                    CC(m).NASSdataStateNormed.yield(jyr)=yvect(m);
                    CC(m).NASSdataStateNormed.year(jyr)=YYYY;

                end
            end
            for m=1:numel(CC)
                CC(m).gadmLevel=2;
            end

            % now add PerturbedWithinNASS data
            CC=PerturbWithinState(CC,CState);



            % now hybridize NASSdataStateNormed and NASSPerturbeddata

            ySN=CC(1).NASSdataStateNormed.year;
            yP=CC(1).NASSPerturbeddata.year;

            allyears=union(ySN,yP);
            if ~isempty(intersect(ySN,yP))
                keyboard
            end

            for jyr=1:numel(allyears);
                YYYY=allyears(jyr);
                for m=1:numel(CC);
                    % note - don't index in ySN or yP because what if one of the
                    % county-level datapoints is missing a year?
                    idx=find(CC(m).NASSdataStateNormed.year==YYYY);
                    jdx=find(CC(m).NASSPerturbeddata.year==YYYY);

                    if numel(jdx)==1
                        CC(m).NASSHybridData.year(jyr)=YYYY;
                        CC(m).NASSHybridData.area(jyr)=CC(m).NASSPerturbeddata.area(jdx);
                        CC(m).NASSHybridData.yield(jyr)=CC(m).NASSPerturbeddata.yield(jdx);
                    elseif numel(idx)==1
                        CC(m).NASSHybridData.year(jyr)=YYYY;
                        CC(m).NASSHybridData.area(jyr)=CC(m).NASSdataStateNormed.area(idx);
                        CC(m).NASSHybridData.yield(jyr)=CC(m).NASSdataStateNormed.yield(idx);
                    else
                        keyboard
                    end

                end
            end



            if isempty(Cnewvect)
                Cnewvect=CC;
            else
                Cnewvect(end+1:end+numel(CC))=CC;
            end

            % keyboard


        end

    end

    


    for j=1:numel(Cnewvect)
        C=Cnewvect(j);
        % let's change yield units to ha, area units to tons
        %% get unit factors
        switch char(C.arealabels.unit_desc);
            case 'ACRES'

                Narea=1/2.4711;

            otherwise
                keyboard
        end

        switch char(C.yieldlabels.unit_desc);
            case 'BU / ACRE'

                switch cropname
                    case 'barley'
                        Nyield=0.021772* 2.4711;
                    case {'maize','sorghum'}
                        Nyield=0.0254* 2.4711;
                    case {'wheat','soybean'}
                        Nyield=0.0272155*2.4711;
                    case {'oats'}
                        % 32 lb/bu
                        %(https://www.vcalc.com/wiki/vcalc/pounds%20per%20bushel%20of%20oats
                        Nyield=32*2.4711/2.2/1000;

                    case {'rye'}
                        % 32 lb/bu
                        %(https://www.vcalc.com/wiki/vcalc/pounds%20per%20bushel%20of%20oats
                        Nyield=56*2.4711/2.2/1000;

                    otherwise
                        keyboard
                end
            case 'LB / ACRE'

                Nyield=1.12085/1000;


            case 'TONS / ACRE'

                Nyield= 2.4711;

            case 'CWT / ACRE'
%https://www.extension.iastate.edu/agdm/wholefarm/pdf/c6-80.pdf
% 1 quintal=1/10 metric ton

                Nyield=.125535;


            otherwise
                keyboard
        end

        %%

        dataSI.yield=C.NASSHybridData.yield*Nyield;
        dataSI.area=C.NASSHybridData.area*Narea;
        dataSI.year=C.NASSHybridData.year;

        Cnew=C;
        Cnew.dataSI=dataSI;

        % ok ... let's relate to gadm2
        switch Cnew.gadmLevel
            case 2
                ii=strmatch(lower(char(Cnew.state_name)),lower(g2USA.namelist1));
                g2state=subsetofstructureofvectors(g2USA,ii);

                [g2fasthash,g2countyname]=...
                    matchGADM2NASScounties(char(Cnew.county_name),g2state);

                Cnew.gadm.g2fasthash=g2fasthash;
                Cnew.gadm.g2countyname=g2countyname;

                idx=find(g2fasthash==g2.gadm2codesfasthash);

                if numel(idx)==1
                    Cnew.gadm.gadm2codes=g2.gadm2codes{idx};
                    Cnew.gadm.gadm2rastercode=g2.uniqueadminunitcode2(idx);
                else
                    Cnew.gadm.gadm2codes='';
                    Cnew.gadm.gadm2rastercode=0;

                end

            case 1
                ii=strmatch(lower(char(Cnew.state_name)),lower(g1USA.namelist1));

                Cnew.gadm.gadm1code=g1USA.gadm1codes{ii};
                Cnew.gadm.gadm1codefasthash=g1USA.gadm1codesfasthash(ii);
                Cnew.gadm.gadm1uniqueadmin=g1USA.uniqueadminunitcode(ii);

        end





        Cnewnewvect(j)=Cnew;

    end

    Cnewvect=Cnewnewvect;
    % now we match to FAO here.

    % first get a list of all years

    yrvect=[1970:2022];
    clear AverageYieldFAO  AverageAreaFAO NASSarea NASSyield
    for jyr=1:numel(yrvect);
        YYYY=yrvect(jyr);
        [AverageYieldFAO(jyr), AverageAreaFAO(jyr)] = GetAverageFAOData('USA',cropname,0,YYYY,0);

        clear avect
        clear yvect
        for j=1:numel(Cnewvect);
            idx=find(Cnewvect(j).dataSI.year==YYYY);
            if numel(idx)==1
                avect(j)=Cnewvect(j).dataSI.area(idx);
                yvect(j)=Cnewvect(j).dataSI.yield(idx);
            else
                avect(j)=0;
                yvect(j)=0;
            end


        end

        NASSarea(jyr)=sum(avect);
        NASSyield(jyr)=sum(avect.*yvect)/sum(avect);


        avectFAOnormalized=avect.*AverageAreaFAO(jyr)/sum(avect);
        yvectFAOnormalized=yvect.*AverageYieldFAO(jyr)/[sum(yvect.*avect)/sum(avect)];


        for j=1:numel(Cnewvect);
            Cnewvect(j).dataSI_FAOMatched.year(jyr)=YYYY;
            Cnewvect(j).dataSI_FAOMatched.area(jyr)=avectFAOnormalized(j);
            Cnewvect(j).dataSI_FAOMatched.yield(jyr)=yvectFAOnormalized(j);
        end




    end



    save(['CDSfiles/CDSprocessed' cropname '.mat'],'Cnewvect');


    Cnewvect=rmfield(Cnewvect,'NASSdataRaw');
    Cnewvect=rmfield(Cnewvect,'didnotparse');
    Cnewvect=rmfield(Cnewvect,'sharedlabels');
    Cnewvect=rmfield(Cnewvect,'arealabels');
    Cnewvect=rmfield(Cnewvect,'yieldlabels');
    Cnewvect=rmfield(Cnewvect,'NASSdataStateNormed');


% pull out some bad data elements
clear iikeep
for j=1:numel(Cnewvect);
    if Cnewvect(j).gadmLevel==1
        iikeep(j)=1;
    elseif Cnewvect(j).gadm.g2fasthash==0
        if any(Cnewvect(j).dataSI_FAOMatched.area>0)
    %        keyboard
        end
        iikeep(j)=0;
    else
        iikeep(j)=1;
    end
end

Cnewvect=Cnewvect(logical(iikeep));


    save(['CDSfiles/CDSprocessedslim' cropname '.mat'],'Cnewvect');


    figure
    subplot(211)
    plot(yrvect,NASSarea,yrvect,AverageAreaFAO,'x--')
    legend('NASS area','FAO area')
    zeroylim
    title(cropname)

    subplot(212)
    plot(yrvect,NASSyield,yrvect,AverageYieldFAO,'x--')
    legend('NASS yield','FAO yield')
    zeroylim

    outputfig('force',['figures/' cropname])

    % %% state level year2000
    % 
    % 
    % statelist=unique({Cnewvect.state_name})
    % 
    % for jstate=1:numel(statelist)
    %     state=statelist{jstate};
    % 
    %     ii=strmatch(state,{Cnewvect.state_name});
    %     CC=Cnewvect(ii);
    % 
    %     YYYY=2000;
    %     clear avect
    %     clear yvect
    %     for j=1:numel(CC);
    %         idx=find(CC(j).dataSI.year==YYYY);
    %         if numel(idx)==1
    %             avect(j)=CC(j).dataSI.area(idx);
    %             yvect(j)=CC(j).dataSI.yield(idx);
    %         else
    %             avect(j)=0;
    %             yvect(j)=0;
    %         end
    % 
    %         [AverageYieldFAO(jyr), AverageAreaFAO(jyr)] = GetAverageFAOData('USA',cropname,0,YYYY,0);
    % 
    %     end
    % 
    %     NASSarea(jstate)=sum(avect);
    %     NASSyield(jstate)=sum(avect.*yvect)/sum(avect);
    % 
    % end
end