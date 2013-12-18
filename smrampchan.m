classdef smrampchan < sminstchan
    %smrampchan --  Structure that holds information on rampable channels.
    
    properties
        minmax=[-inf inf];   % Minimum/maximum value this channel can take on.
        ramprate=inf;        % Ramprate. (maximum ramprate)
        divider=1;           % Divider for channel values.
        donehndl=@(o) 0;         % For hardware rampable channels, this should be a function that returns eta to completion.
    end
    
    methods
        % Default constructor.
        function ic=smrampchan(parent,set,get)
            ic=ic@sminstchan(parent,set,get);
        end
        
        % Set to val at rate rate.
        function set(ic, val, rate)
            val=min(val,minmax(2));
            val=max(val,minmax(1));
            if nargin > 2
                ic.sethndl(ic, val./divider, min(rate,ramprate)/divider);
                ic.val=val;
            else
                ic.sethndl(ic,val./divider,ramprate/divider);
            end            
        end
        
        % Get current val.
        function val=get(ic)
            val=ic.gethndl(ic)*divider;
            ic.val=val;
        end
        
        % Return how much time the ramp has left.
        function val=timeleft(ic)
            val = ic.donehndl(ic);
        end
        
        % Block execution until the ramp finishes.
        function finish(ic)
            while ~ic.complete                
                pause(min(ic.timeleft, 0.001));
            end
        end                
    end
end

