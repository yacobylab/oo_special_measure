classdef sminst < handle
    %sminst is a general instrument superclass for special measure
    %   The idea is that functions can be overloaded by instruments that
    %   inherit from sminst. 
    %    
    %   All functions could default to sminst.cntrlfn
    %     in an attempt to make things backward compatible. 
    
    properties
        inst;         % Handle for communicating with instrument, if applicable
        channels;     % Channel array of sminstchans.
        name;         % Name of *this particular* instrument
        type;         % Human readable type of this instrument, ie. "Agilent DMM"
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
        
        % If rate is empty, set the channel at default rate.
        % If val is empty but rate is not, return how long the sweep should
        % take.
        function [val rate] = set(inst,chan,val,rate)
           fprintf('Unhandled set operation on %s (%s)\n',inst.name, inst.type);
        end
        
        function [val rate] = get(inst,chan)
           fprintf('Unhandled get operation on %s (%s)\n',inst.name, inst.type);
        end
        
    end
    
end


