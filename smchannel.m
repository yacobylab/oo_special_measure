classdef smchannel
    %smchan --  Structure that holds information on channels for smdata    
    
    properties
        inst;       % Handle of instrument
        chan;       % Number of channel        
        name;       % Human readable name of channel, used for smget/smset
        rangeramp=[-inf inf inf 1];  % min, max, ramp rate (units/sec), divider factor
    end
    
    methods
        
        % Default constructor.
        function c=smchannel(name,inst,chan)
            if exist('name','var') 
                c.name=name;
            end
            if exist('inst','var')
                c.inst=inst;
            end
            if exist('chan','var')
                c.chan=chan;
            end
        end
    end
end

