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
           inst.channels=sminstchan(name);
           inst.data=zeros(size(inst.channels));
        end
        
        function open(inst)
        end
        
        function close(inst)
        end
                               
        function status = arm(inst,chans)           
        end
        
        function status = trigger(inst, chans)
        end
        
        function [val rate] = set(inst,chans,val,rate)
            inst.data(chans)=val;           
            if inst.debug
                fprintf('Setting %s to %g\n',inst.channels(chans).name,val);
            end
        end
        
        function [val rate] = get(inst,chans)
            val=inst.data(chans);           
            if inst.debug
                fprintf('Reading %s as %g\n',inst.channels(chans).name,val);
            end
        end  
    end
    
end


