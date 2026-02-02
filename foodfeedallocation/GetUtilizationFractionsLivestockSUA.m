function [UF,Mflat,M,W,Mfields,Ufields,RFVNdom,RFVNworld]=GetUtilizationFractionsLivestockSUA(Country,RootCommodity,TradeCropName,YYYY,IgnoreTrade,ISO);
% GetUtilizationFractions - utilization fractions including exports
%
%
%  Syntax:  [UF,M,W,Mfields]=...
% GetUtilizationFractions(Country,FBSCommodity,TradeCropName,Year,IgnoreTrade);
%
%   M is a matrix ... first column is home country, next cols are
%   importers, rows are utilization
%   W is the tonnes to each country ... W(1)=Domestic Supply Quantity for
%   home, W(2:end) are tons send to each of those countries.  Since this is
%   export corrected, this serves as a weight
%   UF - is the weighted utilization across home and target countries
%
%
%  IgnoreTrade = 0 - ignore trade
%  IgnoreTrade = 1 - don't ignore trade
%  IgnoreTrade = 2 - treat all reported exports as being used as global
%  average
%
%
%
% high-level pseudo code:
% %
% % For each Crop/Country:
% %
% % Domestic Supply Quantity vs Exports in tons
% % DSQ has 6 components
% %
% % Each Exportee has EWi with 6 components.   Then weighted sum.
% %
% % So putting together a matrix with cols:
% % 'Weight'
% %    {'Feed'                    }
% %     {'Seed'                    }
% %     {'Processing'              }
% %     {'Other uses (non-food)'   }
% %     {'Residuals'               }
% %     {'Food'                    }
% %
% %     and rows: 'Domestic, Export 1, Export 2.'

if nargin<2
    % Testing syntax
    Country='United States of America'
    FBSCommodity='Barley'
end


if nargin<5
    IgnoreTrade=0;
end

if nargin<3
    TradeCropName=FBSCommodity;
end

persistent Livestock_conversions_7_3
if isempty(Livestock_conversions_7_3)
    load inputdata/Livestock_conversions_7_3.mat  % from Emily Cassidy.
end

persistent SUAyear saveyear SUAworld
if isempty(SUAyear) | ~isequal(saveyear,YYYY)
    SUA=ReturnSupplyUtilizationAccountsData;
    SUAyear=subsetofstructureofvectors(SUA,SUA.Year==YYYY);
    SUAworld=subsetofstructureofvectors(SUAyear,find(strcmp(SUAyear.Area,'World')));

    saveyear=YYYY;
end

%SUAa=subsetofstructureofvectors(SUAyear,strmatch(Country,SUAyear.Area,'exact'));
SUA=subsetofstructureofvectors(SUAyear,find(strcmp(Country,SUAyear.Area)));


% first the root commodity

%F=subsetofstructureofvectors(SUA,strmatch(RootCommodity,SUA.Item,'exact'));
F=subsetofstructureofvectors(SUA,find(strcmp(RootCommodity,SUA.Item)));


% Get Supply
Production=pullfromsov(F,'Value','Element','Production');
Exportquantity=pullfromsov(F,'Value','Element','Export quantity');
StockVariation=pullfromsov(F,'Value','Element','Stock Variation');
Importquantity=pullfromsov(F,'Value','Element','Import quantity');
Seed=pullfromsov(F,'Value','Element','Seed');
%M(1,1)= nansum([Production -1*Exportquantity -1*StockVariation ]); 
M(1,1)= nansum([Production -1*Seed ]); 
M(2,1)= pullfromsov(F,'Value','Element','Feed');
M(3,1)= Seed;
M(4,1)= pullfromsov(F,'Value','Element','Other uses (non-food)');
M(5,1)= pullfromsov(F,'Value','Element','Residuals');
M(6,1)= pullfromsov(F,'Value','Element','Food supply quantity (tonnes)');
M(7,1)= pullfromsov(F,'Value','Element','Processed');
M(8,1)= pullfromsov(F,'Value','Element','Tourist consumption');
M(9,1)= Exportquantity;
M(10,1)= Importquantity;
M(11,1)=0; % placeholder for indirect calories
M(12,1)=0; % placeholder for indirect calorie factor
M(13,1)= pullfromsov(F,'Value','Element','Loss');



