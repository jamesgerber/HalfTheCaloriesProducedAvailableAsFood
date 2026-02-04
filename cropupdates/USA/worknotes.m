%  here are the codes:

makeInitialCallToAPI 
% this calls the API for all crops, gets a fairly large set of response
% data and saves to directory APIoutputs/CROPNAME    The outputs are saved
% individually, unless there is an error in the call to the API - this can
% be because, say, there is no sugarcane in Alaska, or because there was a
% timeout on the server side.  right now the only check I have that the
% data is good is to confirm that total sums match up at the national
% level.

callAAYR
% script to call areaandyieldresponsestoCDS, which turns 'arearesponse' and
% 'yieldrespone' (from makeInitialCallToAPI) into CDS files.
% when there is confusion, a lot of redundant data is saved into the CDS
% files - so they are quite big at this stage.





% workflow:

% may want to do this multiple times, since it will sometimes get a
% non-null result (null may have happened if server busy)
makeInitialCallToAPI
makeInitialCallToAPIstate



callAAYRState
callAAYR


ProcessRawCDS
