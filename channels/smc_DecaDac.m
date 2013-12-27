classdef smc_DecaDac < sminst
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       update;
       rng;
       script_addr;
       serial_num;
    end
    properties (SetAccess=immutable) % only set by constructor
        nchan;
    end
    
    methods
        function obj = smc_DecaDac(inst,name,nchan)
            obj.inst=inst;
            if ~exist('name','var') || isempty(name)
                name=sprintf('%schan_Dac',nchan); %default name
            end
            obj.name = name;
            obj.device='DecaDac';
            obj.channels = sminstchan(obj,@(o,v,r) smc_DecaDac.write_script(o.parent.inst,v),@(o)o.parent.script_add.get());
            obj.channels.name = 'Script';
            for j = 1:nchan
                obj.channels(end+1) = sminstchan(obj,@(o,v,r) smc_DecaDac.set_val(o.parent.inst,j,v,r),...
                    @(o,v,r) smc_DecaDac.read_val(o.parent.inst,j,v,r));
                obj.channels(end).name = sprintf('Chan%d',j);
                
                obj.channels(end+1) = smrampchan(obj,@(o,v,r) smc_DecaDac.set_ramp(o.parent.inst,j,v,r),...
                    @(o,v,r) smc_DecaDac.read_val(o.parent.inst,j,v,r));
                obj.channels(end).name = sprintf('Ramp%d',j);
                %FIXME: need to populate donehndl
            end
        end
        
        function status = trigger(DD,chan)
            dacwrite(DD.inst, sprintf('B%1d;C%1d;G0;', floor((chan-1)/8), floor(mod(chan-1, 8)/2)));
            status = 1; %this is meaningless
        end
        
        function status = init(DD,opts)
            assert(length(DD.update)==DD.nchan);
            assert(size(DD.rng,2)==DD.nchan);
            %maybe get rid of the next one if we want people to have crazy
            %decadacs?
            assert((length(DD.channels)==DD.nchan*2)||(length(DD.channels)==DD.nchan*2+1));
            
            if DD.handshake
                status = 1;
                for i = 0:((size(DD.channels, 1)-1)/8-1)
                    query(DD.inst, sprintf('B%d;M2;', i));
                    if ~isempty(DD.update)
                        for j = 0:3
                            query(DD.inst, sprintf('C%d;T%d;', j, DD.update(4*i+j+1)));
                        end
                    end
                end
            else
                status = 0;
            end
            
            if exist('opts','var') && ~isempty(strfind(opts,'zero'))
                for i = 1:size(DD.channels, 1)/2
                    DD.channels(i).set(0);
                end
            end
        end
        
        function out = handshake(DD)
            if ~isempty(DD.serial_num)
                hndshk = query(DD.inst, sprintf('A1107296264;p;'));
                out = strcmp(sscanf(hndshk, 'A1107296264!p%d'),DD.serial_num);
            else
                out = true;
            end
        end
    end %end open access methods
    
    methods (Static, Access = {?smc_DecaDac, ?sminstchan})
        function val = dacread(~, inst, str, format)
            if nargin < 3
                format = '%s';
            end           
            i = 1;
            while i < 10
                try
                    val = query(inst, str, '%s\n', format);
                    i = 10;
                catch
                    fprintf('WARNING: error in DAC (%s) communication. Flushing buffer and repeating.\n',inst.Port);
                    while inst.BytesAvailable > 0
                        fprintf(fscanf(inst))
                    end
                    
                    i = i+1;
                    if i == 10
                        error('Failed 10 times reading from DAC')
                    end
                end
            end
        end % end dacread
        

        function val = set_ramp(DD,chan,val,rate)
            rate2 = int32(abs(rate / diff(DD.rng(chan,:))) * 2^32 * 1e-6 * DD.update(floor((chan+1)/2)));
            
            curr = smc_DecaDac.dacread(DD.inst, ...
                sprintf('B%1d;C%1d;d;', floor((chan-1)/8), floor(mod(chan-1, 8)/2)), '%*7c%d');
            
            if curr < val
                if rate > 0
                    smc_DecaDac.dacwrite(DD.inst, sprintf('G8;U%05d;S%011d;G0;', val, rate2));
                else
                    smc_DecaDac.dacwrite(DD.inst, sprintf('G%02d;U%05d;S%011d;', ...
                        smdata.inst(ic(1)).data.trigmode, val, rate2));
                end
            else
                if rate > 0
                    smc_DecaDac.dacwrite(DD.data.inst, sprintf('G8;L%05d;S%011d;G0;', val, -rate2));
                else
                    smc_DecaDac.dacwrite(DD.data.inst, sprintf('G%02d;L%05d;S%011d;', ...
                        smdata.inst(ic(1)).data.trigmode, val, -rate2));
                end
            end
            val = abs(val-curr) * 2^16 * 1e-6 * DD.update(floor((chan+1)/2)) / double(rate2);
        end
        
        function val = set_val(dd,chan,val)
            smc_DecaDac.dacwrite(dd, ...
                sprintf('B%1d;C%1d;D%05d;', floor((chan-1)/8), floor(mod(chan-1, 8)/2), val));
            val = 0;
        end
        
        function get_val(dd,chan)
            val = smc_DecaDac.dacread(dd.inst, ...
                sprintf('B%1d;C%1d;d;', floor((chan-1)/8), floor(mod(chan-1, 8)/2)), '%*7c%d');
            val = val*diff(dd.rng(chan,:))/65535 + dd.rng(chan,1);
            if length(val) > 1
                error(['Apparent DAC comm error. MATLAB sucks.\n',...
                    'Consider closing and opening the instrument with smclose and smopen \n']);
            end
        end
        
        function val = write_script(DD,val)
           query(DD.inst, 'X0;'); % clear buffer to avoid overflows
            if val > 0
                pause(.02); % seems to help avoiding early triggers.           
                fprintf(DD.inst, '%s', sprintf('X%d;', val));
            end
            % suppress terminator which would stop the script
            DD.script_addr = val;
            %if val==0
            %    query(smdata.inst(ic(1)).data.inst, ''); % send terminator and read response
            %    %smflush(ic(1));
            %end
            val = 0; 
        end
        
        function dacwrite(obj, str)
            try
                query(obj.inst, str);
            catch
                fprintf('WARNING: error in DAC (%s) communication. Flushing buffer.\n',obj.inst.Port);
                while obj.inst.BytesAvailable > 0
                    fprintf(fscanf(obj.inst));
                end
            end
        end
        
    end % end second set of methods
end %end class



