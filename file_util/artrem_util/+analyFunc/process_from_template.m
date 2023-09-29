function [processedSig, chck] = process_from_template(rawSig, txt, ...
    distanceMetricDbscan, bracketRange, templateArrayCell, ...
    startInds, endInds, maxLocation)

% This function performs the dictionary method with the given distance
% metric and bracket range when provided with all template information

%% build up dictionary
processedSig = analyFunc.template_dictionary(templateArrayCell, rawSig, txt, ...
    distanceMetricDbscan, startInds, endInds, maxLocation, bracketRange);
    
%% check removal quality

txt.Value = vertcat({'--- Checking removal quality ---'}, txt.Value); pause(0.01);
chck = analyFunc.assess_removal(processedSig, startInds, endInds);
txt.Value = vertcat({'--- Artifact removal complete! ---'}, txt.Value); pause(0.01);


end

