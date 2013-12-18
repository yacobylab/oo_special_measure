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

h = smchanlookup(channels);
nchan = length(h);
data = cell(1, nchan);

for i=1:length(h)    
    data{i}=h(i).get();
    h(i).val = data{i};    
end

if ishandle(smdata.chandisph)
    smdata.smdispchan(channels,smdata.chanvals(channels));
end