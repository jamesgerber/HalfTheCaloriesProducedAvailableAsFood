% script to call "Area and Yield Responses to CDS"
% that script works on a state by state basis
% here we will run through all states.


[nassCropNames,faoCropNames]=NASSCropNameList;


for jcropno=1:numel(nassCropNames);




    CDSvect=[];
    cropname=lower(faoCropNames{jcropno})
    a=dir(['APIoutputs/' cropname '/*.mat']);



    filenameCDS=['CDSfiles/CDSrawNASS' cropname '.mat'];

    if exist(filenameCDS)~=2
        disp(['processing ' filenameCDS])

        for j=1:numel(a);
            filename=a(j).name;



            x=load(['APIoutputs/' cropname '/' a(j).name], 'areadata','yielddata','retrievaltime','cropname','statename');

            CDSstate=areaandyieldresponsestoCDS(x.areadata,x.yielddata);
            c=numel(CDSvect)
            if c==0
                CDSvect=CDSstate;
            else
                CDSvect(end+1:(end+numel(CDSstate)))=CDSstate;
            end


        end




        save(filenameCDS,'CDSvect')
    else
        disp(['already have ' filenameCDS])
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
