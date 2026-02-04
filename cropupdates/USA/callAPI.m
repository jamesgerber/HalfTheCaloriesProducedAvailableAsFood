function [arearesponse,yieldresponse]=callAPI(state,crop);


arearesponse='';
yieldresponse='';





api_key = 'E49DC5B5-B35D-38D6-A58B-E18751D3E7F0';

% NASS API base URL
base_url = 'https://quickstats.nass.usda.gov/api';

% Build the API request URL
url = [base_url '/api_GET'];


% let's get area harvested:
try
    switch crop
        case 'CORN'
            response = webread(url, 'key', api_key, ...
                'unit_desc','ACRES', ...
                'short_desc','CORN, GRAIN - ACRES HARVESTED', ...
                'statisticcat_desc', 'AREA HARVESTED', ...
                'source_desc', 'SURVEY', ...  % Assuming survey data
                'commodity_desc', crop, ...
                'state_name', state, ...  % Specify the state
                'reference_period_desc', 'YEAR', ...
                'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
                'format', 'JSON' ...  % Specify the desired format
                );
        otherwise
            response = webread(url, 'key', api_key, ...
                'unit_desc','ACRES', ...
                'statisticcat_desc', 'AREA HARVESTED', ...
                'source_desc', 'SURVEY', ...  % Assuming survey data
                'commodity_desc', crop, ...
                'state_name', state, ...  % Specify the state
                'reference_period_desc', 'YEAR', ...
                'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
                'format', 'JSON' ...  % Specify the desired format
                );

% here is some code useful for debugging if the above things don't work
            if 3==4
                arearesponse=response;

                clear x
                d=response.data;
                for j=1:numel(d);
                    x(j)=d{j};
                end

                areasov=vos2sov(x);
            end


    end

    disp(['apparent success for state ' state])
catch
    disp(['error for state ' state])
    AS=struct;
    YS=struct;
    return

end

arearesponse=response;








% let's get yield
switch crop

    case {'BARLEY','CORN','OATS','SORGHUM','SOYBEANS','WHEAT','RYE'}
        response = webread(url, 'key', api_key, ...
            'unit_desc','BU / ACRE', ...
            'source_desc', 'SURVEY', ...  % Assuming survey data
            'commodity_desc', crop, ...
            'state_name', state, ...  % Specify the state
            'reference_period_desc', 'YEAR', ...
            'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
            'format', 'JSON' ...  % Specify the desired format
            );
        % case {'RICE','COTTON','PEANUTS','SUNFLOWER','CANOLA'}
    case {'SUGARCANE','TOMATOES'}

        response = webread(url, 'key', api_key, ...
            'unit_desc','TONS / ACRE', ...
            'source_desc', 'SURVEY', ...  % Assuming survey data
            'commodity_desc', crop, ...
            'state_name', state, ...  % Specify the state
            'reference_period_desc', 'YEAR', ...
            'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
            'format', 'JSON' ...  % Specify the desired format
            );
    case {'POTATOES','SWEET POTATOES'}

        response = webread(url, 'key', api_key, ...
            'unit_desc','CWT / ACRE', ...
            'source_desc', 'SURVEY', ...  % Assuming survey data
            'commodity_desc', crop, ...
            'state_name', state, ...  % Specify the state
            'reference_period_desc', 'YEAR', ...
            'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
            'format', 'JSON' ...  % Specify the desired format
            );




    otherwise

        response = webread(url, 'key', api_key, ...
            'unit_desc','LB / ACRE', ...
            'source_desc', 'SURVEY', ...  % Assuming survey data
            'commodity_desc', crop, ...
            'state_name', state, ...  % Specify the state
            'reference_period_desc', 'YEAR', ...
            'agg_level_desc', 'COUNTY', ...  % You can adjust aggregation level based on your needs
            'format', 'JSON' ...  % Specify the desired format
            );
end

yieldresponse=response;





%%
response = webread(url, 'key', api_key, ...
    'reference_period_desc', 'YEAR', ...
    'year','2000', ...
    'agg_level_desc', 'NATIONAL', ...  % You can adjust aggregation level based on your needs
    'format', 'JSON' ...  % Specify the desired format
    );


