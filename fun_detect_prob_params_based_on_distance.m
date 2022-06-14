
%
% Given an array of distances and an array of probability distribution objects
% this function fits a linear model based on input arguments.
%
% Input Arguments:
%    argSeqDistances -> Distance(cm) array, Row Vector
%    argSeqPds    -> Probability Distribution object array, Row Vector
%
% Output Values:
%    mdlMeanLM -> Linear model of mean values that fits input mean values
%    mdlStdDevLM -> Linear model of Standard Deviations that fits input std dev values parameters
%
function [ mdlMeanLM, mdlStdDevLM ] = fun_detect_prob_params_based_on_distance(argSeqDistances, argSeqPds)

	%fprintf("\nBEGIN: fun_detect_prob_params_based_on_distance(%s -- size %d and %s -- size %d\n", ...
	%	mat2str(argSeqDistances), length(argSeqDistances), mat2str(argSeqPds), length(argSeqPds));

	if (isempty(argSeqDistances) || isempty(argSeqPds))
		fprintf('both input argument array sizes (%d and %d) should be gt zero',...
			size(argSeqDistances), size(argSeqPds));
		return;
	elseif (length(argSeqDistances) ~= length(argSeqPds))
		fprintf('input argument array lengths (%d and %d) should be equal ', ...
            size(argSeqDistances), size(argSeqPds));
		return;
    end

    mean_vals = zeros(1, length(argSeqPds));
    for i = 1 : length(argSeqPds)
       mean_vals(i) = argSeqPds(i).mu;
    end
    
    stddev_vals = zeros(1, length(argSeqPds));
    for i = 1 : length(argSeqPds)
       stddev_vals(i) = argSeqPds(i).sigma;
    end

	mdlMeanLM = fitlm (argSeqDistances, mean_vals);
    plot (mdlMeanLM);

    mdlStdDevLM = fitlm (argSeqDistances, stddev_vals);
    plot (mdlStdDevLM);

	return;
end
