


croplist=CropListForProcessing;

for jcrop=1:numel(croplist);
    %spare jcrop croplist
    clear asum bsum csum dsum esum fsum gsum hsum isum
    AlignPlusMinus=2;
    PCUconstants

    %croplist=CropListForProcessing;
    clear Cnew Cnewnewvect 
    cropname=croplist{jcrop};

    savefilename=['GeodatabaseFiles/MonfredaCGHybrid/CDSRev' CreateHybridGDBRev '_FAOaligned' cropname '_withGADM0field_2000_pm' ...
        int2str(AlignPlusMinus) '.mat'];
    if exist(savefilename)==2 & ForceRedo ~=1
        disp(['already have ' savefilename ' in ' mfilename]);
    else
        disp(['processing ' savefilename ' in ' mfilename]);



        [harvareamap,cropareamap,version]=getCropGridsArea(cropname);
        [DS]=getdata(cropname);
        a=DS.Data(:,:,1);
        a(a==a(1))=0;
        cropareaMonf=a;



        load(['GeodatabaseFiles/MonfredaUpdate/CDSRev' AlignToFAOOutputRev '_FAOaligned' cropname '_withGADM0field_2000_pm' ...
            int2str(AlignPlusMinus)' ...
            '_NoAreaReallocation'],'Cnewvect');


        ISOlist=unique({Cnewvect.GADM3});

        for jISO=1:numel(ISOlist);
            GADM3=ISOlist{jISO};
            jj=strmatch(GADM3,{Cnewvect.GADM3});
            CCcountry=Cnewvect(jj);

            [FAOyield2000,FAOarea2000]=GetAverageFAOData(GADM3,cropname,0,2000,AlignPlusMinus);
            [FAOyield2010,FAOarea2010]=GetAverageFAOData(GADM3,cropname,0,2010,AlignPlusMinus);
            [FAOyield2015,FAOarea2015]=GetAverageFAOData(GADM3,cropname,0,2015,AlignPlusMinus);
            [FAOyield2020,FAOarea2020]=GetAverageFAOData(GADM3,cropname,0,2020,AlignPlusMinus);


            clear Cnew
            for j=1:numel(CCcountry)
                CC=CCcountry(j);
                ii=GADMCodeToIndices(CC.GADMCode);
                CGHA2020=sum(harvareamap(ii).*fma(ii)); % cropgrids harvested area
                MonfHA2000=sum(cropareaMonf(ii).*fma(ii)); % Monfreda 2000 harvested area


                CC.CropGridsArea2020=CGHA2020*(MonfHA2000>0);
                CC.M3YieldPerturbedTo2020=CC.M3yieldNormalizedToFAO2000*FAOyield2020/FAOyield2000;
                CC.M3YieldPerturbedTo2010=CC.M3yieldNormalizedToFAO2000*FAOyield2010/FAOyield2000;
                CC.M3YieldPerturbedTo2015=CC.M3yieldNormalizedToFAO2000*FAOyield2015/FAOyield2000;
                CC.M3AreaPerturbedTo2020=CC.M3areaNormalizedToFAO2000*FAOarea2020/FAOarea2000;
                CC.M3AreaPerturbedTo2015=CC.M3areaNormalizedToFAO2000*FAOarea2015/FAOarea2000;
                CC.M3AreaPerturbedTo2010=CC.M3areaNormalizedToFAO2000*FAOarea2010/FAOarea2000;
                CC.LinearSuperposedArea2010=(CGHA2020+MonfHA2000)/2;
                CC.LinearSuperposedArea2015=(CGHA2020*3+MonfHA2000)/4;
                Cnew(j)=CC;
            end

            Normfactor=FAOyield2020*FAOarea2020/nansum([Cnew.CropGridsArea2020].*[Cnew.M3YieldPerturbedTo2020]);
            for j=1:numel(Cnew)
                Cnew(j).M3Yield2020_CGHybridCorrection=Cnew(j).M3YieldPerturbedTo2020*Normfactor;
            end
            asum(jISO)=nansum([Cnew.M3AreaPerturbedTo2020].*[Cnew.M3YieldPerturbedTo2020]);
            bsum(jISO)=nansum([Cnew.CropGridsArea2020].*[Cnew.M3Yield2020_CGHybridCorrection]);
            csum(jISO)=FAOyield2020*FAOarea2020;


            Normfactor2=FAOyield2010*FAOarea2010/nansum([Cnew.LinearSuperposedArea2010].*[Cnew.M3YieldPerturbedTo2010]);
            for j=1:numel(Cnew)
                Cnew(j).M3Yield2010_CGHybridCorrection=Cnew(j).M3YieldPerturbedTo2010*Normfactor2;
            end

            dsum(jISO)=nansum([Cnew.M3AreaPerturbedTo2010].*[Cnew.M3YieldPerturbedTo2010]);
            esum(jISO)=nansum([Cnew.LinearSuperposedArea2010].*[Cnew.M3Yield2010_CGHybridCorrection]);
            fsum(jISO)=FAOyield2010*FAOarea2010;



            Normfactor3=FAOyield2015*FAOarea2015/nansum([Cnew.LinearSuperposedArea2015].*[Cnew.M3YieldPerturbedTo2015]);
            for j=1:numel(Cnew)
                Cnew(j).M3Yield2015_CGHybridCorrection=Cnew(j).M3YieldPerturbedTo2015*Normfactor3;
            end

            gsum(jISO)=nansum([Cnew.M3AreaPerturbedTo2015].*[Cnew.M3YieldPerturbedTo2015]);
            hsum(jISO)=nansum([Cnew.LinearSuperposedArea2015].*[Cnew.M3Yield2015_CGHybridCorrection]);
            isum(jISO)=FAOyield2015*FAOarea2015;

            Cnewnewvect(jj)=Cnew;

        end


        Cnew=Cnewnewvect;




        save(savefilename,'Cnew','asum','bsum','csum','dsum','esum','fsum','gsum','hsum','isum');
    end

end