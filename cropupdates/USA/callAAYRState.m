% script to call "Area and Yield Responses to CDS"
% that script works on a state by state basis
% here we will run through all states.


[nassCropNames,faoCropNames]=NASSCropNameList;

!rm APIoutputsState/sorghum/APIresponse_state_MINNESOTA.mat
!rm APIoutputsState/sorghum/APIresponse_state_WISCONSIN.mat
%!rm APIoutputsState/potato/APIresponse_state_ALABAMA.mat
%!rm APIoutputsState/potato/APIresponse_state_CALIFORNIA.mat


for jcropno=16:numel(nassCropNames);

    CDSvect=[];
    cropname=lower(faoCropNames{jcropno});
    a=dir(['APIoutputsState/' cropname '/*.mat']);


    outerfilename=['CDSfiles/CDSrawNASS' cropname '_State.mat'];

    if exist(outerfilename)~=2
        disp(['processing ' outerfilename])
        for j=1:numel(a);
            filename=a(j).name
            x=load(['APIoutputsState/' cropname '/' a(j).name], 'areadatastate','yielddatastate','retrievaltime','cropname','statename');
            CDSstate=areaandyieldresponsestoCDS_State(x.areadatastate,x.yielddatastate);
            c=numel(CDSvect);
            CDSstate.sharedlabels.state_name

            CDSstate.state_name=char(CDSstate.sharedlabels.state_name);
            if c==0
                CDSvect=CDSstate;
            else
                CDSvect(end+1:(end+numel(CDSstate)))=CDSstate;
            end


        end


        save(outerfilename,'CDSvect')
    else
        disp(['already have ' outerfilename])
    end


end






% % % first list of states
% % clear statelist
% %
% % for j=1:numel(arearesponse);
% %
% %     if ~isempty(arearesponse{j})
% %         statelist{j}=arearesponse{j}.data{1}.state_name;
% %     else
% %         statelist{j}='';
% %     end
% % end
% % CDSvect=[];
% % % now call aayr
% % for j=1:51
% %     if ~isempty(statelist{j})
% %         CDSstate=areaandyieldresponsestoCDS(arearesponse{j},yieldresponse{j});
% %         c=numel(CDSvect)
% %         if c==0
% %             CDSvect=CDSstate;
% %         else
% %             CDSvect(c:(c+numel(CDSstate)-1))=CDSstate;
% %         end
% %         %      a2000(j)=sum([CDSstate(end).area2000sum]);
% %     end
% % end
