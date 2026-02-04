function croplist=CropListForProcessing;
%CropListForProcessing - which crops to process
%
%  This simple function gives me an easy way to have just one or two crops
%  for debugging/ processing through all of the 
%  steps.


%croplist=cropnames;
load intermediatedatafiles/SortedCropNames2020.mat
croplist=Top50WorkingCropsSortedByCalories2020(1:end);

%croplist={'maize'};
