classdef smc_test < sminst
    %smc_test is a test instrument.  Setting the channel sets and internal
    %  buffer.  getting the channel returns the last set.
    properties
        data=[];             % Data values.        
    end
    
    properties (Constant=true)
        debug=0;  % Set to 1 to emitt debugging messages
    end
    
    methods 
        function inst=smc_test(name)
           type='Test';
           if exist('name','var') && ~isempty('name')
             inst.name=name;
           else
             inst.name='Test';
           end
           inst.channels.test=sminstchan(inst, @(o,v,r) o.parent.set(v,r), @(o) o.parent.get());
           inst.channels.ramp_test=smstepchan(inst, @(o,v,r) o.parent.set(v,r), @(o) o.parent.get());
           inst.data=0;
        end
        
        function open(inst)
        end
        
        function close(inst)
        end
                               
        function status = arm(inst,chans)           
        end
        
        function status = trigger(inst, chans)
        end
        
        function [val rate] = set(o,val,rate)
            o.data=val;
            if o.debug
                fprintf('Setting %s to %g\n',o.name,val);
            end
        end
        
        function [val rate] = get(o)
            val=o.data;
            if o.debug
                fprintf('Reading %s as %g\n',o.name,val);
            end
        end  
    end
    
end


