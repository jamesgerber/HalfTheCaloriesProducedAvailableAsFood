
% code to make CDS ("CropDataStructure" Geodatabases).
%
% Here i'm using the databases from Chad (via Julie/Navin) to generate a
% set of crop data structures.  These will use the shapefiles from Chad and
% associate the yield/area data from Chad, but also pull out the
% data from the rasters.
%

% generate CropDataStructures (CDS) based on the admin units implicit in
% the datafiles from chad (via Navin/Julie).   These CDS have the following
% properties:
%    have raw census data for yield and area
%    have monfreda raster yield area and indices according to geographical
%  units
%    often exist at multiple overlapping geographic scales, subsequent
%    codes will determine which overlapping geographic scales are the best
%    fit.
%


% some constants
PCUconstants
cropcodes=readgenericcsv([databasedir 'cropcodes.csv']);
croplist=CropListForProcessing;
cd(workingdirectory)

%%%%%%%%%%%%%%%%%%
%% Yield values  %
%%%%%%%%%%%%%%%%%%

disp(['reading in a bunch of stuff'])
ylamer=readgenericcsv([databasedir 'lameryield.txt']);
yeur=readgenericcsv([databasedir 'euryield.txt']);
yafr=readgenericcsv([databasedir 'afryield.txt']);
yasia=readgenericcsv([databasedir 'asiayield.txt']);
ymdest=readgenericcsv([databasedir 'mdestyieldHeader.txt']);
ynamer=readgenericcsv([databasedir 'admin0andnamer.zip/nameryield.txt']);
yocean=readgenericcsv([OceanMDBDataDir 'OUTPUTYIELD.csv']);


y=combineyieldfiles(yeur,ylamer);
y=combineyieldfiles(y,yafr);
y=combineyieldfiles(y,yasia);
y=combineyieldfiles(y,ymdest);
y=combineyieldfiles(y,ynamer);
ystash=combineyieldfiles(y,yocean);
clear y

%%%%%%%%%%%%%%%%%%
%% Area values  %
%%%%%%%%%%%%%%%%%%
alamer=readgenericcsv([databasedir 'lamerarea.txt']);
aeur=readgenericcsv([databasedir 'eurarea.txt']);
aafr=readgenericcsv([databasedir 'afrarea.txt']);
aasia=readgenericcsv([databasedir 'asiaarea.txt']);
amdest=readgenericcsv([databasedir 'mdestarea.txt']);
anamer=readgenericcsv([databasedir 'admin0andnamer.zip/namerarea.txt']);
aocean=readgenericcsv([databasedir 'asiaarea.txt']);




a=combineyieldfiles(aeur,alamer);
a=combineyieldfiles(a,aafr);
a=combineyieldfiles(a,aasia);
a=combineyieldfiles(a,amdest);
a=combineyieldfiles(a,anamer);
astash=combineyieldfiles(a,aocean);

fivemingrid=fma;


