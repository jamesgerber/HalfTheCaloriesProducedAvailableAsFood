% I've been working with some ad-hoc CDS (Crop Data Structure) files.
% It will be more helpful for the community if I turn them into shapefiles.
% I'm using matlab's shapewrite file to output these.
%
% Some notes:
% Because I'm using shapewrite there are some limitations:
%  can't have NaN or Inf, so I've replaced these with -999 and -999999
%  limited field names, so I've made the following mappings:
% D.M3yieldNormFAO2000=C.M3yieldNormalizedToFAO2000;
% D.M3areaNormFAO2000=C.M3areaNormalizedToFAO2000;
% D.CGArea2020=C.CropGridsArea2020;
% D.M3YPertTo2020=C.M3YieldPerturbedTo2020;
% D.M3YPertTo2015=C.M3YieldPerturbedTo2015;
% D.M3YPertTo2010=C.M3YieldPerturbedTo2010;
% D.M3APertTo2020=C.M3AreaPerturbedTo2020;
% D.M3APertTo2015=C.M3AreaPerturbedTo2015;
% D.M3APertTo2010=C.M3AreaPerturbedTo2010;
% D.LinSupArea2010=C.LinearSuperposedArea2010;
% D.LinSupArea2015=C.LinearSuperposedArea2015;
% D.M3Yield2020_CGHyb=C.M3Yield2020_CGHybridCorrection;
% D.M3Yield2015_CGHyb=C.M3Yield2015_CGHybridCorrection;
% D.M3Yield2010_CGHyb=C.M3Yield2010_CGHybridCorrection;

a=dir('GeodatabaseFiles/MonfredaCGHybrid/CDSRevA_FAOaligned*mat')

load intermediatedatafiles/SortedCropNames2020 Top50WorkingCropsSortedByCalories2020

[g0,g1,g2,g3]=getgeo41;

% section to clean up some GADM codes.  
% GHA
ii=strmatch('GHA',g1.gadm1codes);
for j=1:numel(ii);
    g1.gadm1codes{ii(j)}=strrep(g1.gadm1codes{ii(j)},'GHA','GHA.');
end


%not redistributing the GADM products.
s0=shaperead('~/DataProducts/ext/GADM/GADM41/GADM41_0/GADM41_0.shp')
s1=shaperead('~/DataProducts/ext/GADM/GADM41/GADM41b_1/GADM41b_1.shp')
s2=shaperead('~/DataProducts/ext/GADM/GADM41/GADM41b_2/GADM41b_2.shp')
s3=shaperead('~/DataProducts/ext/GADM/GADM41/GADM41b_3/GADM41b_3.shp')


for jcrop=1:50
    clear Dvect;
    cropname=Top50WorkingCropsSortedByCalories2020{jcrop};
    load(['GeodatabaseFiles/MonfredaCGHybrid/CDSRevA_FAOaligned' cropname '_withGADM0field_2000_pm2.mat']);

    for j=1:numel(Cnew)
        C=Cnew(j);
        clear D
        D.cropname=C.cropname;
        D.GADM3=C.GADM3;
        D.GADMNameCode=C.GADMNameCode;
        D.GADMCode=C.GADMCode;
        D.M3yield=C.M3yield;
        D.M3area=C.M3area;
        D.M3prod=C.M3production;
        D.M3yieldNormFAO2000=C.M3yieldNormalizedToFAO2000;
        D.M3areaNormFAO2000=C.M3areaNormalizedToFAO2000;
        D.CGArea2020=C.CropGridsArea2020;
        D.M3YPertTo2020=C.M3YieldPerturbedTo2020;
        D.M3YPertTo2015=C.M3YieldPerturbedTo2015;
        D.M3YPertTo2010=C.M3YieldPerturbedTo2010;
        D.M3APertTo2020=C.M3AreaPerturbedTo2020;
        D.M3APertTo2015=C.M3AreaPerturbedTo2015;
        D.M3APertTo2010=C.M3AreaPerturbedTo2010;
        D.LinSupArea2010=C.LinearSuperposedArea2010;
        D.LinSupArea2015=C.LinearSuperposedArea2015;
        D.M3Yield2020_CGHyb=C.M3Yield2020_CGHybridCorrection;
        D.M3Yield2015_CGHyb=C.M3Yield2015_CGHybridCorrection;
        D.M3Yield2010_CGHyb=C.M3Yield2010_CGHybridCorrection;




        % to save a shapefile, need to make all fields double.

        fn=fieldnames(D);
        for m=1:numel(fn);
            z=D.(fn{m});
            if isa(z,'single')
                D.(fn{m})=double(z);
            end

            if isnumeric(z)
                if isnan(z)
                    D.(fn{m})=-999;
                elseif isinf(z)
                    D.(fn{m})=-999999;
                end
            end

        end



        switch C.AdminLevel
            case 0
                idx=strmatch(D.GADM3,g0.gadm0codes);
                G=s0(idx);

                D.Geometry=G.Geometry;
                D.BoundingBox=G.BoundingBox;
                D.X=G.X;
                D.Y=G.Y;
            case 1
                idx=strmatch(D.GADMCode,g1.gadm1codes,'exact');
                G=s1(idx);

                D.Geometry=G.Geometry;
                D.BoundingBox=G.BoundingBox;
                D.X=G.X;
                D.Y=G.Y;         
            case 2
                idx=strmatch(D.GADMCode,g2.gadm2codes,'exact');
                G=s2(idx);

                D.Geometry=G.Geometry;
                D.BoundingBox=G.BoundingBox;
                D.X=G.X;
                D.Y=G.Y;         
            case 3
                idx=strmatch(D.GADMCode,g3.gadm3codes,'exact');
                G=s3(idx);

                D.Geometry=G.Geometry;
                D.BoundingBox=G.BoundingBox;
                D.X=G.X;
                D.Y=G.Y;         

                keyboard
        end


        Dvect(j)=D;





    end
shapewrite(Dvect,['GeodatabaseFiles/MonfredaCGHybridshp/MonfredaCropGridsHybrid_FAO_perturbed_' cropname]);
end
