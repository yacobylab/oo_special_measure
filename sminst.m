classdef sminst < handle
    %sminst is a general instrument superclass for special measure
    %   The idea is that functions can be overloaded by instruments that
    %   inherit from sminst. 
    %    
    %   All functions could default to sminst.cntrlfn
    %     in an attempt to make things backward compatible. 
    
    properties
        inst;         % Handle for communicating with instrument, if applicable
        channels;     % Structure where each field is a channel.
        name;         % Name of *this particular* instrument
        device;         % Human readable type of this instrument, ie. "Agilent DMM"
    end
    
    methods       
        function open(inst)
           try
             fopen(inst.inst);
           catch err
             warning(sprintf('Error opening instrument %s (%s): %s',inst.name,inst.type,getReport(err))); 
           end
        end
        
        function close(inst)
           try
             fclose(inst.inst); 
           catch err
             warning(sprintf('Error closing instrument %s (%s): %s',inst.name,inst.type,getReport(err)));
           end
        end
        
        % "Generic" instrument operation functions. Please override        
        function status = arm(inst,chan)
            fprintf('Unhandled arm operation on %s (%s)\n',inst.name, inst.type);
            
        end
        
        function status = trigger(inst, chan)
            fprintf('Unhandled trigger operation on %s (%s)\n',inst.name, inst.type);
        end
    end    
end


