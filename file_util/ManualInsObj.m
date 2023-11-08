classdef ManualInsObj < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % components
        AxGrp; ButGrp; BadLabel; LBut; RBut; SwitchOpt;
        
        % data
        Fs; BlIdx; BadChans; GoodChans
        
        % plotting
        LinGrp; CurPg; NPg; PgSel
        
    end
    
    methods
        function obj = ManualInsObj(ax, but, badlabel, L, R, sw, nchans, fs, ....
                bl, badchans, goodchans, data)
            obj.AxGrp = ax; obj.ButGrp = but; obj.BadLabel = badlabel;
            obj.LBut = L; obj.RBut = R; obj.SwitchOpt = sw; 
            obj.Fs = fs; obj.BlIdx = bl;
            
            obj.BadChans = badchans;
            obj.GoodChans = goodchans;
            
            obj.CurPg = 1;
            obj.NPg = ceil(nchans/15);
            obj.FormatBad;
            obj.PlotPg(data);
        end
        
        function [] = FormatBad(obj)
        % if no bad channels, return empty string
            if isempty(obj.BadChans)
                badchans_f = '';
        % otherwise format string with commas
            else
                badchans_f = arrayfun(@(x) sprintf('%d, ', x), obj.BadChans(1:end-1), ...
                    'UniformOutput', false);
                badchans_f = horzcat(badchans_f{:}, num2str(obj.BadChans(end)));
            end
            obj.BadLabel.Text = sprintf('Bad Channels: %s', badchans_f);
        end
        
        function obj = PlotPg(obj, data)
        % plot channels for manual inspection
            if isequal(obj.SwitchOpt.Value, 'Baseline Only')
                x = obj.BlIdx;
            else
                x = 1:size(data, 1);
            end
            t = (1:length(x))/obj.Fs;
        % calculate channels to plot on current page
            idx1 = 1 + 15*(obj.CurPg - 1);
            locidx = idx1:min(idx1 + 14, size(data, 2));
            obj.LinGrp = cell(1,length(locidx));
            obj.PgSel = false(1, length(locidx));
            for ii = 1:length(locidx)
                cla(obj.AxGrp{ii}, 'reset');
                obj.AxGrp{ii}.Visible = true; obj.ButGrp{ii}.Visible = true;
        % if bad channel, plot in red
                if ismember(locidx(ii), obj.BadChans)
                    obj.LinGrp{ii} = plot(obj.AxGrp{ii}, t, data(x, locidx(ii)), 'r');
        % otherwise, plot in black
                else
                    obj.LinGrp{ii} = plot(obj.AxGrp{ii}, t, data(x, locidx(ii)), 'k');
                end
        % update labels
                obj.ButGrp{ii}.Text = sprintf('Ch. %d', locidx(ii));
                if ismember(locidx(ii), obj.BadChans)
                    obj.ButGrp{ii}.Value = true;
                    obj.PgSel(ii) = true;
                else
                    obj.ButGrp{ii}.Value = false;
                    obj.PgSel(ii) = false;
                end
        % set y axes
                s = std(data(x, locidx(ii)));
                if ~isnan(s)
                    ylim(obj.AxGrp{ii}, [-4*s 4*s]);
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
        % bad channel: change plot to red and add to list
            if value
                obj.BadChans = sort(unique(horzcat(obj.BadChans, ch)));
                obj.GoodChans(obj.GoodChans == ch) = [];
                set(obj.LinGrp{n}, 'Color', 'r');
        % good channel: change plot to black and add to list
            else
                obj.BadChans(obj.BadChans == ch) = [];
                obj.GoodChans = sort(unique(horzcat(obj.GoodChans, ch)));
                set(obj.LinGrp{n}, 'Color', 'k');
            end
        % format bad channel text string
            obj.FormatBad;
            obj.PgSel = comp;
            for ii = 1:length(obj.ButGrp)
                obj.ButGrp{ii}.Enable = true;
            end
            pause(0.001);
        end
        
        function obj = LRPush(obj, inc, data)
            obj.LBut.Enable = false; obj.RBut.Enable = false; pause(0.001);
            obj.CurPg = obj.CurPg + inc; obj.PlotPg(data);
        end
        
        function [goodchans, badchans] = GetGoodBad(obj)
            goodchans = obj.GoodChans;
            badchans = obj.BadChans;
        end
        
    end
end

