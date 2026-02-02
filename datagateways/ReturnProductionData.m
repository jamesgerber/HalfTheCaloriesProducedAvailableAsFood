function [CPD,verstring]=ReturnProductionData;
% ReturnProductionData - read in FAOstat production data, keep in
% persistent

persistent a

if isempty(a)
    DPD=DataProductsDir;
    thissetdir= 'ext/FAOstat/Production_Crops_Livestock_E_All_Data_(Normalized)/Oct2024/';
    a=readgenericcsv([ DPD thissetdir 'Production_Crops_Livestock_E_All_Data_Normalizednq.txt'],1,tab,1);


    a=rmfield(a,'Year_Code');
    a=rmfield(a,'Note');
    a=rmfield(a,'Flag');
end
verstring='Oct_2024';

CPD=a;
