classdef smstepchan < smrampchan
    %smrampchan --  Structure that holds information on simulated rampable
    %  channels.
    
    properties (Transient=true)
        rampstart=[];  % Start voltage
        trampstart=[]; % Start time
        rampend=[];    % End voltage
        trampend=[];   % End time
        cramprate=[];   % Current ramp rate
        ramptimer=[];
    end
    
    properties (Constant=true)
        tstep=0.005;   % Time discretization for simulated ramps.
    end
    
    methods
        % Default constructor.
        function ic=smstepchan(parent,set,get)
            ic=ic@smrampchan(parent,set,get);
        end
        
        % Set the channel, simulating ramps in software.
        function set(ic, val, rate)
            if ~exist('rate','var') || isempty(rate)
                rate=ic.ramprate;
            else
                rate=min(rate,ic.ramprate);
            end
            if isinf(rate)
                ic.sethndl(ic,val,inf);
                ic.val=val;
                complete=1;
                return;
            else
                if ~isempty(ic.ramptimer) && isvalid(ic.ramptimer)  % Stop any current ramp.
                    stop(ic.ramptimer);
                    delete(ic.ramptimer);
                end
                ic.val=ic.gethndl(ic);
                ic.cramprate=rate;
                ic.rampstart=ic.val;
                ic.trampstart=now*24*60*60;
                ic.rampend=val;
                ic.trampend=ic.trampstart+abs((ic.rampstart-ic.rampend)/ic.cramprate);
                ic.ramptimer=timer('Period',ic.tstep,'ExecutionMode','fixedSpacing','TimerFcn',@(~,~) ic.timer());
                ic.complete=0;
                start(ic.ramptimer);
            end
        end
        
        % Timer callback for simulating ramps.
        function timer(ic)         
            t=now*24*60*60;
            if t >= ic.trampend  % Are we done?
                ic.sethndl(ic,ic.rampend,inf);
                ic.val = ic.rampend;
                ic.complete=1;
                stop(ic.ramptimer);
                delete(ic.ramptimer);                
                return;
            end
            
            % Compute new value and go there.
            nv = ic.rampstart + (ic.rampend-ic.rampstart)*abs((t-ic.trampstart)/(ic.trampend - ic.trampstart));
            if ic.rampstart < ic.rampend
                assert((nv >= ic.rampstart) && (nv <= ic.rampend))
            else
                assert((nv <= ic.rampstart) && (nv >= ic.rampend))
            end                
            ic.val=nv;
            ic.sethndl(ic,ic.val,inf);            
        end
        
        % Override timeleft function.
        function val=timeleft(ic)
            t=now*24*60*60;
            val=ic.trampend - t;
        end
        % Get handler.
        function val=get(ic)
            val=ic.gethndl(ic);
        end                
    end
end

