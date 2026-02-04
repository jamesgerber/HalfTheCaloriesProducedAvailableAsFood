function CCout=perturbwithinstate(CC,S);
% perturb the counties in CC to the counties in state




stateyears=unique(S.NASSdataRaw.year);
countyyears=unique(CC(1).NASSdataStateNormed.year);

overlapyears=intersect(stateyears,countyyears);


perturbyears=setdiff(stateyears,countyyears);

perturbextendyears=(max(countyyears)+1):max(stateyears);

% can only extend if there are state years
perturbextendyears=intersect(perturbextendyears,stateyears);

%fillinyears=

% don't perturb to before the first year of county data.
perturbyears=perturbyears(perturbyears>=min(countyyears));

% don't perturb to after the last year of county data
perturbyears=perturbyears(perturbyears<=max(countyyears));


% first construct a matrix whose rows are years and whose columns are
% counties
%

countyyearrange=countyyears(1):countyyears(end);

clear Ma My
Ma=nan(numel(countyyears),numel(CC));
My=nan(numel(countyyears),numel(CC));

for jyr=1:numel(countyyears)
    YYYY=countyyears(jyr);
    for m=1:numel(CC);
        C=CC(m);

        idx=find(C.NASSdataStateNormed.year==YYYY);
        if numel(idx)==1
            Ma(jyr,m)=C.NASSdataStateNormed.area(idx);
            My(jyr,m)=C.NASSdataStateNormed.yield(idx);
        end
    end
end
% so Ma is missing some years.  Linear interpolation to get those
% points.

% now do an interpolation get Ma on
for m=1:numel(CC);
    asparse=Ma(:,m);
        ysparse=My(:,m);

    if numel(countyyearrange)==1
        % extremely rare 
        afull=asparse;
        yfull=ysparse;
    else
        afull=interp1(countyyears,asparse,countyyearrange);
            yfull=interp1(countyyears,ysparse,countyyearrange);

    end
    Mafilledin(:,m)=afull;

  %  yfull=interp1(countyyears,ysparse,countyyearrange);
    Myfilledin(:,m)=yfull;
    % subplot(211)
    % plot(countyyears,asparse,'x',countyyearrange,afull,'o--')
    %
    % subplot(212)
    % plot(countyyears,ysparse,'x',countyyearrange,yfull,'o--')
    % Myfilledin(:,m)=yfull;
    % cf
    % pause

end

% first fill-in perturbation
for jyr=1:numel(perturbyears);
    YYYY=perturbyears(jyr);

    % what is state area ?
    idx=find(S.NASSdataRaw.year==YYYY);
    StateArea=S.NASSdataRaw.area(idx);
    StateYield=S.NASSdataRaw.yield(idx);

    % get vector from Mafilledin

    idx=find(countyyearrange==YYYY);  % this is index into Mafilledin

    avect=Mafilledin(idx,:);
    yvect=Myfilledin(idx,:);


    apertvect=avect*StateArea/sum(avect);
    ypertvect=yvect*StateYield/(sum(avect.*yvect)/sum(avect));

    for m=1:numel(CC)
        NASSPerturbeddata(m).year(jyr)=YYYY;
        NASSPerturbeddata(m).yield(jyr)=ypertvect(m);
        NASSPerturbeddata(m).area(jyr)=apertvect(m);
    end
end

% now extend perturbation

for jyr=1:numel(perturbextendyears);
    YYYY=perturbextendyears(jyr);

    % what is state area ?
    idx=find(S.NASSdataRaw.year==YYYY);
    StateArea=S.NASSdataRaw.area(idx);
    StateYield=S.NASSdataRaw.yield(idx);


    % get vector of the last several years of Ma
    N2=size(Ma,1);
    ii=max(N2-4,1):N2;

    avect=mean(Ma(ii,:),1);
    yvect=mean(My(ii,:),1);

    apertvect=avect*StateArea/sum(avect);
    ypertvect=yvect*StateYield/(sum(avect.*yvect)/sum(avect));


    for m=1:numel(CC)
        NASSPerturbeddata(m).year(jyr)=YYYY;
        NASSPerturbeddata(m).yield(jyr)=ypertvect(m);
        NASSPerturbeddata(m).area(jyr)=apertvect(m);
    end
end

if isempty(perturbyears) & isempty(perturbextendyears)
nulldata.year=[];
nulldata.area=[];
nulldata.yield=[];
    for m=1:numel(CC)
    
CC(m).NASSPerturbeddata=nulldata;
end
else

for m=1:numel(CC)
CC(m).NASSPerturbeddata=NASSPerturbeddata(m);
end
end

CCout=CC;
    
