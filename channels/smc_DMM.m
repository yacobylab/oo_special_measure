classdef smc_DMM < sminst
    %Instrument class defining the agilent 34410A multi meter
    %   This class inherits from the generic class sminst. 
    %   The constructor for this class requires a name and a matlab object
    %   (for example a visa object).
    %   For example: dmm = visa('agilent', 'USB0::0x0957::0x0607::MY47020346::0::INSTR'); 
    %    DMM=smDMM('some_name',dmm);
    
    properties (Transient=true)
        is34401;  % Is this a 34401?
    end
    
    methods
        function obj = smc_DMM(inst,name) %constructor!
            obj.inst=inst;
            if ~exist('name','var') || isempty(name)
                name='DMM'; %default name
            end
            obj.name = name;
            obj.device='HP34401A';
            obj.channels.val=sminstchan(inst,[],@(ob) query(o.inst,'READ?','%s\n','%f')); %only get function
            obj.channels.buf=sminstchan(inst,[], @(ob) sscanf(query(o.inst,'FETCH?'),'%f'));
            
        end
 
        function open(inst)
           try
             fopen(inst.inst);
             inst.is34401=~isempty(strfind(query(inst.inst,'*IDN?'),'34410A'));
           catch err
             warning(sprintf('Error opening instrument %s (%s): %s',inst.name,inst.type,getReport(err))); 
             inst.is34401 = 1; % not really a good default...
           end        
        end
        
        function close(inst)
           fclose(inst.inst); 
        end
        
        function arm(inst,chans) %will arm for acquisition
            fprintf(inst.inst, 'INIT'); 
        end
        
        function trigger(inst, chans)
            fprintf(inst.inst,'*TRG');                    
        end %shouldn't really be used
        
        % Configure the buffer
        % Valid options: bus, ext, imm (see VMM manual)
        % Returns actual sample rate
        function [rate]=bufconfig(inst, npts, rate, opts)
            if ~exist('opts','var')
               opts = 'bus';
            end
            samptime = .4025; %34401A 200 ms
            if 1/rate < samptime  % Correct for the amount of time it takes to take a sample
                %  FIXME; this is hard-coded for slow
                %  mode.
                trigdel = 0;
                rate = 1/samptime;
            else
                trigdel = 1/rate - samptime;
            end
            
            if npts > 512 % 50000 for newer model'; FIXME; we should figure out model.
                error('More than allowed number of samples requested. Correct and try again!\n');
            end
            
            switch opts
                case {'bus','ext','imm'}
                    fprintf(inst.inst, ['TRIG:SOUR ',upper(opts)]); %set trigger to bus
                otherwise
                    error('trigger operation %s not supported',trigopts);
            end
            fprintf(inst.inst, 'SAMP:COUN %d', npts); % set samples to val
            fprintf(inst.inst, 'TRIG:DEL %f', trigdel); % set trigger delay
            inst.channels.buf.datadim=npts;
        end
        
        function beep(inst)
           fprintf(inst.inst,'SYST:BEEP'); 
        end
        function reset(inst)
           fprintf(inst.inst,'*RST'); 
        end
        function [out] = geterr(inst)
           err=query(inst.inst,'SYST:ERR?'); 
           if nargout == 0
               fprintf('%s\n',err);               
           else
               out=err;
           end
        end
    end
    
end
