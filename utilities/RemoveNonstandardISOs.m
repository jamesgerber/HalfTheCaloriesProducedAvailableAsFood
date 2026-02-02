function     ISOlist=RemoveWeirdoGuys(ISOlist);
%     ISOlist=RemoveWeirdoGuys(ISOlist);

    % ISOlist=setdiff(ISOlist,'XKO');
    % ISOlist=setdiff(ISOlist,'NCL');
    % ISOlist=setdiff(ISOlist,'TWN');
    % ISOlist=setdiff(ISOlist,'GUF');
    % ISOlist=setdiff(ISOlist,'GLP');
    % ISOlist=setdiff(ISOlist,'MTQ');
    % ISOlist=setdiff(ISOlist,'PRI');
    % ISOlist=setdiff(ISOlist,'REU');
    % ISOlist=setdiff(ISOlist,'CYM');
    % ISOlist=setdiff(ISOlist,'GUM');
    % ISOlist=setdiff(ISOlist,'MSR');

[g0,g1,g2,g3,g]=getgeo41;
for j=1:263
    try
        ISOtoFAOName(g0.gadm0codes{j});
    catch
        ISOlist=setdiff(ISOlist,g0.gadm0codes{j});
    end
end