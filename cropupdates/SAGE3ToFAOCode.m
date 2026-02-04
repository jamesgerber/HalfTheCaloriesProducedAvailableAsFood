function FAOCode=SAGE3ToFAOCode(SAGE3,yr);
%SAGE3ToFAOCode SAGE3 3 letter code to FAO country number


Codes=FAONamesToCodes;


if nargin==1
    yr=2000;
end


switch SAGE3
        case 'SDN'
            if yr >= 2012
                FAOCode=276;
            else
                FAOCode=206;
            end
            return
end




idx=strmatch(SAGE3,Codes.ISO3);

if numel(idx)==1
    
    FAOCode=Codes.FAOSTAT(idx);
else
    
    switch SAGE3
        case 'ROM'
            FAOCode=SAGE3ToFAOCode('ROU');
        case 'SMN'
            FAOCode=186;
        case 'XKO'
            FAOCode=273;
        case 'SSD'
            FAOCode=277;
        case 'GLP'
            FAOCode=87;
        case 'TWN'
            FAOCode=214;
        otherwise
            FAOCode=[];

    end

            % former sudan='276'
    end
    
end

    