%W(1,1)=nansum([Production -1*Exportquantity -1*StockVariation ]);
W(1,1)=nansum([Production -1*Exportquantity  ]);
Wname{1}=Country;

switch IgnoreTrade
    case 0
        error('uncool - should not call with IgnoreTrade==0');
    case 1
        error('uncool - should not call with IgnoreTrade==1');
    case 2
        SUA=SUAworld;
        % first the root commodity
       % F=subsetofstructureofvectors(SUA,strmatch(RootCommodity,SUA.Item,'exact'));
        F=subsetofstructureofvectors(SUA,find(strcmp(SUA.Item,RootCommodity)));

        ExportWeight=pullfromsov(F,'Value','Element','Export quantity');
        % sort of ignore trade, but for exports average
        ExportWeight(isnan(ExportWeight))=0;
        j=1;
        % Get Supply
        Production=pullfromsov(F,'Value','Element','Production');
        Exportquantity=pullfromsov(F,'Value','Element','Export quantity');
        StockVariation=pullfromsov(F,'Value','Element','Stock Variation');
        Importquantity=pullfromsov(F,'Value','Element','Import quantity');
%        M(1,j+1)= nansum([Production  -1*StockVariation ]);
        M(1,j+1)= nansum([Production  ]);
        M(2,j+1)= pullfromsov(F,'Value','Element','Feed');
        M(3,j+1)= pullfromsov(F,'Value','Element','Seed');
        M(4,j+1)= pullfromsov(F,'Value','Element','Other uses (non-food)');
        M(5,j+1)= pullfromsov(F,'Value','Element','Residuals');
        M(6,j+1)= pullfromsov(F,'Value','Element','Food supply quantity (tonnes)');
        M(7,j+1)= pullfromsov(F,'Value','Element','Processed');
        M(8,j+1)= pullfromsov(F,'Value','Element','Tourist consumption');
        M(9,j+1)= Exportquantity;
        M(10,j+1)= Importquantity;
        M(13,j+1)=0; pullfromsov(F,'Value','Element','Loss');
        W(1,1+j)=ExportWeight;
end

% Average utilization for this crop/country combination

M(isnan(M))=0;

% lose Residuals
M(5,1)=0;
M(5,2)=0;

switch IgnoreTrade
    case 2


        [ICF,~,~,RFVNdom]=CalculateIndirectCalories(ISO,YYYY);
        M(11,1)=M(2,1)*ICF;
        M(12,1)=ICF;

        [ICF,~,~,RFVNworld]=CalculateIndirectCalories('WORLD',YYYY);

        M(11,2)=M(2,2)*ICF;
        M(12,2)=ICF;

    otherwise
        error('  IgnoreTrade now hard-wired to 2.  Earlier versions of GetUtilizationFractions used it')
end

% don't change unless change hardwired construction of Udom and Uexp below.
Mfields={'Amount Commodity Available','Feed','Seed','Other uses (non-food)','Residuals','Food','Processing','Tourist consumption',...
    'Export Quantity','Import Quantity','Indirect Calories','Indirect Calorie Factor','Loss'};


% Let's construct U ... contains relative breakdown into 
%'Feed','Other uses (non-food)','Residuals','Food','Processing','Tourist consumption',...
%   'Indirect Calories'

Mraw=M;
M(isnan(M))=0;
Ufields=Mfields([2  4 5 6  8 11]);
Udom=M([2  4 5 6  8 11],1);
Uexp=M([2  4 5 6  8 11],2);
Udom=Udom/sum(Udom);
Uexp=Uexp/sum(Uexp);

Wdom=M(1,1);   % domestic amount available (not including imports, that woudl be double counting)
Wexp=M(9,1);   % exports

UF=(Udom*Wdom + Uexp*Wexp)/sum(Wdom+Wexp);

M=Mraw;

W=[Wdom Wexp];

Mflat=[];
