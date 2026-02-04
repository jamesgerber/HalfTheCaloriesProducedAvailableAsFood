function CCnewvect=ProjectOntoGADMUnits(CC,sagegeo,gadmgeo,area,yield,DQa,DQy);
%
% make consistent with GADM units if possible.


adminlevel=[CC.AdminLevel];

if numel(unique(adminlevel))~=1
    disp(['multiple admin levels,  clean enough for reprojection']);
    
    for j=1:numel(CC);
        NumIndices(j)=numel(CC(j).indices);
        AL(j)=CC(j).AdminLevel;
    end
    
    finaladminlevel=mode(adminlevel);

else
        finaladminlevel=unique(adminlevel);
end

% overrides for a few countries
switch CC(1).GADM3
    case 'BGR'
        finaladminlevel=1;
    case 'CAN'
        finaladminlevel=1;
    case {'CZE','ECU','ESP','FIN','IRL','IRN','KOR','MNE',...
            'MNG','NLD','NOR','NZL','PRT','ROU','RUS',...
            'SAU','SWE','TUR','ZAF','LKA','NGA','PRY','THA','VEN','VNM'}
        finaladminlevel=1;
        
    case {'AUS','DEU','FRA','GBR','GRC','MEX'}
        finaladminlevel=2;
        
        
        
end

% single set of admin levels

switch finaladminlevel
    case 2
        % pull yield and area out of the original monfreda maps
        
        GADM3=CC(1).GADM3;
        
        idx=strmatch(GADM3,gadmgeo.gadmgeo2.gadm2codes);
        
        for j=1:numel(idx);
            
            code=gadmgeo.gadmgeo2.uniqueadminunitcode2(idx(j));
            indicesGADM=find(gadmgeo.gadmgeo2.raster2==code);
            
            CCnew.indicesGADM=indicesGADM;
            CCnew.numindices=numel(indicesGADM);
            CCnew.AdminLevel=2;
            CCnew.SAGE3=CC(1).SAGE3;
            CCnew.M3YieldVector=yield(indicesGADM);
            CCnew.M3AreaVector=area(indicesGADM);
            CCnew.M3DQYVector=DQa(indicesGADM);
            CCnew.M3DQAVector=DQy(indicesGADM);
            CCnew.cropname=CC(1).cropname;
            CCnew.GADM3=GADM3;
            CCnew.GADMNameCode=gadmgeo.gadmgeo2.namecodes2{idx(j)};
            CCnew.GADMCode=gadmgeo.gadmgeo2.gadm2codes{idx(j)};
            CCnew.GADMRasterIndex=gadmgeo.gadmgeo2.uniqueadminunitcode2(idx(j));
            CCnew.YieldDataTypeFlag=CC(1).YieldDataTypeFlag;
            
            
            aa=area(indicesGADM);
            yy=yield(indicesGADM);
            fm=fma(indicesGADM);
            
            ii=isfinite(aa.*yy.*fm);
            
            psum=sum(aa(ii).*yy(ii).*fm(ii));
            asum=sum(aa(ii).*fm(ii));
            yavg=psum./asum;
            
            CCnew.M3yield=yavg;
            CCnew.M3area=asum;
            CCnew.M3production=psum;
            
            CCnewvect(j)=CCnew;
        end
        
        % can get rid of some of these
        
        % get rid of anything with zero indices
        
