classdef sminstchan
    %sminstchan --  Structure that holds information on channels for inst.
    %   classes.
    
    properties
        name;       % Human readable name of channel
        setable=1;  % 1 if you can set this channel
        datadim=1;  % Dimension of this channel for setting/getting.
        datatype=1; % Type of this channel.  This should be a single value of the correct type.
        ramp=0;     % This should be "1" for rampable channels, "0" otherwise.
    end
    
    methods
        % Default constructor.
        function ic=sminstchan(name)
            if exist('name','var') 
                ic.name=name;
            end
        end
    end
end

