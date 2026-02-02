function [IndirectCalfactor,TonsMeatVector, TonsFeedVector,RFVN]=CalculateIndirectCalories(ISO,YYYY,FractionFeedFromPasture);
% CalculateIndirectCalories - calculate indirect calories
%
% This code follows the

persistent PDsave YYYYsave

if ~isequal(YYYYsave,YYYY) | isempty(PDsave)
    YYYYsave=YYYY;
    PD=ReturnProductionData;
    PD=subsetofstructureofvectors(PD,PD.Year==YYYY);
    PD=subsetofstructureofvectors(PD,strmatch('t',PD.Unit));
    PDsave=PD;
else
    PD=PDsave;
end


if isequal(lower(ISO),'world')
    PD=subsetofstructureofvectors(PD,find(strcmp(PD.Area,'World')));
else
    CountryName= ISOtoFAOName(ISO);
    PDtmp=subsetofstructureofvectors(PD,find(strcmp(PD.Area,CountryName)));
    if isempty(PDtmp.Area_Code)
        disp(['Failed to pull out production data for ' ISO ' as ' CountryName ' using World'])
        PD=subsetofstructureofvectors(PD,find(strcmp(PD.Area,'World')));
    else
        PD=PDtmp;
    end
end

% from Table S6, Cassidy et al
TonsFeedtoCarcassWeight_Beef=21.17;
TonsFeedtoCarcassWeight_Pork=9.29;
TonsFeedtoCarcassWeight_Chicken=3.33;
TonsFeedtoCarcassWeight_Eggs=2.5;
TonsFeedtoCarcassWeight_Dairy=1.1;

%FractionFeedFromPasture=0.15;

cc_beef=0.0308;
cc_pork=0.1043;
cc_chicken=0.1178;
cc_eggs=0.2207;
cc_dairy=0.4025;


% cattle meat:
%P=subsetofstructureofvectors(PD,strmatch('Meat of cattle with the bone',PD.Item));
P=subsetofstructureofvectors(PD,find(strcmp('Meat of cattle with the bone, fresh or chilled',PD.Item)));
TonsCattleMeat=pullfromsov(P,'Value','Unit','t');
TonsCattleMeat(isnan(TonsCattleMeat))=0;

% pigs
%P=subsetofstructureofvectors(PD,strmatch('Meat of pig with the bone',PD.Item));
P=subsetofstructureofvectors(PD,find(strcmp('Meat of pig with the bone, fresh or chilled',PD.Item)));
TonsPigMeat=pullfromsov(P,'Value','Unit','t');
TonsPigMeat(isnan(TonsPigMeat))=0;

% poultry meat
%P=subsetofstructureofvectors(PD,strmatch('Meat, Poultry',PD.Item));
P=subsetofstructureofvectors(PD,find(strcmp('Meat, Poultry',PD.Item)));
TonsPoultry=pullfromsov(P,'Value','Unit','t');
TonsPoultry(isnan(TonsPoultry))=0;

% dairy
%P=subsetofstructureofvectors(PD,strmatch('Raw milk of cattle',PD.Item));
P=subsetofstructureofvectors(PD,find(strcmp('Raw milk of cattle',PD.Item)));
TonsMilk=pullfromsov(P,'Value','Unit','t');
TonsMilk(isnan(TonsMilk))=0;

% eggs
%P=subsetofstructureofvectors(PD,strmatch('Eggs Primary',PD.Item));
P=subsetofstructureofvectors(PD,find(strcmp('Eggs Primary',PD.Item)));
TonsEggs=pullfromsov(P,'Value','Unit','t');
TonsEggs(isnan(TonsEggs))=0;


TonsMeatVector=[TonsCattleMeat TonsPigMeat TonsPoultry TonsMilk TonsEggs];

TonsMeatVector(isnan(TonsMeatVector))=0;


RequiredFeedVector=...
    [TonsCattleMeat*TonsFeedtoCarcassWeight_Beef*(1-0.15) ...
    TonsPigMeat*TonsFeedtoCarcassWeight_Pork ...
    TonsPoultry*TonsFeedtoCarcassWeight_Chicken ...
    TonsEggs*TonsFeedtoCarcassWeight_Eggs ...
    TonsMilk*TonsFeedtoCarcassWeight_Dairy*(1-0.60) ...
];

TonsFeedVector=RequiredFeedVector;

FeedRequirementTons=sum(RequiredFeedVector);

RFVN=RequiredFeedVector/sum(RequiredFeedVector);


% now ... what is calorie conversion factor
IndirectCalfactor=sum(RFVN.*[cc_beef cc_pork cc_chicken cc_eggs cc_dairy])/sum(RFVN);



%%
if 0==1 % never execute, just for copy and paste
    % make a quick timeseries of how ICF has changed over time

    yrvect=2010:2022;
    for j=1:13;
        ICFvect(j)=CalculateIndirectCalories('WORLD',yrvect(j));
    end
end







