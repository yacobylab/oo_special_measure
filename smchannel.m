classdef smchannel < hgsetget
    %smchan --  Structure that holds information on channels for smdata    
    
    properties 
        name;       % Name of this channel
        inst;       % Handle of instrument (string)
        channel;    % Number of channel    (string)
    end
    methods
        function smc=smchannel(name,inst,channel)
            smc.name = name;
            smc.inst = inst;
            smc.channel = channel;
        end
    end
end