%         iikeep=[CCnewvect.numindices]>0;
%         CCnewvect=CCnewvect(iikeep);
%         
%         iinoproduction=([CCnewvect.M3production]==0 | isempty([CCnewvect.M3production]) ...
%             | isnan([CCnewvect.M3production])) ;
%         
%         iilose=[CCnewvect.numindices]<5 &  iinoproduction;
%         CCnewvect=CCnewvect(~iilose);
        
    case 1
        
        GADM3=CC(1).GADM3;
        
        idx=strmatch(GADM3,gadmgeo.gadmgeo1.gadm1codes);
        
        for j=1:numel(idx);
            
            code=gadmgeo.gadmgeo1.uniqueadminunitcode1(idx(j));
            indicesGADM=find(gadmgeo.gadmgeo1.raster1==code);
            
            CCnew.indicesGADM=indicesGADM;
            CCnew.numindices=numel(indicesGADM);
            CCnew.AdminLevel=1;
            CCnew.SAGE3=CC(1).SAGE3;
            CCnew.M3YieldVector=yield(indicesGADM);
            CCnew.M3AreaVector=area(indicesGADM);
            CCnew.M3DQYVector=DQa(indicesGADM);
            CCnew.M3DQAVector=DQy(indicesGADM);
            CCnew.cropname=CC(1).cropname;
            CCnew.GADM3=GADM3;
            CCnew.GADMNameCode=gadmgeo.gadmgeo1.namecodes1{idx(j)};
            CCnew.GADMCode=gadmgeo.gadmgeo1.gadm1codes{idx(j)};
            CCnew.GADMRasterIndex=gadmgeo.gadmgeo1.uniqueadminunitcode1(idx(j));
                        CCnew.YieldDataTypeFlag=CC(1).YieldDataTypeFlag;

            aa=area(indicesGADM);
            yy=yield(indicesGADM);
            fm=fma(indicesGADM);
            
            ii=isfinite(aa.*yy.*fm);
            
            psum=sum(aa(ii).*yy(ii).*fm(ii));
            asum=sum(aa(ii).*fm(ii));
            yavg=psum./asum;
            
            CCnew.M3yield=yavg;
            CCnew.M3area=asum;
            CCnew.M3production=psum;
            
            CCnewvect(j)=CCnew;
        end
        
        % can get rid of some of these
        
        % get rid of anything with zero indices
        
%         iikeep=[CCnewvect.numindices]>0;
%         CCnewvect=CCnewvect(iikeep);
%         
%         iinoproduction=([CCnewvect.M3production]==0 | isempty([CCnewvect.M3production]) ...
%             | isnan([CCnewvect.M3production])) ;
%         
%         iilose=[CCnewvect.numindices]<5 &  iinoproduction;
%         CCnewvect=CCnewvect(~iilose);
        
    case 0
        GADM3=CC(1).GADM3;
        
        idx=strmatch(GADM3,gadmgeo.gadmgeo0.gadm0codes);
        if numel(idx)~=1
            keyboard
        end
        for j=1:numel(idx);
            
            code=gadmgeo.gadmgeo0.uniqueadminunitcode0(idx(j));
            indicesGADM=find(gadmgeo.gadmgeo0.raster0==code);
            
            CCnew.indicesGADM=indicesGADM;
            CCnew.numindices=numel(indicesGADM);
            CCnew.AdminLevel=0;
            CCnew.SAGE3=CC(1).SAGE3;
            CCnew.M3YieldVector=yield(indicesGADM);
            CCnew.M3AreaVector=area(indicesGADM);
            CCnew.M3DQYVector=DQa(indicesGADM);
            CCnew.M3DQAVector=DQy(indicesGADM);
            CCnew.cropname=CC(1).cropname;
            CCnew.GADM3=GADM3;
            CCnew.GADMNameCode=gadmgeo.gadmgeo0.namelist0{idx(j)};
            CCnew.GADMCode=gadmgeo.gadmgeo0.gadm0codes{idx(j)};
            CCnew.GADMRasterIndex=gadmgeo.gadmgeo0.uniqueadminunitcode0(idx(j));
                        CCnew.YieldDataTypeFlag=CC(1).YieldDataTypeFlag;

            aa=area(indicesGADM);
            yy=yield(indicesGADM);
            fm=fma(indicesGADM);
            
            ii=isfinite(aa.*yy.*fm);
            
            psum=sum(aa(ii).*yy(ii).*fm(ii));
            asum=sum(aa(ii).*fm(ii));
            yavg=psum./asum;
            
            CCnew.M3yield=yavg;
            CCnew.M3area=asum;
            CCnew.M3production=psum;
            
            CCnewvect(j)=CCnew;
        end
        
        % can get rid of some of these
        
        % get rid of anything with zero indices
        
        iikeep=[CCnewvect.numindices]>0;
        CCnewvect=CCnewvect(iikeep);
        
        iinoproduction=([CCnewvect.M3production]==0 | isempty([CCnewvect.M3production]) ...
            | isnan([CCnewvect.M3production])) ;
        
        iilose=[CCnewvect.numindices]<5 &  iinoproduction;
        CCnewvect=CCnewvect(~iilose);
        
    otherwise
        keyboard
        
end
3



