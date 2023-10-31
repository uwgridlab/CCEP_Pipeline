function [processedSig,templateArrayCellOutput] = ...
    template_dictionary(templateArrayCell, rawSig, txt, distanceMetricDbscan, ...
    startInds, endInds, maxLocation, bracketRange)

% This function implements the template dictionary method. Briefly, the
% beginning and ending indices of stimulation artifact periods are
% extracted on a channel and trial-wise basis. From here, artifacts are
% clustered to create a dictionary. The closest matching dictionary entry
% for each trial is subtracted out to remove the artifact.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% templateArrayCell = 1 x chans cell array with an array of templates for
%   the channel in each cell (samps x trials), now aligned to max
% rawSig = time x channels x trials raw signal
% txt = text window to print output

% distanceMetricDbscan = distance metric to use with the DBScan dictionary
%   building method.

% startInds = cell array of the start indices each artifact for each
%	channel and trial - startInds{trial}{channel}
% endsInds = cell array of the end indices of each artifact for each
%	channel and trial - endInds{trial}{channel}

% maxLocation = 1 x chans array with the index of the maximum across trials
%   for each channel
% maxAmps = 1 x channels arry with maximum amplitude over all artifacts for
%   each channel

% bracketRange = the number of samples around the maximum voltage deflection 
%   to use for template clustering and subsequent matching (default -6:6)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% processedSig = rawSig with artifacts subtracted out


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Implicitly hardcoded: distanceMetricSigMatch = xcorr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% hardcoded:
amntPreAverage = 3;
minPts = 1;
minClustSize = 1;
outlierThresh = 0.95;

templateArrayCellOutput = cell(1, size(rawSig, 2));
templateSubtractCell = cell(1, size(rawSig, 2));
templateListVec = cell(1, size(rawSig, 2));
maxLocAll = maxLocation;

txt.Value = vertcat({'--- Dictionary ---'}, txt.Value); pause(0.01);
% fprintf(['-------Dictionary-------- \n'])