disp(['starting analysis'])
% loop through crops
for jcrop=1:numel(croplist)

    cropname=croplist{jcrop}
    cropcode=cropnameToCode(cropname);

    savefilename=['GeodatabaseFiles/MonfredaUpdate/CDS_Raw_Rev' CDSRawOutputRev '_' cropname '.mat'];

    if exist(savefilename)==2
        disp(['already have ' savefilename])
    else


    [area,yield]=getmonfredadata(cropname);

    %%
    map0=datablank;
    numberwrites0=datablank;

    map1=datablank;
    numberwrites1=datablank;

    map2=datablank;
    numberwrites2=datablank;

    map3=datablank;
    numberwrites3=datablank;
    areamap0=datablank;
    numberwritesarea0=datablank;

    areamap1=datablank;
    numberwritesarea1=datablank;

    areamap2=datablank;
    numberwritesarea2=datablank;

    areamap3=datablank;
    numberwritesarea3=datablank;
    %
    clear CDSvect;
    tic
    c=0;





    ii=ystash.ITEM_CODE==cropcode;
    y.SAGEADMCDE=ystash.SAGEADMCDE(ii);
    y.ITEM_CODE=ystash.ITEM_CODE(ii);
    y.YIELD=ystash.YIELD(ii);

    ii=astash.ITEM_CODE==cropcode;
    a.SAGEADMCDE=astash.SAGEADMCDE(ii);
    a.ITEM_CODE=astash.ITEM_CODE(ii);
    a.AREA=astash.AREA(ii);



    %% remove duplicate census entries (example: Mexico bean)
    z=unique(y.SAGEADMCDE);
    for j=1:numel(z);
        ii=strmatch(z(j),y.SAGEADMCDE);

        if numel(ii)>1
            keep=setdiff(1:numel(y.SAGEADMCDE),ii(2:end));
            y.ITEM_CODE=y.ITEM_CODE(keep);
            y.YIELD=y.YIELD(keep);
            y.SAGEADMCDE=y.SAGEADMCDE(keep);
        end
    end
    z=unique(a.SAGEADMCDE);
    for j=1:numel(z);
        ii=strmatch(z(j),a.SAGEADMCDE);

        if numel(ii)>1
            keep=setdiff(1:numel(a.SAGEADMCDE),ii(2:end));
            a.ITEM_CODE=a.ITEM_CODE(keep);
            a.AREA=a.AREA(keep);
            a.SAGEADMCDE=a.SAGEADMCDE(keep);
        end
    end





    IndicesOfAreaElementsThatHadYield=a.AREA*0;
    %%
    for j=1:numel(y.SAGEADMCDE)

        if y.ITEM_CODE(j)==cropcode;

            clear CDS

            SAGE35=y.SAGEADMCDE{j};

            [ii,AdminLevel]=SAGE_ADM_codeToIndices(SAGE35);

            CDS.indices=ii;
            CDS.AdminLevel=AdminLevel;
            CDS.yieldRevEng=yield(ii);
            CDS.yieldCensus=y.YIELD(j);
            CDS.SAGE35=SAGE35;

            switch AdminLevel
                case 0
                    map0(ii)=y.YIELD(j);
                    numberwrites0(ii)=numberwrites0(ii)+1;
                case 1
                    map1(ii)=y.YIELD(j);
                    numberwrites1(ii)=numberwrites1(ii)+1;
                case 2
                    map2(ii)=y.YIELD(j);
                    numberwrites2(ii)=numberwrites2(ii)+1;
                case 3
                    map3(ii)=y.YIELD(j);
                    numberwrites3(ii)=numberwrites3(ii)+1;
            end



            % now look in the area data

            idx=strmatch(SAGE35,a.SAGEADMCDE);
            idxcrop=find(a.ITEM_CODE==cropcode);

            idx=intersect(idx,idxcrop);

            switch numel(idx)
                case 0
                    disp(['found yield but no area']);
                    CDS.areaRevEng=area(ii);
                    CDS.areaCensus=a.AREA(idx)*nan;
                case 1

                    IndicesOfAreaElementsThatHadYield(idx)=1;

                    CDS.areaRevEng=area(ii);
                    CDS.areaCensus=a.AREA(idx);

                    switch AdminLevel
                        case 0
                            areamap0(ii)=a.AREA(idx);
                            numberwritesarea0(ii)=numberwritesarea0(ii)+1;
                        case 1
                            areamap1(ii)=a.AREA(idx);
                            numberwritesarea1(ii)=numberwritesarea1(ii)+1;
                        case 2
                            areamap2(ii)=a.AREA(idx);
                            numberwritesarea2(ii)=numberwritesarea2(ii)+1;
                        case 3
                            areamap3(ii)=a.AREA(idx);
                            numberwritesarea3(ii)=numberwritesarea3(ii)+1;
                    end
                otherwise
                    disp(['multiple areas with yield'])

                    % area areas approximately the same?

                    if std(a.AREA(idx)) <= abs(mean(a.AREA(idx))*.001);

                        % areas approximately the same
                        for m=1:numel(idx)
                            IndicesOfAreaElementsThatHadYield(idx(m))=1;

                            CDS.areaRevEng=area(ii);
                            CDS.areaCensus=a.AREA(idx(1));

                            switch AdminLevel
                                case 0
                                    areamap0(ii)=a.AREA(idx(1));
                                    numberwritesarea0(ii)=numberwritesarea0(ii)+1;
                                case 1
                                    areamap1(ii)=a.AREA(idx(1));
                                    numberwritesarea1(ii)=numberwritesarea1(ii)+1;
                                case 2
                                    areamap2(ii)=a.AREA(idx(1));
                                    numberwritesarea2(ii)=numberwritesarea2(ii)+1;
                                case 3
                                    areamap3(ii)=a.AREA(idx(1));
                                    numberwritesarea3(ii)=numberwritesarea3(ii)+1;
                            end


                        end

                    else
                        disp(['and areas different'])
                        keyboard
                    end
            end
            c=c+1;
            CDSvect(c)=CDS;

        end
    end
    elapsedtime=toc;
    %%
    fivemingrid=fma;


    for m=1:numel(CDSvect)


        % let's calculate avg Monfreda Yield over these indices
        ii=CDSvect(m).indices;
        aa=area(ii);
        yy=yield(ii);
        fiveminidx=fivemingrid(ii);

        jj=isfinite(aa.*yy);


        %pp=nansum(aa(jj).*yy(jj).*fivemingrid(ii(jj)));
        zz=aa(jj).*yy(jj).*fivemingrid(ii(jj));
        pp=sum(zz(~isnan(zz)));

        avgyield=pp./sum(aa(jj).*fiveminidx(jj));

        CDSvect(m).ProdWeightedYield=avgyield;
        CDSvect(m).ProdRevEng=pp;
        CDSvect(m).SAGE3=CDSvect(m).SAGE35(1:3);
    end


    save(savefilename,'CDSvect','map0','map1','map2','areamap0','areamap1','areamap2','areamap3','map3',...
        'IndicesOfAreaElementsThatHadYield');
    end

end
