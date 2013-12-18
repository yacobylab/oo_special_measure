classdef smdata_class < handle
    %SMDATA   Central data structure for special measure    
    %   All of special measure's functions assume there is a global
    %    instance of this object called "smdata"
    properties
        inst={};       % Cell array of instruments
        channels;      % Structure of smchannel's.
        configch=[];   % Cell array of numbers of channels to save with scan
        configfn={};   % Cell array of config functions.  Run at start of smrun, save values in configdata.
    end
    
    properties (Transient = true)
        chandisph;        % Handle to channel display
        chanvals;         % Last set/get values of channels
    end
    
    properties (Constant = true)
        chandispfig=999;  % Figure number for the channel display
    end
    
    methods
        function sm=smdata_class % Auto-fix the path.
           p=fileparts(which('smdata_class'));              
           addpath([p]);
           addpath([p filesep 'channels']); %assumes channels are in subdirectory of dir with smdata_class
        end
                
        %% Functions relating to channel display
        % Update the channel display for channels chan with data data.
        function smdispchan(smdata, chan, data)           
            if length(data) ~= length(chan)
                warning('Channel-data mismatch in smdispchan');
                return;
            end
            if ishandle(smdata.chandispfig)
                str = get(smdata.chandisph, 'string');
                for k = 1:length(chan)
                    str{chan(k)} = sprintf('%.5g', data(k));
                end
                set(smdata.chandisph, 'string', str);
                drawnow;
            end            
        end
        
        % Initialize figure 999 to display current channel values.
        % The displayed values of all scalar channels will be updated by every
        % call of smset or smget as long is figure 999 is open.
        function sminitdisp(smdata)            
            nchan = length(smdata.channels);
            
            figure(smdata.chandispfig);
            s=get(0,'ScreenSize');
            set(smdata.chandispfig, 'position', [10, s(4)-50-14*nchan, 220, 14*nchan+20], 'MenuBar', 'none', ...
                'Name', 'Channels');
            
            str = cell(1, nchan);
            for i = 1:nchan
                str{i} = sprintf('%-25s', smdata.channels(i).name);
            end
            
            uicontrol('style', 'text', 'position', [10, 10, 200, 14*nchan], ...
                'HorizontalAlignment', 'Left', 'string',  str, 'BackgroundColor', [.8 .8 .8]);
            
            smdata.chandisph = uicontrol('style', 'text', 'position', [110, 10, 100, 14*nchan], ...
                'HorizontalAlignment', 'Left', 'string',  repmat({''}, nchan, 1), 'BackgroundColor', [.8 .8 .8]);
            
        end
    end
end
