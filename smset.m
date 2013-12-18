function smset(channels, vals, ramprate)
% smset(channels, vals, ramprate)
%
% Set channels to vals.
% channels can be a cell or char array with channel names, or a vector
% with channel numbers.
% vals is a vector with one element for each channel.
% ramprate is used instead of instrument default if given, finite,     
% and smaller than default. A negative ramprate prevents
% waiting for ramping to finish for self ramping channels (type = 1).
% (This faeature is mainly used by smrun).

global smdata;

if isempty(channels)
    return
end

channels = smchanlookup(channels);
nchan = length(channels);

if isnumeric(vals)
    if length(vals) == 1  %% Work around half-assed deprecation in MATLAB
      vals={vals};
    else
      vals=num2cell(vals);
    end
end
if length(vals) == 1 && nchan > 1
    vals = num2cell(vals{1} * ones(1,nchan));
end
   
if exist('ramprate','var') && ~isempty(ramprate) 
   if length(ramprate)==1
      ramprate = ramprate*ones(nchan,q); 
   end
   for k=1:nchan
     channels(k).set(vals{k},ramprate(k));
     channels(k).val = vals{k};
   end
else
   for k=1:nchan
     channels(k).set(vals{k});
     channels(k).val = vals{k};
   end
end

% Wait for any ramps to finish.
for k=1:nchan
    channels(k).finish();
end

if ishandle(smdata.chandisph)
    smdispchan(channels, vals);
end
