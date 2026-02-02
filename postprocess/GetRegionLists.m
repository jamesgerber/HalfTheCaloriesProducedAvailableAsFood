function [ISOGroupList,ISOGroupName]=GetRegionLists(ISOvect);

y = importUNRegionData("inputdata/UNSD — Methodology.xlsx", "Sheet1", [2, Inf]);


eu_iso3 = { ...
    'AUT', ...  % Austria
    'BEL', ...  % Belgium
    'BGR', ...  % Bulgaria
    'HRV', ...  % Croatia
    'CYP', ...  % Cyprus
    'CZE', ...  % Czech Republic
    'DNK', ...  % Denmark
    'EST', ...  % Estonia
    'FIN', ...  % Finland
    'FRA', ...  % France
    'DEU', ...  % Germany
    'GRC', ...  % Greece
    'HUN', ...  % Hungary
    'IRL', ...  % Ireland
    'ITA', ...  % Italy
    'LVA', ...  % Latvia
    'LTU', ...  % Lithuania
    'LUX', ...  % Luxembourg
    'MLT', ...  % Malta
    'NLD', ...  % Netherlands
    'POL', ...  % Poland
    'PRT', ...  % Portugal
    'ROU', ...  % Romania
    'SVK', ...  % Slovakia
    'SVN', ...  % Slovenia
    'ESP', ...  % Spain
    'SWE'  ...  % Sweden
};


RestOfWorld=setdiff(ISOvect,eu_iso3);
RestOfWorld=setdiff(RestOfWorld,'USA');
RestOfWorld=setdiff(RestOfWorld,'CHN');
RestOfWorld=setdiff(RestOfWorld,'IND');
RestOfWorld=setdiff(RestOfWorld,'BRA');
EntireWorld=ISOvect;
%%
ISOGroupList={{'USA'},{'CHN'},{'IND'},{'BRA'},eu_iso3,RestOfWorld,EntireWorld};
ISOGroupName={'USA','China','India','Brazil','EU27','Rest of World','Global'};

% now append other guys
subregioncodes=unique(y.SubregionCode);
subregioncodes=subregioncodes(isfinite(subregioncodes));

for j=1:numel(subregioncodes);
    sr=subregioncodes(j);

    idx=find(y.SubregionCode==sr);
    ISOList=y.ISOalpha3Code(idx);
    GroupName=char(y.SubregionName(idx(1)))
    ISOGroupList{end+1}=ISOList;
    ISOGroupName{end+1}=GroupName;
end