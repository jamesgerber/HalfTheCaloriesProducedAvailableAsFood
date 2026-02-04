
yrvect=1974:2022
%yrvect=1974:1975;;
%yrvect=[2000 2002 2005 2010];

for c=[1:17]%:29;
    clear CDS
    for jyr=1:numel(yrvect)
        YYYY=yrvect(jyr)

        AreaS=getharvestedareaBRA(YYYY);
        ProdS=getproductionBRA(YYYY);

        [cropnamezinho,cropname]=cropinhos(c);


        x={AreaS.portuguesename};
        idx=strmatch(cropnamezinho,x)
        A=AreaS(idx);

        x={ProdS.portuguesename};
        idx=strmatch(cropnamezinho,x)
        P=ProdS(idx);





        if iscell(P.datacolumn)
            P.datacolumn=str2double(P.datacolumn);
        end

        if iscell(A.datacolumn)
            A.datacolumn=str2double(A.datacolumn);
        end



        [g0,g1,g2,g3,g]=getgeo41;


       
        



        [~,ii]=unique(A.gadm2codes);
        codelist=A.gadm2codesfasthash(ii);
        gadm2codelist=A.gadm2codes(ii);

        N2namelist=A.N2list(ii);
        for j=1:numel(codelist);

            code=codelist(j);
            % first get area

            idx=find(code==A.gadm2codesfasthash);
            area(j)=A.datacolumn(idx);

            idx=find(code==P.gadm2codesfasthash);
            prod(j)=P.datacolumn(idx);


        end


        yield=prod./area;

        ii=isfinite(yield);

        avgyieldIBGE(jyr)=sum(yield(ii).*area(ii))/sum(area(ii))
        areaIBGE(jyr)=nansum(area);
        testarea(jyr)=nansum(area(ii));
        prodIBGE(jyr)=nansum(prod);

        try
            [AverageYieldFAO(jyr), AverageAreaFAO(jyr)] = GetAverageFAOData('BRA',cropname,0,YYYY,0);
        catch
            AverageYieldFAO(jyr)=nan;
            AverageAreaFAO(jyr)=nan;
        end


        area_FAOMatch=area.*AverageAreaFAO(jyr)./nansum(area);
        prod_FAOMatch=prod.*AverageAreaFAO(jyr)*AverageYieldFAO(jyr)./nansum(prod);
        yield_FAOMatch=prod_FAOMatch./area_FAOMatch;

        CDS(jyr).yield=yield;
        CDS(jyr).gadm2codefasthash=codelist;
        CDS(jyr).gadm2code=gadm2codelist;
        CDS(jyr).N2namelist=N2namelist;
        CDS(jyr).year=YYYY;
        CDS(jyr).area=area;
        CDS(jyr).production=prod;
        CDS(jyr).cropname=cropname;
        CDS(jyr).cropname_portuguese=cropnamezinho;
        CDS(jyr).area_FAOMatch=area_FAOMatch;
        CDS(jyr).yield_FAOMatch=yield_FAOMatch;


    end
    %%
    figure
    subplot(311)
    plot(yrvect,avgyieldIBGE,yrvect,AverageYieldFAO,'x')
    title yield
    subplot(312)
    plot(yrvect,areaIBGE,yrvect,AverageAreaFAO,'x')
    title area
    subplot(313)
    plot(yrvect,prodIBGE,yrvect,AverageAreaFAO.*AverageYieldFAO,'o');
    legend(cropnamezinho, cropname)
    title production
    fattenplot
    outputfig('force',['figures/' cropname '_' cropnamezinho])


    clear C
    for j=1:numel(CDS(1).gadm2codefasthash)
        C(j).gadm2codefasthash=CDS(1).gadm2codefasthash(j);
        C(j).cropname=CDS(1).cropname;
        C(j).N2name=CDS(1).N2namelist{j};
        C(j).gadm2code=CDS(1).gadm2code{j};
        %C(j).gadm2code=CDS(1).
        for m=1:numel(CDS);
            C(j).rawdata.year(m)=CDS(m).year;
            C(j).rawdata.area(m)=CDS(m).area(j);
            C(j).rawdata.yield(m)=CDS(m).yield(j);
    
            C(j).data.year(m)=CDS(m).year;
            C(j).data.area(m)=CDS(m).area_FAOMatch(j);
            C(j).data.yield(m)=CDS(m).yield_FAOMatch(j);
        end
        C(j).source='from IBGE 12_23, "table 1612"';
        C(j).areaunits='ha';
        C(j).yieldunits='tons/ha';
    end
    
    Cnew=C;
    save(['datastructures/version2_' cropname],'Cnew');

end

