function Code=cropnameToCode(cropname)


persistent cropcodes

if isempty(cropcodes)
    
    databasedir='/Users/jsgerber/sandbox/jsg184_MonfredaRasters_To_DataStructures/RawDataFromChad2/ChadCropmaps/Global/database/';
    cropcodes=readgenericcsv([databasedir 'cropcodes.csv']);
end

idx=strmatch(cropname,cropcodes.CROPNAME,'exact');

if numel(idx)~=1
    switch cropname
        case 'pulsesnes'
            idx=strmatch('pulsenes',cropcodes.CROPNAME,'exact');
        case 'rootsnes'
            idx=strmatch('rootnes',cropcodes.CROPNAME,'exact');
        case 'vegetablesnes'
            idx=strmatch('vegetablenes',cropcodes.CROPNAME,'exact');
        otherwise
            error
    end
end

Code=cropcodes.ITEM_CODE(idx);
