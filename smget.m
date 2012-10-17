function data = smget(channels)
% data = smget(channels)
% 
% Get current values of channels.
% channels can be a cell or char array with channel names, or a vector
% with channel numbers.
% data is a cell vector of data arrays.

global smdata;

if(isempty(channels))
    data={};
    return
end

if ~isnumeric(channels)
    channels = smchanlookup(channels);
end

nchan = length(channels);
data = cell(1, nchan);

for i=1:length(channels)
    c=smdata.channels(channels(i));
    data{i}=c.inst.get(c.chan) / c.rangeramp(4);
    smdata.chanvals(channels(i)) = data{i}(1);
end

if ishandle(smdata.chandisph)
    smdata.smdispchan(channels,smdata.chanvals(channels));
end