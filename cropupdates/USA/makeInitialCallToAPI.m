
% makeInitialCallToAPI
%
% This is an improved version of the codes that parse the API
% in particular, this separates out calling the API and getting all the
% data from parsing it.  Beneifts are cleaner code and perhaps more
% importnat sometimes the API call fails because server busy.

[nassCropNames,faoCropNames]=NASSCropNameList;


[g0,g1,g2,g3,g]=getgeo41;

% statenames
ii=strmatch('USA',g1.gadm0codes);
g1USA=subsetofstructureofvectors(g1,ii);
statenames=g1.namelist1(ii);



for jcropno=[20];%numel(faoCropNames)%numel(nassCropNames);

    cropname=lower(faoCropNames{jcropno})
    mkdir(['APIoutputs/' cropname]);

    crop=upper(nassCropNames{jcropno})
    tic
    for jstate=1:51
            STATE=upper(statenames{jstate});
            %  try
    %              if isequal(STATE,'FLORIDA')
  [arearesponse,yieldresponse]...
                =callAPI(STATE,crop);
            % end

            [arearesponsestate,yieldresponsestate]...
                =callAPIstate(STATE,crop);



            if numel(arearesponse)>0
                areadata=arearesponse;
                yielddata=yieldresponse;
                statename=arearesponse.data{1}.state_name
                retrievaltime=datestr(now);
                disp(['saving ' statename ' datafile ... '])
                save(['APIoutputs/' cropname '/APIresponse' statename], 'areadata','yielddata','retrievaltime','cropname','statename');
            end
        end
        disp('pausing so we don''t anger the NASS bandwidth gods')
        pause(20)
    end
%end

