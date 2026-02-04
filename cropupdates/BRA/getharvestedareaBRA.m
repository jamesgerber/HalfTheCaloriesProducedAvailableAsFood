function DCS=getharvestedareaBRA(YYYY);

if nargin==0
    help(mfilename)
    return
end


[g0,g1,g2,g3,g]=getgeo41;

ystr=int2str(YYYY);
a=readtable(['12_2023_downloads_ToJamie/' ystr '/harvested_tabela1612.xlsx']);
c=0;
fn=fieldnames(a);
for j=4:36;
    c=c+1;
    tmp=eval(['a.' fn{j} ';']);


% replace '-' with 0
% replace '...' with nan

idx=strmatch('-',tmp);
jdx=strmatch('...',tmp);

if iscell(tmp)
    for m=1:numel(idx);tmp{idx(m)}='0';end;
    for m=1:numel(jdx);tmp{jdx(m)}='NaN';end;
else

for m=1:numel(idx);tmp(idx(m))=0;end;
for m=1:numel(jdx);tmp(jdx(m))=NaN;end;

end

% % % Legenda	
% % % Símbolo	Significado
% % % -	"Zero absoluto, não resultante de um cálculo ou arredondamento.
% % % Ex: Em determinado município não existem pessoas de 14 anos de idade sem instrução."
% % % 0	"Zero resultante de um cálculo ou arredondamento.
% % % Ex: A inflação do feijão em determinada Região Metropolitana foi 0.
% % % Determinado município produziu 400 kg de sementes de girassol e os dados da tabela são expressos em toneladas."
% % % X	"Valor inibido para não identificar o informante.
% % % Ex: Determinado município só possui uma empresa produtora de cimento, logo o valor de sua produção deve ser inibido."
% % % ..	"Valor não se aplica.
% % % Ex: Não se pode obter o total da produção agrícola em determinado município quando os produtos agrícolas são contabilizados com unidades de medida distintas."
% % % ...	"Valor não disponível.
% % % Ex: A produção de feijão em determinado município não foi pesquisada ou determinado município não existia no ano da pesquisa."
% % % "A a Z
% % % (exceto X)"	"Significa uma faixa de valores. Varia em função da tabela (se for o caso).
% % % Ex: O nível de precisão da produção estimada de combustíveis está na faixa A (95 a 100%)"
    DCS(c).datacolumn=tmp(2:end-1);
    DCS(c).englishname='';;
    DCS(c).portuguesename=fn{j};
end

clear gadmlist

namelist=a.Var2(2:end-1);

%% parse namelist

nl=namelist;

for j=1:numel(nl);
    x=nl{j};
    idx=findstr(')',x);

    STlist{j}=x(idx-2:idx-1);
    N2list{j}=x(1:idx-5);
    N2list_noturds{j}=removeASCIIturds(x(1:idx-5));
    STlist_noturds{j}=removeASCIIturds(STlist{j});

end



%%
%limit to brasil

ii=strmatch('BRA',g2.gadm2codes);


%g2.namelist2{ii}

for j=1:numel(ii)
    g2statenames_noturds{j}=removeASCIIturds(g2.namelist1{ii(j)});
    g2statenames{j}=g2.namelist1{ii(j)};
    g2level2names_noturds{j}=removeASCIIturds(g2.namelist2{ii(j)});
    g2level2names{j}=g2.namelist2{ii(j)};
end


statelist=...
    {'AC,  Acre',...
    'AL,  Alagoas',...
    'AP,  Amapá',...
    'AM,  Amazonas',...
    'BA,  Bahia',...
    'CE,  Ceará',...
    'DF,  Distrito Federal',...
    'ES,  Espírito Santo',...
    'GO,  Goiás',...
    'MA,  Maranhão',...
    'MT,  Mato Grosso',...
    'MS,  Mato Grosso do Sul',...
    'MG,  Minas Gerais',...
    'PA,  Pará',...
    'PB,  Paraíba',...
    'PR,  Paraná',...
    'PE,  Pernambuco',...
    'PI,  Piauí',...
    'RJ,  Rio de Janeiro',...
    'RN,  Rio Grande do Norte',...
    'RS,  Rio Grande do Sul',...
    'RO,  Rondônia',...
    'RR,  Roraima',...
    'SC,  Santa Catarina',...
    'SP,  São Paulo',...
    'SE,  Sergipe',...
    'TO,  Tocantins'};

for j=1:numel(statelist);
    x=statelist{j};
    referenceST{j}=x(1:2);
    referenceStateName{j}=x(6:end);
    referenceStateName_noturds{j}=removeASCIIturds(x(6:end));
end

%%
%now ... for each element of ST, N2 vectors -
g2statenamelist=unique(g2.namelist1(ii));
% note to self:  success= matching each element of N2 vector with something
% in g2.namelist2
for j=1:numel(STlist);
    ST=STlist{j};
    thisN2_noturds=N2list_noturds{j};
    thisN2=N2list{j};
    idx=strmatch(ST,referenceST);
    if numel(idx)~=1
        keyboard
    end


    % first match state.  want to get idxState - which
    fullstatename_noturds=referenceStateName_noturds{idx};
    idxState=strmatch(fullstatename_noturds,g2statenames_noturds,'exact');

    if numel(unique(g2statenames(idxState)))~=1
        unique(g2statenames(idxState))
        keyboard

    end
    numel(unique(g2statenames(idxState)));
    %idxState=strmatch(fullstatename,g2statenames)


    %  idxState=strmatch(fullstatename_noturds,g2statenames_noturds)
    % remember ... idxState is an index into ii - which is brazil.

    g2municipionames_noturds=g2level2names_noturds(idxState);
    g2municipionames=g2level2names(idxState);

    idx=strmatch(thisN2_noturds,g2municipionames_noturds,'exact');

    if numel(idx)~=1


        idx2=strmatch(thisN2,g2municipionames,'exact');


        if numel(idx2)==1
            % we're good
        else
            thisN2;

            if isequal(thisN2_noturds,'Piraju')
                % some really strange character coupled with non-unique once remove turds

                if isequal(thisN2,'Pirajuí')
                    idx2=375;
                else
                    disp(' shouldn''t be able to get here since hte other will have been unique')
                    keyboard
                    
                end


            elseif isequal(thisN2_noturds,'Tapira')
                if isequal(thisN2,'Tapiraí')
                    idx2=780;
                else
                    idx2=779;
                end

            elseif isequal(thisN2_noturds,'Curu')
                if isequal(thisN2,'Curuá')
                    idx2=83;
                else
                    idx2=84;
                end


            else
                switch thisN2

                    case 'Santo Antônio de Leverger'
                        idx2=strmatch('Santo Antnio do Leverger',g2municipionames_noturds,'exact');

                    case 'Pirajuí'
                        keyboard
                    otherwise

                        keyboard
                end

            end
        end

        idx=idx2;


    end

    % ok, here we are.  We have matched.  Now can relate the row of the
    % .xls files from IBGE to gadm codes.  should be easy from here.

    %
    gadm2codes{j}=g2.gadm2codes{ii(idxState(idx))};
    gadm2codesfasthash(j)=g2.gadm2codesfasthash(ii(idxState(idx)));
    
end

for c=1:numel(DCS);
    DCS(c).gadm2codes=gadm2codes;
    DCS(c).gadm2codesfasthash=gadm2codesfasthash;
    DCS(c).N2list=N2list;
    DCS(c).STlist=STlist;

end
