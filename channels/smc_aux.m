classdef smc_aux < sminst
    %smc_test is a generic instrument for returning handy stuff from MATLAB
     methods 
        function inst=smc_aux(name)
           type='Auxillary';
           if exist('name','var') && ~isempty('name')
             inst.name=name;
           else
             inst.name='Auxillary';
           end
           inst.channels=[sminstchan('Time')];
        end
        
        function open(inst)
        end
        
        function close(inst)
        end
        
        % "Generic" instrument operation functions. Please override
        % nb. -- the cntlfn structure will make instrument drivers hard to 
        % read.  Do we want to encourage such wanton behavior?  -- OD
        
        function status = arm(inst,chans)           
        end
        
        function status = trigger(inst, chans)
        end
        
        function [val rate] = set(inst,chan,val,rate)
        end
        
        function [val rate] = get(inst,chan,val,rate)
            switch(chan)
                case 1
                   val=now;     
            end
        end  
    end
    
end


