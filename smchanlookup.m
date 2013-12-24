function [h] = smchanlookup(channels)
% function h = smchanlookup(channels);
% Convert channel names, smchannel objects, sminstchan objects, or channel
%   indices to sminstchan handles.

global smdata;

if isnumeric(channels)
    smc=smdata.channels(channels);
elseif isa(channels(1),'smchannel')
    smc=channels;
elseif isa(channels(1),'sminstchan')
    h=channels;
    return;
else
    if ischar(channels)
        channels = cellstr(channels);
    end
    assert(iscell(channels));
    for i = 1:length(channels)
        smc(i) = findobj(smdata.channels, 'name', channels{i});
    end
end    
for i=1:length(smc)
  h(i)=smdata.inst.(smc(i).inst).channels.(smc(i).channel);
end
