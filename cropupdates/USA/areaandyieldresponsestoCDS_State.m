function CDSstate=areaandyieldresponsestoCDS_State(areadata,yielddata)
% function areaandyieldresponsestoCDS derive CDS from output of NASS API
%
%
% i'm rewriting this little fuckface of a program to differentiate the API
% query step and the parse the outputs step.
%areaandyieldresponsestoCDS(arearesponse{8},yieldresponse{8})
c=0;
% first area

clear x
d=areadata.data;
for j=1:numel(d);
    x(j)=d{j};
end

% let's limit x and area to grain names
switch x(1).commodity_desc
    case 'CORN'
        ii=strmatch('CORN, GRAIN - ACRES HARVESTED',{x.short_desc});
    case 'WHEAT'
        ii=strmatch('WHEAT - ACRES HARVESTED',{x.short_desc});
    case 'SOYBEANS'
        ii=strmatch('SOYBEANS - ACRES HARVESTED',{x.short_desc});
    case 'RICE'
        ii=strmatch('RICE - ACRES HARVESTED',{x.short_desc});
    case 'BARLEY'
        ii=strmatch('BARLEY - ACRES HARVESTED',{x.short_desc});
    case 'OATS'
        ii=strmatch('OATS - ACRES HARVESTED',{x.short_desc});
    case 'COTTON'
        ii=strmatch('COTTON - ACRES HARVESTED',{x.short_desc});

    case 'PEANUTS'
        ii=strmatch('PEANUTS - ACRES HARVESTED',{x.short_desc});

    case 'SORGHUM'
        ii=strmatch('SORGHUM, GRAIN - ACRES HARVESTED',{x.short_desc});
    case 'SUNFLOWER'
        ii=strmatch('SUNFLOWER - ACRES HARVESTED',{x.short_desc});
    case 'POTATOES'
        ii=strmatch('POTATOES - ACRES HARVESTED',{x.short_desc});

    case 'SUGARCANE'
        ii=strmatch('SUGARCANE, SUGAR & SEED - ACRES HARVESTED',{x.short_desc});


   case 'TOMATOES'
        ii=strmatch('TOMATOES, IN THE OPEN - ACRES HARVESTED',{x.short_desc});

    otherwise
        if numel(unique({x.short_desc}))==1
            ii=1:numel({x.short_desc});
        else

            unique({x.short_desc})'
            keyboard
        end
end
x=x(ii);
areasov=vos2sov(x);


%% now get yield
x(1).commodity_desc
x(1).state_name
clear y
d=yielddata.data;
for j=1:numel(d);
    y(j)=d{j};
end


% let's limit x and area to grain names

switch y(1).commodity_desc
    case 'CORN'
        ii=strmatch('CORN, GRAIN - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case 'WHEAT'
        ii=strmatch('WHEAT - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case {'SOYBEANS'}
        ii=strmatch('SOYBEANS - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case {'RICE'}
        ii=strmatch('RICE - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
    case {'BARLEY'}
        ii=strmatch('BARLEY - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case {'OATS'}
        ii=strmatch('OATS - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case {'COTTON'}
        ii=strmatch('COTTON, UPLAND - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
    case {'PEANUTS'}
        ii=strmatch('PEANUTS - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
    case {'SORGHUM'}
        ii=strmatch('SORGHUM, GRAIN - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case 'SUNFLOWER'
        ii=strmatch('SUNFLOWER - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
    case 'CANOLA'
        ii=strmatch('CANOLA - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
    case 'MILLET'
        ii=strmatch('MILLET, PROSO - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case 'POTATOES'
        ii=strmatch('POTATOES - YIELD, MEASURED IN CWT / ACRE',{y.short_desc});
    case 'RYE'
        ii=strmatch('RYE - YIELD, MEASURED IN BU / ACRE',{y.short_desc});
    case 'SUGARCANE'
        ii=strmatch('SUGARCANE, SUGAR & SEED - ACRES HARVESTED',{y.short_desc});

    
    case {'placeholder'}
        ii=1:numel(y);
        %
    otherwise

        % ok - i'm tired of filling the above case statement.  if there is a single
        % 'YIELD' that's what we want.


        % look for single yield
        crop=y(1).commodity_desc;
        shorties=unique({y.short_desc});
        cc=0;
        for j=1:numel(shorties);
            idx=findstr('YIELD',char(shorties{j}));
            if numel(idx)==1
                cc=cc+1;
                short_desc=char(shorties{j});
            end
        end
        if cc==1
            ii=strmatch(short_desc,{y.short_desc});
        elseif numel(unique({y.short_desc}))==1
            ii=1:numel({y.short_desc});
        else
            y(1).commodity_desc
            unique({y.short_desc})'
            keyboard
        end
end
y=y(ii);
yieldsov=vos2sov(y);




%%% get county names, confirm yield and area have same list
ysov=yieldsov;
asov=areasov;






% now make data vectors

yrvect=intersect(unique(ysov.year),unique(asov.year));

clear areaval yieldval
for jyr=1:numel(yrvect)
    YYYY=yrvect(jyr);

    idxy=find(ysov.year==YYYY);
    idxa=find(asov.year==YYYY);

    if numel(idxy)==1 & numel(idxa)==1

        try
            areaval(jyr)=str2num(strrep(asov.Value{idxa},',',''));
            yieldval(jyr)=str2num(strrep(ysov.Value{idxy},',',''));
        catch
            % what seems to be a very rare case where there is a flag
            disp([' strange value: asov.Value ' char(asov.Value{idxa})])
            disp([' strange value: ysov.Value ' char(ysov.Value{idxy})])
            areaval(jyr)=0;
            yieldval(jyr)=0;

        end

    else
        keyboard
        % ok ... both
    end
end

CDS.NASSdataRaw.area=areaval;
CDS.NASSdataRaw.yield=yieldval;
CDS.NASSdataRaw.year=yrvect;
% add all unique fields from asov
fn=fieldnames(asov);

fn=setdiff(fn,'Value');
fn=setdiff(fn,'year');
%fn=setdiff(fn,'load_time');
%fn=setdiff(fn,'asd_code');
CDS.didnotparse=struct;
for j=1:numel(fn)
    fieldname=fn{j};
    yvals=unique(ysov.(fieldname));
    avals=unique(asov.(fieldname));

    % easy case
    if isequal(yvals,avals) & numel(yvals)==1
        CDS.sharedlabels.(fieldname)=avals;
    elseif numel(yvals)==1 & numel(avals)==1
        CDS.yieldlabels.(fieldname)=yvals;
        CDS.arealabels.(fieldname)=avals;
    else
        CDS.didnotparse.ysov=ysov;
        CDS.didnotparse.asov=asov;
        % if we are here, need to add dummy fields
        CDS.sharedlabels.(fieldname)='';
    end
end
c=c+1;
CDSstate(c)=CDS;
end

%end