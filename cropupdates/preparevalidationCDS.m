% prepare the CDS (crop data structures) from IBGE and NASS, and put them
% in a simple format which can then be ingested by
% caloriemapslayergateway.m

%those CDS need the following properties:

% live in GeodatabaseFiles/ValidationCDS/

% these fields:
%  GADMCode
%  validationtestarea2020
%  validationtestyield2020
%  validationtestarea2000
%  validationtestyield2000


NASSCropList= {'maize', 'wheat', 'soybean', 'rice',...
    'barley', 'oats', 'cotton', 'groundnut', 'sorghum', ...
    'rapeseed','potato','rye','sugarcane','sweetpotato'};

IBGECropList  = {'cotton', 'rice', 'oats', 'sweetpotato', 'potato', 'sugarcane', 'rye',...
    'barley', 'pea', 'cassava', 'watermelon', 'maize', 'soybean', ...
    'sorghum', 'tomato', 'wheat', 'triticale'};

[Both,ia,ib]=intersect(NASSCropList,IBGECropList);

BRAlist=setdiff(IBGECropList,Both);
USAlist=setdiff(NASSCropList,Both);


%doing some crops that aren't in the top 50, but a useful product so
%I'll share anyway

for j=1:numel(USAlist);

    cropname=USAlist{j};
    load(['GeodatabaseFiles/NASS/CDSprocessedslim' cropname '.mat'],'Cnewvect');
    clear Cval
    for m=1:numel(Cnewvect);
        C=Cnewvect(m);

        switch C.gadmLevel
            case 2
                Cval(m).GADMCode=C.gadm.gadm2codes;
            case 1
                Cval(m).GADMCode=C.gadm.gadm1code;
        end

        ii=find(C.dataSI_FAOMatched.year==2000);
        Cval(m).validationtestarea2000=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2000=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2019);
        Cval(m).validationtestarea2019=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2019=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2020);
        Cval(m).validationtestarea2020=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2020=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2021);
        Cval(m).validationtestarea2021=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2021=C.dataSI_FAOMatched.yield(ii);

        Cval(m).cropname=cropname;
    end

    save(['GeodatabaseFiles/ValidationCDS/CDS_' cropname '.mat'],'Cval');
end




% now BRA
for j=1:numel(BRAlist);

    cropname=BRAlist{j};
    load(['GeodatabaseFiles/IBGE/version2_' cropname '.mat'],'Cnew');
    clear Cval
    for m=1:numel(Cnew);
        C=Cnew(m);
        Cval(m).GADMCode=C.gadm2code;

        ii=find(C.data.year==2000);
        Cval(m).validationtestarea2000=C.data.area(ii);
        Cval(m).validationtestyield2000=C.data.yield(ii);

        ii=find(C.data.year==2019);
        Cval(m).validationtestarea2019=C.data.area(ii);
        Cval(m).validationtestyield2019=C.data.yield(ii);

        ii=find(C.data.year==2020);
        Cval(m).validationtestarea2020=C.data.area(ii);
        Cval(m).validationtestyield2020=C.data.yield(ii);

        ii=find(C.data.year==2021);
        Cval(m).validationtestarea2021=C.data.area(ii);
        Cval(m).validationtestyield2021=C.data.yield(ii);

        Cval(m).cropname=cropname;
    end

    save(['GeodatabaseFiles/ValidationCDS/CDS_' cropname '.mat'],'Cval');
end

% now the ones with both

for j=1:numel(Both);
    cropname=Both{j};

    load(['GeodatabaseFiles/NASS/CDSprocessedslim' cropname '.mat'],'Cnewvect');
    clear Cval
    for m=1:numel(Cnewvect);
        C=Cnewvect(m);

        switch C.gadmLevel
            case 2
                Cval(m).GADMCode=C.gadm.gadm2codes;
            case 1
                Cval(m).GADMCode=C.gadm.gadm1code;
        end

        ii=find(C.dataSI_FAOMatched.year==2000);
        Cval(m).validationtestarea2000=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2000=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2019);
        Cval(m).validationtestarea2019=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2019=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2020);
        Cval(m).validationtestarea2020=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2020=C.dataSI_FAOMatched.yield(ii);

        ii=find(C.dataSI_FAOMatched.year==2021);
        Cval(m).validationtestarea2021=C.dataSI_FAOMatched.area(ii);
        Cval(m).validationtestyield2021=C.dataSI_FAOMatched.yield(ii);

        Cval(m).cropname=cropname;
    end


    load(['GeodatabaseFiles/IBGE/version2_' cropname '.mat'],'Cnew');
    for c=1:numel(Cnew);
        m=m+1;
        C=Cnew(c);
        Cval(m).GADMCode=C.gadm2code;

        ii=find(C.data.year==2000);
        Cval(m).validationtestarea2000=C.data.area(ii);
        Cval(m).validationtestyield2000=C.data.yield(ii);

        ii=find(C.data.year==2019);
        Cval(m).validationtestarea2019=C.data.area(ii);
        Cval(m).validationtestyield2019=C.data.yield(ii);

        ii=find(C.data.year==2020);
        Cval(m).validationtestarea2020=C.data.area(ii);
        Cval(m).validationtestyield2020=C.data.yield(ii);

        ii=find(C.data.year==2021);
        Cval(m).validationtestarea2021=C.data.area(ii);
        Cval(m).validationtestyield2021=C.data.yield(ii);

        Cval(m).cropname=cropname;
    end

    save(['GeodatabaseFiles/ValidationCDS/CDS_' cropname '.mat'],'Cval');
end