classdef smc_DMM < sminst
    %Instrument class defining the agilent 34410A multi meter
    %   This class inherits from the generic class sminst. It has no new
    %   properties beyond those in sminst;
    %   The constructor for this class requires a name and a matlab object
    %   (for example a visa object).
    %   For example: dmm = visa('agilent', 'USB0::0x0957::0x0607::MY47020346::0::INSTR'); 
    %    DMM=smDMM('some_name',dmm);
    
    properties (Transient=true)
        is34401;  % Is this a 34401?
    end
    
    methods
        function obj = smc_DMM(name,inst) %constructor!
            obj.name = name;
            obj.inst = inst;
            obj.channels=[sminstchan('Val') sminstchan('Buf')];
            obj.channels(1).setable=0;
            obj.channels(2).setable=0;
        end
 
        function open(inst,chans)
           try
             fopen(inst.inst);
           catch err
             warning(sprintf('Error opening instrument %s (%s): %s',inst.name,inst.type,getReport(err))); 
           end 
           inst.is34401=~isempty(strfind(query(inst.inst,'*IDN?'),'34410A'));
        end
        
        function arm(inst,chans) %will arm for acquisition
            fprintf(inst.inst, 'INIT'); 
        end
        
        function trigger(inst, chans)
            fprintf(inst.inst,'*TRG');                    
        end
        
        % Configure the buffer
        % Valid options: bus, ext, imm (see VMM manual)
        % Returns actual sample rate
        function [rate]=bufconfig(inst, npts, rate, opts);
            if ~exist('opts','var')
                trigopts = 'bus';
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
            
            switch trigopts
                case 'bus'
                    fprintf(inst.inst, 'TRIG:SOUR BUS'); %set trigger to bus
                case 'ext'
                    fprintf(inst.inst, 'TRIG:SOUR EXT'); %
                case 'imm' % immediate triggering
                    fprintf(inst.inst, 'TRIG:SOUR IMM'); %
                otherwise
                    error('trigger operation %s not supported',trigopts);
            end
            fprintf(inst.inst, 'SAMP:COUN %d', npts); % set samples to val
            fprintf(inst.inst, 'TRIG:DEL %f', trigdel); % set trigger delay
            inst.channels(2).datadim=npts;
        end
        
        function [val rate] = get(inst,chans,val,rate) %read the value or buffer           
           switch chans
               case 1 % Get the value
                   val = query(inst.inst,  'READ?', '%s\n', '%f');
               case 2 % Read the buffer
                   s=query(inst.inst,'FETCH?');
                   val = sscanf(s, '%f,')';
               otherwise
                   error('requesting operation on non-existent channel');
           end
            
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
