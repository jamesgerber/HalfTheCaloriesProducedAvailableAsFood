function [arearesponse,yieldresponse]=callAPIstate(state,crop);


arearesponse='';
yieldresponse='';





api_key = 'E49DC5B5-B35D-38D6-A58B-E18751D3E7F0';

% NASS API base URL
base_url = 'https://quickstats.nass.usda.gov/api';

% Build the API request URL
url = [base_url '/api_GET'];


% let's get area harvested:
try
    response = webread(url, 'key', api_key, ...
        'unit_desc','ACRES', ...
        'statisticcat_desc', 'AREA HARVESTED', ...
        'source_desc', 'SURVEY', ...  % Assuming survey data
        'commodity_desc', crop, ...
        'state_name', state, ...  % Specify the state
        'reference_period_desc', 'YEAR', ...
        'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
        'format', 'JSON' ...  % Specify the desired format
        );
    arearesponse=response;


    response = webread(url, 'key', api_key, ...
        'source_desc', 'SURVEY', ...  % Assuming survey data
        'commodity_desc', crop, ...
        'state_name', state, ...  % Specify the state
        'reference_period_desc', 'YEAR', ...
        'agg_level_desc', 'STATE', ...  % You can adjust aggregation level based on your needs
        'format', 'JSON' ...  % Specify the desired format
        );

    yieldresponse=response;

    disp(['apparent success for state ' state])
catch
    disp(['error for state ' state])
end








