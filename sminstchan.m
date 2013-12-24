classdef sminstchan < hgsetget & matlab.mixin.Heterogeneous
    %sminstchan --  Structure that holds information on channels for inst. classes.
    
    properties
        name;       %human readable name
        parent=[];  % Parent instrument of this channel
        datadim=1;  % Dimension of this channel for setting/getting.
        datatype=1; % Type of this channel.  This should be a single value of the correct type.
        sethndl=@(o,v,r) error('This channel is not setable');     % Function for setting the channel
        gethndl=@(o)   error('This channel is not getable');     % Function for getting the channel
        val;        % Last set/get value of this channel (arb. type)        
        complete=1; % True if channel is done with it's set/get operation.
    end
    
    methods
        % Default constructor.
        function ic=sminstchan(parent,set,get)
            ic.parent=parent;
            if exist('set','var') && ~isempty(set)
              ic.sethndl=set;
            end
            if exist('get','var') && ~isempty(get)
              ic.gethndl=get;
            end
        end
        
        function set(ic, val, rate)
            if nargin > 2
                val=ic.sethndl(ic, val, rate);
            else
                val=ic.sethndl(ic,val,[]);
            end
        end
        
        function val=get(ic)
            val=ic.gethndl(ic);
        end                
        
        function finish(ic)  % Wait for last operation to complete.
            assert(ic.complete == 1);
            return;
        end
    end
end

