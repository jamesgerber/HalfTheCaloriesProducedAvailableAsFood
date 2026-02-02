function out=detrendaveragemap(in,N);
% fit a linear curve, return value of curve at year N


out=ones(size(in(:,:,1)));
ii=find(out==1);

for j=1:size(in,3)
    tmp=in(:,:,j);
    y(:,j)=tmp(ii);
end

D=detrend(y.').';


yy=y(1688354,:);
% nigeria point:   4088978, 1688354
% ramsey 1006670
dd=detrend(yy);

lin=y-D;

best=lin(:,N);

best=max(best,min(y,[],2));
best=min(best,max(y,[],2));

out(ii)=best;