for chan = 1:size(rawSig, 2)
    txt.Value = vertcat({sprintf('artifact channel %d', chan)}, txt.Value); pause(0.01);
    
    templateArray = templateArrayCell{chan};
    
    if isempty(templateArray)
        continue
    end
    % shorten data to be centered around the peak +/- the bracketRange. In
    % this way there is less clustering around non-discriminative data
    % points.
    templateArrayShortened = templateArray(maxLocation(chan)+bracketRange,:);

    % data is in "templateArrayShorted". We will initiate a new HDBSCAN instance
    clusterer = HDBSCAN.HDBSCAN( templateArrayShortened');
    
    try
        % (1) directly set the parameters
        %         clusterer.minpts = 2;
        %         clusterer.minclustsize = 3;
        %         clusterer.outlierThresh = 0.95;
        clusterer.minpts = minPts;
        clusterer.minclustsize = minClustSize;
        clusterer.outlierThresh = outlierThresh;
        clusterer.metric = distanceMetricDbscan;
        clusterer.fit_model(); 			% trains a cluster hierarchy
    catch
        % (1) directly set the parameters
        clusterer.minpts = minPts+1;
        clusterer.minclustsize = minClustSize+1;
        clusterer.outlierThresh = outlierThresh;
        clusterer.metric = distanceMetricDbscan;
        clusterer.fit_model(); 			% trains a cluster hierarchy
    end
    clusterer.get_best_clusters(); 	% finds the optimal "flat" clustering scheme
    clusterer.get_membership();		% assigns cluster labels to the points in X
    
    % (2) call run_hdbscan() with optional inputs. This is the prefered/easier method
    %  clusterer.run_hdbscan( 10,20,[],0.85 );
    
    % Let's visualize the condensed cluster tree (the tree without spurious clusters)
    
    labels = clusterer.labels;
    vectorUniq = unique(labels);
    templateArrayExtracted = [];
    
    if sum(vectorUniq) > 0
        for ii = vectorUniq'
            if ii~=0
                meanTempArray = mean(templateArray(:,labels==ii),2);
                templateArrayExtracted = [templateArrayExtracted meanTempArray]; %no subtraction
            end
        end
        % if no good clusters, try just
    else
        warning('Using average of pulses for channel because no points not labelled as outliers')
        templateArrayExtracted = mean(templateArray, 2);
    end
    
    
    templateListVec{chan} = templateArrayShortened;
    
    % assign templates to channel
    templateArrayCellOutput{chan} = templateArrayExtracted;
    
end

txt.Value = vertcat({'--- Finished clustering artifacts ---'}, txt.Value); pause(0.01);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% now do the template subtraction

processedSig = rawSig;
for chan = 1:size(templateArrayCell, 2)
    
    startLoc = cellfun(@(x) x{chan}, startInds, 'UniformOutput', false);
    startLoc = [startLoc{:}];
    endLoc = cellfun(@(x) x{chan}, endInds, 'UniformOutput', false);
    endLoc = [endLoc{:}];

    for trial = 1:size(templateArrayCell{chan}, 2)

        if trial > 1
            firstLoopTrial = 0;
        else
            firstLoopTrial = 1;
        end
        
        win = startLoc(trial):endLoc(trial);
        extractedSig = rawSig(win, chan);
        firstLoopChan = 1;
        templates = templateArrayCellOutput{chan};
            

        extractedSig = extractedSig - mean(extractedSig(1:amntPreAverage));
            
            % find best artifact; align templates to max
            [~, maxIdxLoc] = max(abs(extractedSig));
            maxLocation = maxLocAll(chan);
            
            if maxLocation < maxIdxLoc
                % should only happen when alignment is not chosen
                post = length(extractedSig) - maxIdxLoc;
                pad = zeros(maxIdxLoc - maxLocation, size(templates, 2));
                
                templatesSts = [pad; templates(1:(maxLocation + post), :)];
            else
                post = length(extractedSig) - maxIdxLoc;
                pre = length(extractedSig) - post - 1;

                templatesSts = templates((maxLocation - pre):(maxLocation + post),:);
            end
            
            % make sure the bracket range does not exceed the first or last
            % sample of the template array
            
            sizeTemplates = size(templatesSts);
            bracketRangeMin = maxLocation+bracketRange(1);
            bracketRangeMax = maxLocation+bracketRange(end);
            
            adjustTemplates = false;
            if (bracketRangeMin < 1)
                bracketRangeMin = 0;
                adjustTemplates = true;
            end
            
            if (bracketRangeMax > sizeTemplates(1))
                bracketRangeMax = sizeTemplates(1) - maxLocation;
                adjustTemplates = true;
            end
            
            bracketRangeAdj = bracketRange;
            
            if adjustTemplates
                bracketRangeAdj = bracketRangeMin:bracketRangeMax;% - maxLocation;
            end
            
            if isempty(bracketRangeAdj)
                bracketRangeAdj = 0:size(templatesSts, 1)-1;
                maxLocation = 1;
            end
            
            templatesStsShortened = templatesSts(maxLocation+bracketRangeAdj,:);
            extractedSigShortened = extractedSig(maxLocation+bracketRangeAdj,:);
                               
            sizeTemplates = size(templatesStsShortened,2);
            xcorrMat = zeros(1, sizeTemplates);
            xcorrIdxMat = zeros(1, sizeTemplates);
            for idx = 1:sizeTemplates
                locX = xcorr(extractedSigShortened, templatesStsShortened(:, idx), 'coeff');
                [xcorrMat(idx), xcorrIdxMat(idx)] = max(abs(locX));
            end
            [~, index] = max(xcorrMat);
            shiftBy = xcorrIdxMat(index) - ceil(length(locX)/2);
            
            % shift template if needed to match maximal cross correlation
            if shiftBy < 0
                templateSubtract = [templatesSts((1 - shiftBy):end,index); zeros(-shiftBy, 1)]; 
            elseif shiftBy > 0
                templateSubtract = [zeros(shiftBy, 1); templatesSts(1:(end-shiftBy),index)];
            else
            	templateSubtract = templatesSts(:,index);
            end
            % which template best matched
            if firstLoopChan && firstLoopTrial
                templateSubtractCell{chan} = index;
            else
                templateSubtractCell{chan} = [templateSubtractCell{chan}; index];
            end
            
            [~,templateSubtract] = procrustes(extractedSig,templateSubtract);
                
            scaling = (max(extractedSig) - min(extractedSig))/(max(templateSubtract) ...
                - min(templateSubtract));
            templateSubtract = templateSubtract*scaling;
            
            yshift = processedSig(win(1), chan) - templateSubtract(1);

            templateSubtract = templateSubtract + yshift;

            processedSig(win, chan) = processedSig(win, chan) - templateSubtract + ...
                processedSig(win(1), chan);
                
    end
        
end
end