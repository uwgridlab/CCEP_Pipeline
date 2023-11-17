classdef EPInsObj < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % components
        AxGrp; ButGrp; EPLabel; LBut; RBut;
        
        % data
        TEpoch; GoodChans; EPChans; AmpChans;
        
        % plotting
        LinGrp; CurPg; NPg; PgSel;
    end
    
    methods
        function obj = EPInsObj(ax, but, L, R, EPlabel, stimchans, ....
                tEpoch, goodchans, data, fs)
            obj.AxGrp = ax; obj.ButGrp = but; obj.EPLabel = EPlabel;
            obj.LBut = L; obj.RBut = R; 
            
            stimchans = unique(stimchans(:));
            goodchans(ismember(goodchans, stimchans))= [];
            
            obj.TEpoch = tEpoch; obj.GoodChans = goodchans; 
            
            t10 = obj.TEpoch >= 0.01;
            obj.EPChans = find(sum(abs(data(t10, :)) > 1) >= fs*.05 | ...
                sum(abs(data(t10, :)) > 0.5) >= fs*.25);
            obj.AmpChans = obj.EPChans;
            
            nchans = size(data, 2);
            
            obj.CurPg = 1;
            obj.NPg = ceil(nchans/15);
            obj.FormatEPs;
            obj.PlotPg(data);
        end
        
        function [] = FormatEPs(obj)
        % if no bad channels, return empty string
            if isempty(obj.EPChans)
                EPchans_f = '';
        % otherwise format string with commas
            else
                EPchans_f = arrayfun(@(x) sprintf('%d, ', x), obj.EPChans(1:end-1), ...
                    'UniformOutput', false);
                EPchans_f = horzcat(EPchans_f{:}, num2str(obj.EPChans(end)));
            end
            obj.EPLabel.Text = sprintf('EP Channels: %s', EPchans_f);
        end
        
        function obj = PlotPg(obj, data)
        % plot channels for manual inspection
        % temporarly disable channel selection
            for ii = 1:length(obj.ButGrp)
                obj.ButGrp{ii}.Enable = false;
            end
            pause(0.001);
        % calculate channels to plot on current page
            idx1 = 1 + 15*(obj.CurPg - 1);
            locidx = idx1:min(idx1 + 14, size(data, 2));
            obj.LinGrp = cell(1,length(locidx));
            obj.PgSel = false(1, length(locidx));
            t = obj.TEpoch;
            for ii = 1:length(locidx)
                cla(obj.AxGrp{ii}, 'reset');
                if ~ismember(locidx(ii), obj.GoodChans)
                    obj.ButGrp{ii}.Enable = false;
                    obj.ButGrp{ii}.Value = false;
                    obj.PgSel(ii) = false;
                    obj.ButGrp{ii}.Text = 'N/A';
                else
                    obj.AxGrp{ii}.Visible = true; obj.ButGrp{ii}.Visible = true;
            % if EP channel, plot in green
                    if ismember(locidx(ii), obj.EPChans)
                        obj.LinGrp{ii} = plot(obj.AxGrp{ii}, t, data(:, locidx(ii)), 'g');
            % otherwise, plot in black
                    else
                        obj.LinGrp{ii} = plot(obj.AxGrp{ii}, t, data(:, locidx(ii)), 'k');
                    end
            % update labels
                    obj.ButGrp{ii}.Text = sprintf('Ch. %d', locidx(ii));
                    if ismember(locidx(ii), obj.EPChans)
                        obj.ButGrp{ii}.Value = true;
                        obj.PgSel(ii) = true;
                    else
                        obj.ButGrp{ii}.Value = false;
                        obj.PgSel(ii) = false;
                    end
                    if ismember(locidx(ii), obj.AmpChans)
                        obj.ButGrp{ii}.Enable = true;
                    else
                        obj.ButGrp{ii}.Enable = false;
                    end
            % set y axes
                    s = std(data(:, locidx(ii)));
                    if ~isnan(s)
                        ylim(obj.AxGrp{ii}, [-4*s 4*s]);
                    end
                end
            end
        % hide empty plots
            if length(locidx) < 15
                for ii = (length(locidx)+1):15
                    cla(obj.AxGrp{ii}, 'reset'); 
                    obj.AxGrp{ii}.Visible = false; 
                    obj.ButGrp{ii}.Visible = false;
                end
            end
        % enable/disable R/L buttons
            obj.RLSettings();
        end
        
        function obj = RLSettings(obj)
            n = obj.NPg; c = obj.CurPg;
            if n == 1
                obj.LBut.Enable = false; obj.RBut.Enable = false;
            elseif c == 1
                obj.LBut.Enable = false; obj.RBut.Enable = true;
            elseif c == n
                obj.LBut.Enable = true; obj.RBut.Enable = false;
            else
                obj.LBut.Enable = true; obj.RBut.Enable = true;
            end
        end
        
        function obj = ChangeDes(obj)
        % change designation of channel as good or bad
        % temporarly disable channel selection
            init_enable = cellfun(@(x) x.Enable, obj.ButGrp, 'UniformOutput', false);
            for ii = 1:length(obj.ButGrp)
                obj.ButGrp{ii}.Enable = false;
            end
            pause(0.001);
        % identify index of changed channel
            comp = cellfun(@(x) x.Value, obj.ButGrp);
            comp = comp(1:length(obj.PgSel));
            n = find(comp ~= obj.PgSel);
        % find the index of the channel on the page of plotted channels
            value = obj.ButGrp{n}.Value;
            ch = n + (15*(obj.CurPg - 1)); % calcuate actual channel #
        % EP channel: change plot to green and add to list
            if value
                obj.EPChans = sort(unique(horzcat(obj.EPChans, ch)));
                set(obj.LinGrp{n}, 'Color', 'g');
        % non-EP channel: change plot to black and add to list
            else
                obj.EPChans(obj.EPChans == ch) = [];
                set(obj.LinGrp{n}, 'Color', 'k');
            end
        % format bad channel text string
            obj.FormatEPs;
            obj.PgSel = comp;
            for ii = 1:length(obj.ButGrp)
                obj.ButGrp{ii}.Enable = init_enable{ii};
            end
            pause(0.001);
        end
        
        function obj = LRPush(obj, inc, data)
            obj.LBut.Enable = false; obj.RBut.Enable = false; pause(0.001);
            obj.CurPg = obj.CurPg + inc; obj.PlotPg(data);
        end
        
        function EPchans = GetEPChans(obj)
            EPchans = obj.EPChans;
        end
        
        function obj = AddEPChans(obj, EPchans)
            obj.EPChans = EPchans;
        end
        
    end
end

