function [g2fasthash,g2countyname]=...
    matchGADM2NASScounties(NASSCounty,g2state);
% matchGADM2NASScounties 
lowercountynamelist=lower(g2state.namelist2);


% match a NASSCounty and state with gadm2
NASSCounty=strrep(NASSCounty,'ST.','SAINT');

idx=strmatch(lower(NASSCounty),lowercountynamelist,'exact');

idxother=strmatch('other',lower(NASSCounty));

if idxother ==1
    g2fasthash=0;
    g2countyname='other';
return
end

if numel(idx)~=1
    
    switch NASSCounty
        case 'DE KALB'
            idx=strmatch('dekalb',lowercountynamelist,'exact');
        case 'DU PAGE'
            idx=strmatch('dupage',lowercountynamelist,'exact');
        case 'ST CLAIR'
            idx=strmatch('saint clair',lowercountynamelist,'exact');
        case 'LA PORTE'
            idx=strmatch('laporte',lowercountynamelist,'exact');
        case 'O BRIEN'
            idx=strmatch('o''brien',lowercountynamelist,'exact');
        case 'PRINCE GEORGES'
            idx=strmatch('prince george''s',lowercountynamelist,'exact');
        case 'QUEEN ANNES'
            idx=strmatch('queen anne''s',lowercountynamelist,'exact');
        case 'ST MARYS'
            idx=strmatch('saint mary''s',lowercountynamelist,'exact');
        case 'ST JOSEPH'
            idx=strmatch('saint joseph',lowercountynamelist,'exact');
        case 'DE SOTO'
            idx=strmatch('desoto',lowercountynamelist,'exact');
        case 'ST JOSEPH'
            idx=strmatch('saint joseph',lowercountynamelist,'exact');
        case 'ST CHARLES'
            idx=strmatch('saint charles',lowercountynamelist,'exact');
        case 'ST FRANCOIS'
            idx=strmatch('saint francois',lowercountynamelist,'exact');
        case 'ST LOUIS'
            idx=strmatch('saint louis',lowercountynamelist,'exact');
         case 'STE GENEVIEVE'
            idx=strmatch('sainte genevieve',lowercountynamelist,'exact');
         case 'STE. GENEVIEVE'
            idx=strmatch('sainte genevieve',lowercountynamelist,'exact');
        case 'ST FRANCOIS'
            idx=strmatch('saint francois',lowercountynamelist,'exact');
         case 'DE BACA'
            idx=strmatch('debaca',lowercountynamelist,'exact');
        case 'ST LAWRENCE'
            idx=strmatch('saint lawrence',lowercountynamelist,'exact');
        case 'LA MOURE'
            idx=strmatch('lamoure',lowercountynamelist,'exact');
        case 'LEFLORE'
            idx=strmatch('le flore',lowercountynamelist,'exact');
         case 'MCKEAN'
            idx=strmatch('mc kean',lowercountynamelist,'exact');
         case 'LAPAZ'
            idx=strmatch('la paz',lowercountynamelist,'exact');
          case 'OGLALA LAKOTA'
            idx=strmatch('shannon',lowercountynamelist,'exact');
        case 'MCKEAN'
            idx=strmatch('mc kean',lowercountynamelist,'exact');
        case 'DE WITT'
            idx=strmatch('dewitt',lowercountynamelist,'exact');
        case 'CHESAPEAKE CITY'
            idx=strmatch('chesapeake',lowercountynamelist,'exact');
       case 'SUFFOLK CITY'
            idx=strmatch('suffolk',lowercountynamelist,'exact');
       case 'VIRGINIA BEACH CITY'
            idx=strmatch('virginia beach',lowercountynamelist,'exact');
        case 'ST CROIX'
            idx=strmatch('saint croix',lowercountynamelist,'exact');
        case 'MAUI & KALWAO'
            idx=strmatch('maui',lowercountynamelist,'exact');



            % case 'PRINCE GEORGES'
        case 'WASHABAUGH'
            g2fasthash=0;
            g2countyname='other';
            return
        case 'WASHINGTON'
            g2fasthash=0;
            g2countyname='other';
            return
        case {'NANSEMOND','ORMSBY'}
            g2fasthash=0;
            g2countyname='other';
            return
        otherwise
            NASSCounty
            keyboard
            g2fasthash=0;
            g2countyname='other';

return
    end
end

g2fasthash=g2state.gadm2codesfasthash(idx);
g2countyname=g2state.namelist2{idx};
