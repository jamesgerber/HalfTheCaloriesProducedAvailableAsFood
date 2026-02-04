function CDSstate=areaandyieldresponsestoCDS(areadata,yielddata)
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
    case 'BARLEY'
        ii=strmatch('BARLEY - ACRES HARVESTED',{x.short_desc});
    case 'OATS'
        ii=strmatch('OATS - ACRES HARVESTED',{x.short_desc});
    case 'COTTON'
        ii=strmatch('COTTON, UPLAND - ACRES HARVESTED',{x.short_desc});
    case 'PEANUTS'
        ii=strmatch('PEANUTS - ACRES HARVESTED',{x.short_desc});
   case 'SORGHUM'
        ii=strmatch('SORGHUM, GRAIN - ACRES HARVESTED',{x.short_desc});
    case 'SUNFLOWER'
        ii=strmatch('SUNFLOWER - ACRES HARVESTED',{x.short_desc});
        if isempty(ii)
            ii=strmatch('SUNFLOWER',{x.short_desc});
        end
    case 'POTATOES'
        ii=strmatch('POTATOES - ACRES HARVESTED',{x.short_desc});



    otherwise
        if numel(unique({x.short_desc}))==1
            ii=1:numel({x.short_desc});
        else
        unique({x.short_desc})
        keyboard
        end
end
x=x(ii);
areasov=vos2sov(x);


%% now get yield

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
        if isempty(ii)
        ii=strmatch('SUNFLOWER, OIL TYPE - YIELD, MEASURED IN LB / ACRE',{y.short_desc});
        end
        
    case 'POTATOES'
           ii=strmatch('POTATOES - YIELD, MEASURED IN CWT / ACRE',{y.short_desc});

        %
    otherwise
     if numel(unique({y.short_desc}))==1
         ii=1:numel({y.short_desc});
     else
         unique({y.short_desc})
         keyboard
     end
end
y=y(ii);
yieldsov=vos2sov(y);




%%% get county names, confirm yield and area have same list


countynameswithother=unique(areasov.county_name);
idx=strmatch('OTHER',countynameswithother);
idx=[];
areacountynames=countynameswithother(setdiff(1:numel(countynameswithother),idx));

countynameswithother=unique(yieldsov.county_name);
idx=strmatch('OTHER',countynameswithother);
idx=[];
yieldcountynames=countynameswithother(setdiff(1:numel(countynameswithother),idx));





if isequal(areacountynames,yieldcountynames)
    countynames=areacountynames;
else
    % incommensurate county names


    sadcounty=setxor(areacountynames,yieldcountynames);
    %setdiff(yieldcountynames,areacountynames)

    %warndlg(sadcounty)
    %idx=strmatch(sadcounty,yieldsov.county_name)
    %y(idx)
    %y(idx).Value
    countynames=intersect(areacountynames,yieldcountynames);
end


for jcounty=1:numel(countynames);
    clear CDS
    %jcounty=4;
    county=countynames{jcounty}

    % now subsets of x and y

    ii=strmatch(county,areasov.county_name,'exact');
    asov=vos2sov(x(ii));
    xcounty=x(ii);


    jj=strmatch(county,yieldsov.county_name,'exact');
    ysov=vos2sov(y(jj));
    ycounty=y(jj);




    % now make data vectors

    yrvect=intersect(unique(ysov.year),unique(asov.year));

    clear areaval yieldval
    for jyr=1:numel(yrvect)
        YYYY=yrvect(jyr);

        idxy=find(ysov.year==YYYY);
        idxa=find(asov.year==YYYY);

        if numel(idxy)==1 & numel(idxa)==1

            areaval(jyr)=str2num(strrep(asov.Value{idxa},',',''));
            yieldval(jyr)=str2num(strrep(ysov.Value{idxy},',',''));

        else
            if numel(idxy)>1
                if strmatch('OTHER',county)==1

                    % it's some 'other' shit ... just add them all together
                    clear aothervect yothervect
                    for j=1:numel(idxa)
                        aothervect(j)=str2num( strrep( asov.Value{idxa(j)},',',''));
                    end
                    for j=1:numel(idxy)
                        yothervect(j)=str2num( strrep( ysov.Value{idxy(j)},',',''));
                    end

                    if numel(aothervect)~=numel(yothervect);
                        ii=aothervect>0;
                        jj=yothervect>0;

                        if numel(find(ii))==numel(find(jj))
                            areaval(jyr)=sum(aothervect);
                            yieldval(jyr)=sum(aothervect(ii).*yothervect(jj))/sum(aothervect);

                        else
% ugly - but just take the mean of the yield values
                            areaval(jyr)=sum(aothervect);
                            yieldval(jyr)=mean(yothervect);

                        end

                    else

                        areaval(jyr)=sum(aothervect);
                        yieldval(jyr)=sum(aothervect.*yothervect)/sum(aothervect);
                    end
                else
                    ycounty(idxy(1))
                    ycounty(idxy(2))
                    xcounty(idxa(1))
                    xcounty(idxa(2))
                    
                    keyboard
                end


            end
            % ok ... both
        end
    end
    idx=find(yrvect==2000);
    area2000vect(jcounty)=sum(areaval(idx));

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