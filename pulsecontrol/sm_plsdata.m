classdef sm_plsdata
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        datafile;
        grpdir;
        tbase=1000;
        pulses;
    end
    
    methods
        function pd = sm_plsdata(dfile,grpdr)
           pd.datafile = dfile;
           pd.grpdir = grpdr;
        end
        function success = save(pd,name)
            success = save(name,pd);
        end
        function addpls(pd,pls,plsnum)
               if ~exist('plsnum','var') || isempty(plsnum)
                   plsnum = length(pd.pulses)+1;
               end
               if plsnum < length(pd.pulses)+1
                   while 1
                        fprintf('Pulse %i exists. Overwrite? (yes/no)', plsnum);
                        str = input('', 's');
                        switch str
                            case {'yes','no'}
                                break
                        end
                   end
                   if ~strcmp(str,'yes')
                       return
                   end
               end
               pd.pulses(plsnum) = pls;
            end
    end
    
end

