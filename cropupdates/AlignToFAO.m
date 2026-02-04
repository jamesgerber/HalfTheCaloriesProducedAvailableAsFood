% AlignToFAO
%
%  This script reads in output from cleanGEOUnits and aligns to FAO Data.
%  for every country in the CDS files, calculate current total area and
%  total yield, then compare to FAO circa 2000 total area and total yield.
%  proportionally allocate changes in total area / total yield so that
%  resulting CDS match up with FAO.

croplist=CropListForProcessing;
%croplist=sixteencrops;
fivemingrid=fma;


PCUconstants;

[g0,g1,g2,g3]=getgeo41;

gadmgeo0=g0;
gadmgeo1=g1;
gadmgeo2=g2;
gadmgeo3=g3;



gadmgeo.gadmgeo0=g0;
gadmgeo.gadmgeo1=g1;
gadmgeo.gadmgeo2=g2;
gadmgeo.gadmgeo3=g3;
%%





for jcrop=1:numel(croplist)
    cropname=croplist{jcrop};
    savefilename = ['GeodatabaseFiles/MonfredaUpdate/CDSRev' AlignToFAOOutputRev '_FAOaligned' cropname '_withGADM0field_2000_pm' ...
        int2str(AlignPlusMinus)' ...
        '_NoAreaReallocation' '.mat']

    if exist(savefilename)==2 & ForceRedo==0
        disp(['already have ' savefilename ' from ' mfilename])
    else
        disp(['working on ' savefilename ' from ' mfilename])


    disp(['Processing ' cropname ]);
    load(['GeodatabaseFiles/MonfredaUpdate/CDSRev' CleanGEOUnitsOutputRev '_gadm_' cropname ],'CCnewGADMvect');
    CC=CCnewGADMvect;
    GADM3list=unique({CC.GADM3});

 
    for jCountry=1:numel(GADM3list)
        GADM3=GADM3list{jCountry};



        ii=strmatch(GADM3,{CC.GADM3});

        if numel(ii)>0

            CDSvect=CC(ii);
            [FAOyield2000,FAOarea2000]=GetAverageFAOData(GADM3,cropname,CC(ii),2000,AlignPlusMinus);
            FAOarea=FAOarea2000;
            FAOyield=FAOyield2000;
            FAOprod=FAOarea*FAOyield;

            if numel(ii)==1
                CC(ii).M3yieldNormalizedToFAO2000=FAOyield;
                CC(ii).M3areaNormalizedToFAO2000=FAOarea;
            else

                % scale yield and area




                M3yield=[CDSvect.M3yield];
                M3area=[CDSvect.M3area];

                jj=isfinite(M3yield.*M3area);

                M3prod=sum(M3yield(jj).*M3area(jj));


                M3avgyield=M3prod./sum(M3area(jj));

                % how compare to FAO?

                FAOProd=FAOyield.*FAOarea;

                M3areaScaled=M3area.*FAOarea./sum(M3area(jj));
                M3yieldScaled=M3yield.*FAOyield./M3avgyield;

                M3areaScaled(~jj)=nan;
                M3yieldScaled(~jj)=nan;

                for m=1:numel(ii)
                    CC(ii(m)).M3yieldNormalizedToFAO2000=M3yieldScaled(m);
                    CC(ii(m)).M3areaNormalizedToFAO2000=M3areaScaled(m);
                end

            end

        else
            keyboard

        end
    end

    Cnewvect=CC;

    save(savefilename,'Cnewvect');
    end

end
%%
