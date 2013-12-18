classdef sm_awg
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        inst;
        chans = [1 2 3 4];
        scale = [1 1 1 1]*4.23;
        clk = 1e-9;
        offst = [0 0 0 0];
        bits = 14;
        slave = 0;
        alternates;
        type = '5k';
        pulsegroups;
    end
    
    methods
        function rm(awg,grps)
            
        end
        function clear(awg,ctrl)
            
        end
        function add(awg,grps)
            
        end
        function on(awg,chans)
            if isempty(chans)
                chans = awg.chans;
            end
           for i = chans
               fprintf(awgdata.inst, 'OUTPUT%i:STAT 1', i);
           end 
        end
        
        function off(awg,chans)
            if isempty(chans)
                chans = awg.chans;
            end
            for i = chans
                fprintf(awgdata.inst, 'OUTPUT%i:STAT 0', i);
            end
        end
        
        function stop(awg)
            fprintf(awg.inst, 'AWGC:STOP'); 
        end
        
        function start(awg)
           fprintf(awgdata(a).awg, 'AWGC:RUN');
           awg.wait();
        end
        
        function wait(awg) %set the timeout to 5min, query for wait, reset timeout
           to = awg.inst.timeout;
           awg.inst.timeout = 600;
           query(awg.inst, '*OPC?');
           awg.inst.timeout = to; 
        end
        
        function raw(awg,chans)
            if any(awg.israw())
                if isempty(chans)
                    chans = awg.chans;
                end
                    if strcmp(awg.type,'5k')
                        for i = chans
                            fprintf(awgdata(a).awg, 'AWGC:DOUT%i:STAT 1', i);
                        end
                    end
            else
                fprintf('Already raw\n');
            end
        end
        
        function amp(awg,chans)
            if any(awg.israw())
                if isempty(chans)
                    chans = awg.chans;
                end
                if strcmp(awg.type,'5k')
                    for i = chans
                        fprintf(awgdata(a).awg, 'AWGC:DOUT%i:STAT 0', i);
                    end
                end
            else
                fprintf('Already raw\n');
            end
        end
        
        function val = israw(awg,chans)
           val=[];
           if isempty(chans)
               chans = awg.chans;
           end
                if strcmp(awg.type,'5k')
                    for i = chans
                        fprintf(awg.inst, 'AWGC:DOUT%i:STAT?',i);
                        val(end+1) = fscanf(awg.inst,'%f');
                    end
                end  
        end
        
        function val = ison(awg) %if instrument waiting for trigger, returns .5
           val=[];                                
           fprintf(awg.inst, 'AWGC:RST?');
           val(end+1) = .5*fscanf(awg.inst,'%f');                       
        end
        
        function exton(awg,chans)
            if isempty(chans)
                chans = awg.chans;
            end
           for i = chans
               fprintf(awgdata(a).awg, 'SOUR%i:COMB:FEED "ESIG"', i);
           end 
        end
        
        function extoff(awg,chans)
            if isempty(chans)
                chans = awg.chans;
            end
            for i = chans
                fprintf(awgdata(a).awg, 'SOUR%i:COMB:FEED ""', i);
            end
        end
        
        function err(awg)
            er=query(awg.inst, 'SYST:ERR?');
            if strcmp(er(1:end-1), '0,"No error"')
                % Supress blank error messages.
            else
                fprintf('%d: %s\n',a,er);
            end
        end
        
        function clr(awg)
            i = 0;
            err2 = sprintf('n/a.\n');
            while 1
                err = query(awg.inst, 'SYST:ERR?');
                if strcmp(err(1:end-1), '0,"No error"')
                    if i > 0
                        fprintf('%d: %i errors. Last %s', a, i, err2);
                    end
                    break;
                end
                err2 = err;
                i = i + 1;
            end
        end
        
    end
    
end


