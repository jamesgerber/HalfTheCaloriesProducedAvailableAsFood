
HalfCaloriesLocalEnvironment




% consider testing having paths at beginning or end in case something
% named here conflicts
% addpath([codedir 'cropupdates']);
% addpath([codedir 'utilities']);
% addpath([codedir 'datagateways']);
% addpath([codedir 'foodfeedallocation']);
% addpath([codedir 'postprocess']);

addpath([codedir 'cropupdates'],'-end');
addpath([codedir 'utilities'],'-end');
addpath([codedir 'datagateways'],'-end');
addpath([codedir 'foodfeedallocation'],'-end');
addpath([codedir 'postprocess'],'-end');


% the paths for this code base are written such that there is a working
% directory and there is a folder ./codes with that, and these files live
% within codes.
%
% this script should be in the working directory.  In other words, at a
% minimum, this should not crash:





% notes to user:
%
%  We are not supplying the codes in datagateways/  this is because users
%  should obtain the data directly.  For the Monfreda data this can be
%  obtained from www.earthstat.org, for cropgrids this can be obtained from
%  https://figshare.com/articles/dataset/CROPGRIDS/22491997
%
%  codes are [area,yield]=getmonfredadata;
%
%
% need to run this once
mkdir GeodatabaseFiles/MonfredaUpdate/
mkdir GeodatabaseFiles/MonfredaCGHybrid
mkdir intermediatedatafiles/matfilesCropGridHybrid/
% set up paths and working directories
PCUconstants


%
MakeCDS_Raw; %

makeCDS

cleanGEOUnits

AlignToFAO

% now make the hybrid geodatabases

CreateHybridMonfCG


% figure out which crops matter the most

% this can remain commented out, providing output file with distribution.
% sortcropsbycalories_useSUACalorieDensity


% now make layers of production - call this once, it makes a bunch of
% layers, then it shouldn't need to be called again.
makeinitialproductionlayers


% make all of the individual maps, this really is the heart of the analysis
makemapoffoodvsfeedSUA_trackcalories

% combine maps
% note that jcroploop=0 for the combined map, jcroploop=1:50 for individual
% maps, can do them all at once (jcroploop=0:50) but need to do both to get
% the CropUtilization files and publication maps.
% jcroploop negative corresponds to the validation studies.
%

combinecaloriemaps_MultiplyFractions



%A key output of combinecaloriemaps_MultiplyFractions is the .csv files in
%CalorieUtilization/ ... these break down the data for every country.  More
%useful, however, is to sum the data across countries, and the resulting
%files can be further mined to assess totals.

%The file CombineCalorieUtilizationFilesAcrossCountries.m does this, and
%makes the files 
% CalorieUtilizationSummaryOutputYYYY.csv

CombineCalorieUtilizationFilesAcrossCountries

%This then calls

CombineCalorieUtilizationFilesAcrossCrops


PrepDataForHorizontalbarchartoffoodfeed


% there is a validation step which results in the production of some
% useful data and some figures in the supplemental.  Those aren't in the
% workflow above. 

preparevalidationCDS