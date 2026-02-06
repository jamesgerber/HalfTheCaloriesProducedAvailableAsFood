Codes used for calculations of 
Only half of the calories produced on croplands are available as food for human consumption

Paul C. West, James S. Gerber,  Emily S. Cassidy,  Samuel Stiffman

Environmental Research: Food Systems

See the Zenodo repository at https://doi.org/10.5281/zenodo.18476564

Here is an upload of all codes used to create results and figures.

Some notes:

anyone running these codes will have to undertake a few things:

(1) make the 'datagateway' codes and directory work.  The codes in the 'datagateway' directory all require public domain datasets to be downloaded and installed on users' computer. 
I can't automate this because I don't want to republish others' data. 

(2) start with FoodFeedAllocationScript.m ... this sets up the path, and
should be run from a working directory.  Directories will be created within
this working directory.   I have had a working directory along with these
files:
FoodFeedAllocationScript - script that calls everything else 
HalfCaloriesLocalEnvironment - hard wire for your own directory structure
PCUconstants - a bunch of constants related to "Pertubative Crop Update"

(3) Notes on HalfCaloriesLocalEnvironment.m: you'll have to
adapt this for your own path structure.  Note that this file is in .gitignore
so you can change it and git won't try to track changes.    
Here's what it looks like for me: 

codedir=['~/source/HalfTheCaloriesProducedAvailableAsFood/'];

base=['/Users/jsgerber/sandbox/jsg220_FoodFeedAllocation_PublicationRevision/'];

workingdirectory=base;

SAGEAdminRastersDir=[base 'inputdata/Reference/AdminRastersSage'];;

databasedir=[base 'inputdata/Reference/ChadCropmaps/Global/database/'];

OceanMDBDataDir=[base 'inputdata/Reference/OutputOceanmdb/'];

GeoDatabaseDirectory=[base 'GeodatabaseFiles/'];



I'm available to help answer questions on how to do this (jgerber68@gmail.com)