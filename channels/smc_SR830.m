classdef smc_SR830 < sminst
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        currsamp; %for reading buffers
        sampint;
        buf_chans;
    end
    
%             cmds = {'OUTP 1', 'OUTP 2', 'OUTP 3', 'OUTP 4', 'FREQ', 'SLVL', ...
%     'OAUX 1', 'OAUX 2', 'OAUX 3', 'OAUX 4', 'AUXV 1', 'AUXV 2', 'AUXV 3', 'AUXV 4' ...
%     ,'','','SENS', 'OFLT', 'SYNC'};
    % 1: X, 2: Y, 3: R, 4: Theta, 5: freq, 6: ref amplitude
% 7:10: AUX input 1-4, 11:14: Aux output 1:4
% 15,16: stored data, length determined by datadim
% 17: sensitivity
% 18: time constant
% 19: sync filter on/off
%val = query(smdata.inst(ic(1)).data.inst, sprintf('%s? %s',...
  %                  cmds{ic(2)}(1:4), cmds{ic(2)}(5:end)), '%s\n', '%f');
    methods
        function obj = smc_SR830(inst,name)
            obj.inst=inst;
            if ~exist('name','var') || isempty(name)
                name='Lockin'; %default name
            end
            obj.name = name;
            obj.channels = sminstchan(obj,[],@(o) query(o.parent.inst,...
                sprintf('%s? %s','OUTP', '1', '%s\n', '%f')));
            obj.channels.name = 'X';
            obj.channels(2) = sminstchan(obj,[],@(o) query(o.parent.inst,...
                sprintf('%s? %s','OUTP', '2', '%s\n', '%f')));
            obj.channels(2).name = 'Y';
            obj.channels(3) = sminstchan(obj,[],@(o) query(o.parent.inst,...
                sprintf('%s? %s','OUTP', '3', '%s\n', '%f')));
            obj.channels(3).name = 'R';
            obj.channels(4) = sminstchan(obj,[],@(o) query(o.parent.inst,...
                sprintf('%s? %s','OUTP', '1', '%s\n', '%f')));
            obj.channels(4).name = 'Theta';
            obj.channels(5) = sminstchan(obj,@(o,v,r)fprintf(o.parent.inst, sprintf('%s %f', 'FREQ', v)),...
                @(o) query(o.parent.inst,sprintf('%s? %s','FREQ', '', '%s\n', '%f')));
            obj.channels(5).name = 'Freq';
            obj.channels(6) = sminstchan(obj,@(o,v,r)fprintf(o.parent.inst, sprintf('%s %f', 'FREQ', v)),...
                @(o) query(o.parent.inst,sprintf('%s? %s','SLVL', '', '%s\n', '%f')));
            obj.channels(6).name = 'Ampl';
            
            obj.channels(7) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('OAUX 1 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','OAUX', 1, '%s\n', '%f')));
            obj.channels(7).name = 'Aux_in_1';
            obj.channels(8) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('OAUX 2 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','OAUX', 2, '%s\n', '%f')));
            obj.channels(8).name = 'Aux_in_2';
            obj.channels(9) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('OAUX 3 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','OAUX', 3, '%s\n', '%f')));
            obj.channels(9).name = 'Aux_in_3';
            obj.channels(10) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('OAUX 4 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','OAUX', 4, '%s\n', '%f')));
            obj.channels(10).name = 'Aux_in_4';
            
            obj.channels(11) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('AUXV 1 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','AUXV', 1, '%s\n', '%f')));
            obj.channels(11).name = 'Aux_out_1';
            obj.channels(12) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('AUXV 2 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','AUXV', 2, '%s\n', '%f')));
            obj.channels(12).name = 'Aux_out_2';
            obj.channels(13) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('AUXV 3 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','AUXV', 3, '%s\n', '%f')));
            obj.channels(13).name = 'Aux_out_3';
            obj.channels(14) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,sprintf('AUXV 4 %f',v)),...
                    @(o) query(o.parent.inst,sprintf('OAUX? %d','AUXV', 4, '%s\n', '%f')));
            obj.channels(14).name = 'Aux_out_4';
            
            for j = 1:2
                obj.channels(end+1) = sminstchan(obj,@(o)smc_SR830.read_buffer(o,j));
                obj.channels(end).name = sprintf('Buf%d',j);
                obj.buf_chans = [obj.buf_chans, length(obj.channels)];
            end
            obj.currsamp = zeros(1,j);
            obj.sampint = zeros(1,j);
            obj.channels(end+1) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,...
                sprintf('%s %f', 'SENS', smc_SR830.SR830sensindex(v))),...
                @(o)smc_SR830.sensvalue(query(o.prent.inst,sprintf('%s? %s','SENS','','%s\n','%f'))));
            obj.channels(end).name = 'Sensitivity';
            obj.channels(end+1) = sminstchan(obj,@(o,v,r) fprintf(o.parent.inst,...
                sprintf('%s %f', 'OFLT', smc_SR830.SR830tausindex(v))),...
                @(o)smc_SR830.tauvalue(query(o.prent.inst,sprintf('%s? %s','OFLT','','%s\n','%f'))));
            obj.channels(end).name = 'TimeConst';
            
        end % end constructor
        
        function trigger(lockin)
           fprintf(lockin.in,'STRT'); 
        end
        
        function arm(lockin)
            fprintf(lockin.inst, 'REST');
            lockin.currsamp = zeros(size(lockin.currsamp));
            pause(.1); %needed to give instrument time before next trigger.
            % anything much shorter leads to delays.
        end
        
        function out = buf_config(lockin,val,rate,chan)
            if nargin > 4 && strfind(ctrl, 'sync')
                n = 14;
            else
                n = round(log2(rate)) + 4;
                rate = 2^-(4-n);
                % allow ext trig?
                if n < 0 || n > 13
                    error('Samplerate not supported by SR830');
                end
            end
            %if strfind(ctrl, 'trig')
            fprintf(lockin.inst, 'REST; SEND 1; TSTR 1; SRAT %i', n);
            %else
            %    fprintf(smdata.inst(ic(1)).data.inst, 'REST; SEND 1; TSTR 0; SRAT %i', n);
            %end
            pause(.1);
            lockin.currsamp(chan) = 0*chan;
            
            lockin.sampint = 1/rate;
            lockin.channels(lockin.buf_chans).datadim = val;
            out = true;
        end
        
    end
    
    methods (Static, Access = {?smc_SR830, ?sminstchan})
        function val = SR830sensvalue(~,sensindex)
            % converts an index to the corresponding sensitivity value for the SR830
            % lockin.
            x = [2e-9 5e-9 10e-9];
            sensvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
            val = sensvals(sensindex+1);
        end
        function sensindex = SR830sensindex(~,sensval)
            % converts a sensitivity to a corresponding index that can be sent to the
            % SR830 lockin.  rounds up (sens = 240 will become 500)
            x = [2e-9 5e-9 10e-9];
            sensvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
            sensindex = find(sensvals >= sensval,1)-1;
        end
        function val = SR830tauvalue(~,tauindex)
            % converts an index to the corresponding sensitivity value for the SR830
            % lockin.
            x = [10e-6 30e-6];
            tauvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
            val = tauvals(tauindex+1);
        end
        function tauindex = SR830tauindex(~,tauval)
            % converts a time constant to a corresponding index that can be sent to the
            % SR830 lockin.  rounds up (tau = 240 will become 300)
            x = [10e-6 30e-6];
            tauvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
            tauindex = find(tauvals >= tauval,1)-1;
        end
        function val = read_buffer(~,ic,chan)
            npts = ic.datadim;
            while 1
                navail = query(ic.parent.inst, 'SPTS?', '%s\n', '%d');
                if navail >= npts + ic.parent.currsamp(chan);
                    break;
                else
                    pause(0.8 * (npts + ic.parent.currsamp(chan) - navail) *ic.parent.sampint);
                end
                fprintf(ic.parent.inst.inst, 'TRCB? %d, %d, %d', ...
                    [chan, ic.parent.currsamp(chan)+[0, npts]]);
                val = fread(ic.parent.inst, npts, 'single');
                ic.parent.currsamp(chan) =  ic.parent.currsamp(chan) + npts;
            end
        end
        
    end %end static methods
    
end

