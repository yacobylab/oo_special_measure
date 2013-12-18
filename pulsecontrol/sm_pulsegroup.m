classdef sm_pulsegroup
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        pulses;
        params;
        varpar;
        chan;
        readout;
        dict;
        history;
        time;
        time_list;
    end
    
    methods
        function p = getinfo(pg,time)
            ind = find(pg.time_list<time,1,'first');
            if pg.history(ind).time<time && pg.history(ind+1).time > time
                p = pg.history(ind);
            else
                error('logging is messed up for pulsegroup %s',pg.name);
            end
        end
        
        function update(pg)
           pg.time = now;
           pg.time_list = [pg.time_list,pg.time];
           pg.history(end+1) = pg;
           pg.save();
        end
        
        function success = save(pg)
           success = save(pg.name,pg); 
        end
        
        function out = compare(pg,pg2)
           out = (pg.name == pg2.name && all(pg.pulses==pg2.pulses) && all(pg.chan==pg2.chan) && all(pg.readout == pg2.readout));
           for j = 1:length(pg.pulses)
              out= out && all(pg.varpar{j}==pg2.varpar{j}) && all(pg.params{j}==pg2.params{j});
              if ~out
                  break
              end
           end
        end
        
        function out = isstale(pg)
           out = compare(pg,pg.history(end)); 
        end
    end
    
end

