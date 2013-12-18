classdef sm_pulse
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        data;
        taurc=Inf;
        trafofn;
        pardef;
        param_names={};
        format = 'elem';
        
    end
    
    methods
        function smp = sm_pulse(nm,dt,pardef,trafofn,param_names)
           smp.name = nm;
           smp.data = dt;
           smp.pardef = pardef;
           smp.trafofn = trafofn;
           smp.param_names = param_names;
        end
    end
    
end

