
% makeInitialCallToAPI
%
% This is an improved version of the codes that parse the API
% in particular, this separates out calling the API and getting all the
% data from parsing it.  Beneifts are cleaner code and perhaps more
% importnat sometimes the API call fails because server busy.


[nassCropNames,faoCropNames]=NASSCropNameList;[g0,g1,g2,g3,g]=getgeo41;

% statenames
ii=strmatch('USA',g1.gadm0codes);
g1USA=subsetofstructureofvectors(g1,ii);
statenames=g1.namelist1(ii);



for jcropno=[ 11];%11:numel(faoCropNames)%numel(nassCropNames);

    cropname=lower(faoCropNames{jcropno})
    mkdir(['APIoutputsState/' cropname]);

    crop=upper(nassCropNames{jcropno})
    tic
    for jstate=1:51
        STATE=upper(statenames{jstate});
        statename=STATE;
        filename=['APIoutputsState/' cropname '/APIresponse_state_' statename '.mat'];



        if exist(filename)==2
            y=load(filename);
            if isempty(y.yielddatastate);
                CALLAPIFLAG=1;
            else
                CALLAPIFLAG=0;

            end
        else
            CALLAPIFLAG=1;
        end



        if CALLAPIFLAG==1
            [arearesponsestate,yieldresponsestate]...
                =callAPIstate(STATE,crop);



            if numel(arearesponsestate)>0

                % getstatename
                if numel(arearesponsestate.data)==1
                    statename=arearesponsestate.data(1).state_name;

                else
                    statename=arearesponsestate.data{1}.state_name;

                end


                areadatastate=arearesponsestate;
                yielddatastate=yieldresponsestate;
                retrievaltime=datestr(now);
                disp(['considering saving ' statename ' datafile ... '])

                % first see if there is already a file there, prepare to overwrite if
                % necessary


                if exist(filename)~=2
                    disp('first time through');
                    save(filename, 'areadatastate','yielddatastate','retrievaltime','cropname','statename');

                else
                    y=load(filename);

                    clear t
                    t.a1=areadatastate;
                    t.a2=yielddatastate;
                    t.a3=retrievaltime;
                    t.a4=cropname;
                    t.a5=statename;
                    existingfile=whos('y');
                    newfile=whos('t');

                    if newfile.bytes>existingfile.bytes
                        disp(['new file much bigger - presumably an API problem last time'])
                        save(['APIoutputsState/' cropname '/APIresponse_state_' statename], 'areadatastate','yielddatastate','retrievaltime','cropname','statename');
                    else
                        disp(['not resaving']);
                    end
                end
                disp('pausing for 20 seconds / keep API gods content')
                pause(5)
            end
        end
    end
end


