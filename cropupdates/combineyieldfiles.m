function y=combineyieldfiles(y1,y2)



iinew=(1:numel(y2.ITEM_CODE))+numel(y1.ITEM_CODE);
ynew=y1;
ynew.SAGEADMCDE(iinew)=y2.SAGEADMCDE;
ynew.ITEM_CODE(iinew)=y2.ITEM_CODE;
try
    ynew.YIELD(iinew)=y2.YIELD;
catch
        ynew.AREA(iinew)=y2.AREA;

end
y=ynew;
