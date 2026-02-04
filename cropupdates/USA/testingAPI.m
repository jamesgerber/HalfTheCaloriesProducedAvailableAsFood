% Replace 'YOUR_API_KEY' with your actual NASS API key
api_key = 'E49DC5B5-B35D-38D6-A58B-E18751D3E7F0';

% NASS API base URL
base_url = 'https://quickstats.nass.usda.gov/api';

% % Specify request parameters
% params = struct(...
%     'key', api_key, ...
%     'source_desc', 'SURVEY', ...  % Assuming survey data
%     'commodity_desc', 'OATS', ...
%     'year', '2015', ...  % Specify the year you are interested in
%     'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
%     'format', 'JSON' ...  % Specify the desired format
% );

% Build the API request URL
url = [base_url '/api_GET'];

% Make the GET request
%response = webread(url, params);

response = webread(url, 'key', api_key, ...
    'source_desc', 'SURVEY', ...  % Assuming survey data
    'commodity_desc', 'CORN', ...
    'reference_period_desc', 'YEAR', ...
    'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
  'year', '2015', ...  % Specify the year you are interested in
    'format', 'JSON' ...  % Specify the desired format
);
%    'year', '2000', ...  % Specify the year you are interested in
clear x y
d=response.data;
for j=1:numel(d);
    x(j)=d{j};
end

y=vos2sov(x);
%%
% let's keep refining

% 
response = webread(url, 'key', api_key, ...
    'unit_desc','ACRES', ...
    'source_desc', 'SURVEY', ...  % Assuming survey data
    'commodity_desc', 'CORN', ...
    'state_name', 'MINNESOTA', ...  % Specify the state
    'reference_period_desc', 'YEAR', ...
    'year', '2000', ...  % Specify the year you are interested in
    'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
    'format', 'JSON' ...  % Specify the desired format
);

clear x
d=response.data;
for j=1:numel(d);
    x(j)=d{j};
end

y=vos2sov(x);


% let's get area harvested:

response = webread(url, 'key', api_key, ...
    'unit_desc','ACRES', ...
    'statisticcat_desc', 'AREA HARVESTED', ...
    'source_desc', 'SURVEY', ...  % Assuming survey data
    'commodity_desc', 'CORN', ...
    'state_name', 'MINNESOTA', ...  % Specify the state
    'reference_period_desc', 'YEAR', ...
    'year', '2015', ...  % Specify the year you are interested in
    'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
    'format', 'JSON' ...  % Specify the desired format
);

clear x
d=response.data;
for j=1:numel(d);
    x(j)=d{j};
end

y=vos2sov(x);


% let's get yield

response = webread(url, 'key', api_key, ...
    'unit_desc','BU / ACRE', ...
    'source_desc', 'SURVEY', ...  % Assuming survey data
    'commodity_desc', 'CORN', ...
    'state_name', 'MINNESOTA', ...  % Specify the state
    'reference_period_desc', 'YEAR', ...
    'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
    'format', 'JSON' ...  % Specify the desired format
);




% Display the response

% now make a csv of 


response = webread(url, 'key', api_key, ...
    'source_desc', 'SURVEY', ...  % Assuming survey data
    'commodity_desc', 'CORN', ...
    'reference_period_desc', 'YEAR', ...
    'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
    'year', '2000', ...  % Specify the year you are interested in
    'format', 'JSON' ...  % Specify the desired format
    );
%    'year', '2000', ...  % Specify the year you are interested in
clear x y
d=response.data;
for j=1:numel(d);
    x(j)=d{j};
end

y=vos2sov(x);

statelist=unique({x.state_name});

for jstate=1:numel(statelist);
    state=statelist{jstate};
    
    
    ii=strmatch(state,y.state_name);
    
       jj=strmatch('CORN, GRAIN - ACRES HARVESTED',y.short_desc)
    %jj=strmatch('AREA HARVESTED',y.statisticcat_desc)
    
    kk=intersect(ii,jj);
    if numel(kk)==1
        HarvestedAreaAcres(jstate)=str2num(strrep(x(kk).Value,',',''));
    end
end


    

