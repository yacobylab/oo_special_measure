classdef testclass
    properties
        a=p
    end
    
    methods
        function [tc]=testclass
            
        end
        function [io]=set.a(io,v)
            'set'
        end
        function [v]=get.a(io)
            'get'
            if isstruct(v)
                'f'
            end
            v=0;
        end
    end
    
end

classdef p
    properties
        a
        b
        c
    end
end