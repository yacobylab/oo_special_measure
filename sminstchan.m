classdef sminstchan < hgsetget & matlab.mixin.Heterogeneous
    %sminstchan --  Structure that holds information on channels for inst. classes.
    
    properties
        name;       %human readable name
        HWmin= -Inf;
        HWmax = Inf;
        HWoffset = 0;
        HWrate = Inf;
        HWdivider = 1;
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
            %allowing empty constructors makes nice default behavior:
            % it will let you say array(5) = sminstchan(some_arguments)
            % even if array(1:4) don't exist. 
            if ~exist('parent','var')
                parent = [];
                warning('no parent object given');
            end
            ic.parent=parent;
            if exist('set','var') && ~isempty(set)
              ic.sethndl=set;
            end
            if exist('get','var') && ~isempty(get)
              ic.gethndl=get;
            end
        end
        
        function val = set(ic, val, rate)
            val=min(val,ic.HWmax);
            val=max(val,ic.HWmin);
            val = val+ic.HWoffset;
            %could do a check if nargout ==0 and change behavior?
            if nargin > 2
                val = ic.sethndl(ic, val./ic.HWdivider, min(rate,ic.HWrate)/ic.HWdivider);
                %val=ic.sethndl(ic, val, min(rate,ic.HWrate));
            else
                val = ic.sethndl(ic, val./ic.HWdivider);
                %val=ic.sethndl(ic,val,[]);
            end
            ic.val = val;
        end
        
        function val=get(ic)
            val=ic.gethndl(ic)*ic.HWdivider;
            ic.val=val;
            %val=ic.gethndl(ic);
        end                
        
        function finish(ic)  % Wait for last operation to complete.
            assert(ic.complete == 1);
            return;
        end
    end
end

