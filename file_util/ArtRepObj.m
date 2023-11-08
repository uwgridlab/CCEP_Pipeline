classdef ArtRepObj < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % components
        AxGrp; ButGrp; RadGrp; Rad; NALabel; LBut; RBut; Txt; PreLabel; PostLabel;
        
        % data
        Fs; OnsetsSamps; GoodChans; PP; StimChans;
        
        % plotting
        LinGrp; CurPg; NPg; PgSel; CurCh;
        
        %
        AccChans; NAccChans;
    end
    
    methods
        
        function obj = ArtRepObj(ax, but, rad, radpar, NAlabel, L, R, pre, post, txt, nchans, fs, ...
                onsets_samps, goodchans, stimchans)
            obj.AxGrp = ax; obj.ButGrp = but; obj.RadGrp = rad; obj.Rad = radpar;
            obj.NALabel = NAlabel;
            obj.LBut = L; obj.RBut = R; obj.Txt = txt;
            obj.PreLabel = pre; obj.PostLabel = post;
            obj.Fs = fs; obj.OnsetsSamps = onsets_samps;
            obj.GoodChans = goodchans;
            obj.StimChans = unique(stimchans(:));
            
            obj.AccChans = sort(obj.StimChans)'; obj.NAccChans = obj.GoodChans;
            obj.NAccChans(ismember(obj.NAccChans, obj.AccChans)) = [];
            obj.PP = nan(nchans, 2);
           
            obj.CurPg = 1;
            obj.NPg = ceil(nchans/15);
            obj.FormatNA;
        end
        
        function [ARout, obj] = RunArtRepOneCh(obj, data, chan_in, pre, post)
            ii = mod(chan_in, 15);
            if ii == 0; ii = 15; end
            ARout = obj.RunArtRep(data, chan_in, pre, post);
            obj.PreLabel.Value = obj.PP(chan_in, 1);
            obj.PostLabel.Value = obj.PP(chan_in, 2);
            obj.PlotCh(ARout, ii);
            obj.ChangeSel(chan_in);
        end
        
        function [ARout, obj] = RunArtRepAllCh(obj, data, chan_in, pre, post)
            cellfun(@(x) cla(x, 'reset'), obj.AxGrp); 
            obj.CurPg = 1;
            ARout = obj.RunArtRep(data, chan_in, pre, post);
            obj.PlotPg(ARout);
        end
        
        function [ARout, obj] = RunArtRep(obj, data, chan_in, pre, post)
            obj.RBut.Enable = false; obj.LBut.Enable = false;
            data = data(:, chan_in); ARout = nan(size(data));
            % setup replacement and baseline
            pre_samps = round(pre*obj.Fs); post_samps = round(post*obj.Fs);
            len = pre_samps + post_samps + 1;
            max_bl = -floor((pre + 0.05)*obj.Fs); min_bl = -floor(0.5*obj.Fs);
            for ch = 1:size(data, 2)
                if ~ismember(chan_in(ch), obj.StimChans)
                    obj.Txt.Value = vertcat({sprintf('Channel %d', chan_in(ch))}, obj.Txt.Value); pause(0.001);
                    loc = data(:, ch);
                    for trl = 1:length(obj.OnsetsSamps)
                        win = (-pre_samps:post_samps) + obj.OnsetsSamps(trl);
                        samp = loc(win); 
                        rep_win = loc((min_bl:max_bl) + obj.OnsetsSamps(trl));
                        outliers = find(isoutlier(rep_win));
                        [~, spks] = findpeaks(zscore(rep_win), 'MinPeakProminence', 2);
                        outliers = sort(unique([1; outliers; spks; length(rep_win)]));
                        d = diff(outliers);
                        if ~any(d >= (len + 2))
                            [~, midx] = max(d); % not robust
                            idx = outliers(midx) + 2;
                            while idx >= (length(rep_win) - len - 2)
                                outliers(midx:end) = [];
                                d = diff(outliers);
                                [~, midx] = max(d);
                                idx = outliers(midx) + 2;
                            end
                        else
                            [m, midx] = max(d);
                            r = randi(m - len - 1);
                            idx = outliers(midx) + r + 1;
                        end
                        rep = rep_win(idx:(idx + len - 1));
                        rsl = (rep(end) - rep(1))/length(rep);
                        sub = rep(1) + rsl*(1:length(rep))';
                        ssl = (mean(samp(end-10:end)) - mean(samp(1:10)))/length(rep);
                        adl = mean(samp(1:10)) + ssl*(1:length(rep))';
                        loc(win) = rep + adl - sub;
                    end
                    ARout(:, ch) = loc;
                    obj.PP(chan_in(ch), :) = [pre post];
                else
                end
            end
            % change all ch_in accepted vals to false
            obj.NAccChans = sort(unique([obj.NAccChans chan_in]));
            obj.NAccChans(ismember(obj.NAccChans, obj.StimChans)) = [];
            obj.AccChans(ismember(obj.AccChans, chan_in)) = [];
            obj.AccChans = sort(unique([obj.AccChans, obj.StimChans']));
            obj.FormatNA;
        end
        
        function [] = FormatNA(obj)
        % if channels accepted, recommend confirm
            loc = obj.NAccChans;
            if isempty(loc)
                NAchans_f = 'All channels accepted! Press confirm to continue.';
        % otherwise format string with commas
            else
                NAchans_f = arrayfun(@(x) sprintf('%d, ', x), loc(1:end-1), ...
                    'UniformOutput', false);
                NAchans_f = horzcat(NAchans_f{:}, num2str(loc(end)));
            end
            obj.NALabel.Text = sprintf('Channels to Accept: %s', NAchans_f);
        end
        
        function obj = PlotCh(obj, dataARCh, ii)
            cla(obj.AxGrp{ii}, 'reset');
            obj.AxGrp{ii}.Visible = true; obj.ButGrp{ii}.Visible = true;
            [dataAREp, tAREp] = epochData(dataARCh, obj.OnsetsSamps, 0.005, ...
                0.02, obj.Fs);
            dataARMn = median(dataAREp, 3);
        % plot trials in grey
            trls = squeeze(dataAREp);
            trls = trls - mean(trls);
            plot(obj.AxGrp{ii}, tAREp, trls, 'Color', [0.6627 0.6627 0.6627]);
            hold(obj.AxGrp{ii}, 'on');
        % plot mean in red
            mn = dataARMn; mn = mn - mean(mn);
            obj.LinGrp{ii} = plot(obj.AxGrp{ii}, tAREp, ...
                mn, 'r', 'LineWidth', 2);
        % set axis limits
%             s = mean(std(trls, [], 2));
            s = std(mn);
            ylim(obj.AxGrp{ii}, [-4*s 4*s]);
            xlim(obj.AxGrp{ii}, tAREp([1 end]));
        % update labels
            obj.ButGrp{ii}.Value = false;
            obj.PgSel(ii) = false;
            obj.ButGrp{ii}.Enable = true;
            obj.RadGrp{ii}.Enable = true;
            obj.RLSettings;
        end
        
        function obj = PlotPg(obj, dataAR)
        % plot channels for manual inspection
        % calculate channels to plot on current page
            idx1 = 1 + 15*(obj.CurPg - 1);
            locidx = idx1:min(idx1 + 14, size(dataAR, 2));
            obj.LinGrp = cell(1,length(locidx));
            obj.PgSel = false(1, length(locidx));
            [dataAREp, tAREp] = epochData(dataAR(:, locidx), obj.OnsetsSamps, 0.005, ...
                0.02, obj.Fs);
            dataARMn = median(dataAREp, 3);
            usable = 1:15;
            for ii = 1:length(locidx)
                cla(obj.AxGrp{ii}, 'reset');
                obj.AxGrp{ii}.Visible = true; obj.ButGrp{ii}.Visible = true;
        % if bad channel or stim channel, ignore
                if ~ismember(locidx(ii), obj.GoodChans) || ...
                        any(isnan(dataAR(:, locidx(ii))))
                    obj.ButGrp{ii}.Text = 'N/A';
                    obj.RadGrp{ii}.Text = 'N/A';
                    obj.ButGrp{ii}.Value = true;
                    obj.RadGrp{ii}.Value = false;
                    obj.ButGrp{ii}.Enable = false;
                    obj.RadGrp{ii}.Enable = false;
                    obj.PgSel(ii) = true;
                    usable(usable == locidx(ii)) = [];
                else
        % plot trials in grey
                    trls = squeeze(dataAREp(:, ii, :));
                    trls = trls - mean(trls);
                    plot(obj.AxGrp{ii}, tAREp, trls, 'Color', [0.6627 0.6627 0.6627]);
                    hold(obj.AxGrp{ii}, 'on');
        % if accepted channel, plot mean in black
                    mn = dataARMn(:, ii); mn = mn - mean(mn);
                    if ismember(locidx(ii), obj.AccChans)
                        obj.LinGrp{ii} = plot(obj.AxGrp{ii}, tAREp, ...
                           mn, 'k', 'LineWidth', 2);
        % otherwise, plot in red
                    else
                        obj.LinGrp{ii} = plot(obj.AxGrp{ii}, tAREp, ...
                            mn, 'r', 'LineWidth', 2);
                    end
        % set axis limits
%                     s = mean(std(trls, [], 2));
                    s = std(mn);
                    ylim(obj.AxGrp{ii}, [-4*s 4*s]);
                    xlim(obj.AxGrp{ii}, tAREp([1 end]));
        % update labels
                    obj.ButGrp{ii}.Text = sprintf('Ch. %d', locidx(ii));
                    obj.RadGrp{ii}.Text = sprintf('Ch. %d', locidx(ii));
                    if ismember(locidx(ii), obj.AccChans)
                        obj.ButGrp{ii}.Value = true;
                        obj.PgSel(ii) = true;
                    else
                        obj.ButGrp{ii}.Value = false;
                        obj.PgSel(ii) = false;
                    end
                    obj.ButGrp{ii}.Enable = true;
                    obj.RadGrp{ii}.Enable = true;
                    obj.PreLabel.Value = obj.PP(locidx(ii), 1);
                    obj.PostLabel.Value = obj.PP(locidx(ii), 2);
                end
            end
        % hide empty plots
            if length(locidx) < 15
                for ii = (length(locidx)+1):15
                    cla(obj.AxGrp{ii}, 'reset'); 
                    obj.AxGrp{ii}.Visible = false; 
                    obj.ButGrp{ii}.Visible = false;
                    obj.RadGrp{ii}.Visible = false;
                end
            end
            if ~isempty(usable)
                obj.ChangeSel(locidx(usable(1)));
            end
        % enable/disable R/L buttons
            obj.RLSettings();
        end
        
        function obj = LRPush(obj, inc, dataAR)
            obj.LBut.Enable = false; obj.RBut.Enable = false; pause(0.001);
            obj.CurPg = obj.CurPg + inc; obj.PlotPg(dataAR);
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
        
        function obj = AddPP(obj, pp)
           obj.PP = pp;
        end
        
        function [ret, obj] = ChangeDes(obj)
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
        % bad channel: change plot to red and add to list
            if value
                obj.AccChans = sort(horzcat(obj.AccChans, ch));
                obj.NAccChans(obj.NAccChans == ch) = [];
                set(obj.LinGrp{n}, 'Color', 'k');
        % good channel: change plot to black and add to list
            else
                obj.AccChans(obj.AccChans == ch) = [];
                obj.NAccChans = sort(horzcat(obj.NAccChans, ch));
                set(obj.LinGrp{n}, 'Color', 'r');
            end
        % format not acc channel text string
            obj.FormatNA;
            obj.PgSel = comp;
            for ii = 1:length(obj.ButGrp)
                obj.ButGrp{ii}.Enable = init_enable{ii};
            end
            pause(0.001);
            ret = isempty(obj.NAccChans);
        end
        
        function obj = ChangeSel(obj, n)
            obj.CurCh = n;
            obj.PreLabel.Value = obj.PP(n, 1);
            obj.PostLabel.Value = obj.PP(n, 2);
            obj.PreLabel.Enable = true;
            obj.PostLabel.Enable = true;
            idx = mod(n, 15); if idx == 0; idx = 15; end
            for ii = 1:15
                if ii == idx
                    obj.AxGrp{ii}.BackgroundColor = [1 1 0];
                    obj.RadGrp{ii}.Value = true;
                else
                    obj.AxGrp{ii}.BackgroundColor = [0.94 0.94 0.94];
                    obj.RadGrp{ii}.Value = false;
                end
            end
        end
        
        function [chRun, allRun] = ChangePrePost(obj, pp)
            chRun = ~isequal(pp, obj.PP(obj.CurCh, :));
            upre = unique(obj.PP(:, 1)); upost = unique(obj.PP(:, 1));
            if length(upre) == 1 && length(upost) == 1
                if isequal([upre upost], pp)
                    allRun = false;
                else
                    allRun = true;
                end
            else
                allRun = true;
            end
        end
        
        function curCh = GetCurrentChannel(obj)
            curCh = obj.CurCh;
        end
        
        function pp = GetPP(obj)
            pp = obj.PP;
        end
    end
end

