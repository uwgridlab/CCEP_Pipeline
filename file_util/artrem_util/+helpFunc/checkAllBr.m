function [datout, allchck, br] = checkAllBr(data, fsData, anode, cathode, ...
    onsets_samps, txt, varargin)
%CHECKALLBR Summary of this function goes here
%   Detailed explanation goes here

    p = inputParser;
    addRequired(p, 'data', @isnumeric);
    addRequired(p, 'fsData', @isnumeric);
    addRequired(p, 'anode', @isnumeric);
    addRequired(p, 'cathode', @isnumeric);
    addRequired(p, 'onsets_samps', @isnumeric);
    addRequired(p, 'txt');
    addParameter(p, 'dmdb', 'eucl', @(x) strcmp(x, 'eucl') || strcmp(x, 'corr'));
    addParameter(p, 'pre', .4096, @isnumeric);
    addParameter(p, 'post', .4096, @isnumeric);
    addParameter(p, 'plotIt', true, @islogical);
    addParameter(p, 'startInds', []);
    addParameter(p, 'endInds', []);
    addParameter(p, 'maxAmps', []);
    addParameter(p, 'maxLocation', []);
    addParameter(p, 'templateArrayCell', []);
    
    p.parse(data, fsData, anode, cathode, onsets_samps, txt, varargin{:});
    
    data = p.Results.data;
    fsData = p.Results.fsData;
    anode = p.Results.anode;
    cathode = p.Results.cathode;
    onsets_samps = p.Results.onsets_samps;
    txt = p.Results.txt;
    dmdb = p.Results.dmdb;
    pre = p.Results.pre;
    post = p.Results.post;
    plotIt = p.Results.plotIt;
    startInds = p.Results.startInds;
    endInds = p.Results.endInds;
    maxAmps = p.Results.maxAmps;
    maxLocation = p.Results.maxLocation;
    templateArrayCell = p.Results.templateArrayCell;
    
    br = {{-6:6 -6:5 -6:4 -6:3 -6:2 -6:1 -1:6 -2:6 -3:6 -4:6 -5:6}, ...
        {-5:5 -5:4 -5:3 -5:2 -5:1 -1:5 -2:5 -3:5 -4:5}, ...
        {-4:4 -4:3 -4:2 -4:1 -1:4 -2:4 -3:4}, ...
        {-3:3 -3:2 -3:1 -1:3 -2:3}, {-2:2 -2:1 -1:2}};
    dims = [4 3; 3 3; 3 3; 2 3; 1 3];
    
    datout = cell(size(br));
    allchck = cell(size(br));
    stimChans = [cathode anode];
    
    if isempty(startInds) || isempty(endInds) || isempty(maxAmps) || ...
            isempty(maxLocation) || isempty(templateArrayCell)
        
        numChans = size(rawSig,2);
        [~,goodCell] = helpFunc.good_channel_extract('numChans',numChans,...
            'bads',bads,'stimChans',stimChans);
        [startInds,endInds] = analyFunc.get_artifact_indices(data, txt, ...
            'pre',pre,'post',post,'fixedDistance',4,'fs',fsData,...
            'goodCell',goodCell,'minDuration',0.25,'threshVoltageCut',80,...
            'threshDiffCut',80,'onsetThreshold',5, 'stimRecord', onsets_samps);
        [templateCell,lengthMax,maxAmps] = analyFunc.get_artifacts(data,...
            'goodCell',goodCell,'startInds',startInds,'endInds',endInds,...
            'normalize','preAverage');
        [~,templateArrayCell, maxIdxArray] = ...
            analyFunc.template_equalize_length(templateCell,data,txt,'lengthMax',...,
            lengthMax,'startInds',startInds,'goodCell',goodCell);
        [templateArrayCell, maxLocation] = analyFunc.template_align(templateArrayCell, ...
            maxIdxArray, 0.9, txt);

    end
    
    for b1 = 1:length(br)
        if plotIt
            figure;
        end
        loc = cell(1, length(br{b1}));
        loc_allchck = cell(1,length(br{b1}));
        for b2 = 1:length(br{b1})
            
            da = analyFunc.template_dictionary(templateArrayCell,data,fsData,txt,...
                'distanceMetricDbscan',dmdb,'distanceMetricSigMatch','xcorr',...
                'goodCell',goodCell,'startInds',startInds,'endInds',endInds,...
                'recoverExp',0,'maxAmps',maxAmps,'maxLocation',maxLocation,...
                'bracketRange',bracketRange,'expThreshDiffCut',75,...
                'expThreshVoltageCut',75,'minClustSize',1,'useProcrustes',1);
            txt.Value = vertcat({'--- Extracting data ---'}, txt.Value); pause(0.01);
            txt.Value = vertcat({'--- Checking removal quality ---'}, txt.Value); pause(0.01);
            chck = analyFunc.assess_removal(processedSig, startInds, endInds);
            txt.Value = vertcat({'--- Artifact removal complete! ---'}, txt.Value); pause(0.01);
            
            loc{b2} = da;
            loc_allchck{b2} = chck;

            if plotIt
                subplot(dims(b1, 1), dims(b1, 2), b2);
                plot(data, 'r');
                hold on;
                plot(da);
                vline(onsets_samps);
                title([num2str(br{b1}{b2}(1)) ':' num2str(br{b1}{b2}(end)) ...
                    ' (' num2str(nansum(chck)) ')']);
            end
          
            if all(nansum(chck) >= size(chck, 1))
                datout{b1} = loc;
                allchck{b1} = loc_allchck;
                return
            end
            
            
        end
        
        datout{b1} = loc;
        allchck{b1} = loc_allchck;
        
    end

end

