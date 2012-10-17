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

dt = .01;  % We simulate sweeps with setchans.  This is the timestep to use.

if ~isnumeric(channels)
    channels = smchanlookup(channels);
end

nchan = length(channels);

if size(vals, 2) > 1
    vals = vals';
end

if length(vals) == 1
    vals = vals * ones(nchan, 1);
end


instchan = vertcat(smdata.channels(channels));
rangeramp = vertcat(instchan.rangeramp);


if nargin >= 3 %&& ~isempty(ramprate)
    if size(ramprate, 2) > 1
        ramprate = ramprate';
    end

    if length(ramprate) == 1
        ramprate = ramprate * ones(nchan, 1);
    end

    mask = isfinite(ramprate);
    if any(mask)
        rangeramp(mask, 3) = min(ramprate(mask), rangeramp(mask, 3));
    end
end

%limits & conversion factor
vals = max(min(vals, rangeramp(:, 2)), rangeramp(:, 1));

vals2 = vals .* rangeramp(:, 4);
rangeramp(:, 3) = rangeramp(:, 3) .* rangeramp(:, 4);

curr = zeros(nchan, 1);
chantype = zeros(nchan, 1);
ramptime = zeros(nchan, 1);

for i=1:nchan
  chantype(i)=instchan(i).inst.channels(instchan(i).chan).ramp;
end

% channels to ramp.  Notice that this can miss channels.
rampchan = find(isfinite(rangeramp(:, 3)) & chantype == 1);
stepchan = find(isfinite(rangeramp(:, 3)) & chantype == 0);

if any(rangeramp(stepchan, 3) < 0)
    error('Negative ramp rate for step channel.');
end
    
setchan = find(~isfinite(rangeramp(:, 3)));
% The union of rampchan, stepchan, and setchan is all the channels.

% get current val for step channels
for k = stepchan'   
    curr(k)=instchan(k).inst.get(instchan(k).chan);
end

% start ramps
for k = rampchan' 
    ramptime(k) = instchan(k).inst.set(instchan(k).chan, vals2(k), rangeramp(k, 3));
end

for k = setchan'    
    ramptime(k) = instchan(k).inst.set(instchan(k).chan, vals2(k));    
end

tramp = now;

if ishandle(smdata.chandisph)
    smdispchan(channels([rampchan; setchan]), vals([rampchan; setchan]));
end

% step channels
if ~isempty(stepchan)
    rangeramp(stepchan, 3) = dt * rangeramp(stepchan, 3) .* (2 * (vals2(stepchan) > curr(stepchan)) - 1);
    nstep = floor((vals2(stepchan)-curr(stepchan))./rangeramp(stepchan, 3));
    for l = 1:max(nstep)
        tstep = now;
        curr = curr + rangeramp(:, 3);        
        for k = stepchan(l <= nstep)';
            instchan(k).inst.set(instchan(k).chan,curr(k));
        end
        
        if ishandle(smdata.chandisph) && ~mod(l, 10)
            smdispchan(channels(stepchan(l <= nstep)), curr(stepchan(l <= nstep))...
                ./rangeramp(stepchan(l <= nstep), 4));
        end

        % wait
        while (now-tstep) > 0.005
            pause(0.005);
        end
        while (now - tstep) * 24 * 3600 < dt ;end
        
        if ishandle(1000) 
            c = get(1000, 'CurrentCharacter');
            if c == char(27)
                return;
            end
        end
    end
end

% set exact target value 
for k = stepchan'    
    instchan(k).inst.set(instchan(k).chan,vals2(k));
end
if ishandle(smdata.chandisph)
    smdispchan(channels(stepchan), vals(stepchan));
end

smdata.chanvals(channels) = vals;

rampchan = rampchan(rangeramp(rampchan, 3) > 0);
ramptime = ramptime(rampchan);
if ~isempty(rampchan)
    pause(max(ramptime) + 24*3600*(tramp - now));
    return; 
    [ramptime, ind] = sort(ramptime, 'descend');
    for k = rampchan(ind)'       
        t = Inf;
        while t > 0
            t = instchan(k).inst.set(instchan(k).chan,[], rangeramp(k, 3));
            pause(0.8 * t);
        end
    end
end

