% ***********************************************************
% 
% fun_k4a_find_depth_error_distribution function
% K4A Depth Camera Error Distribution is evaluated and plotted by this function
% 
% INPUT:
%
%   argSeqOfDepthImageMatrices			-> an array of ..
%   argSeqOfGroundTruthImageMatrices	-> an array of ...
%
% **********************************************************
function [seqDiffValues, seqGroundTruthValues] = fun_k4a_find_depth_error_distribution(...
	argSeqOfDepthImageMatrices, argSeqOfGroundTruthImageMatrices)

	fprintf("\nBEGIN: fun_k4a_find_depth_error_distribution\n");
	fprintf("\nArgument Checking: \n");

	if (~iscell(argSeqOfDepthImageMatrices) || ~iscell(argSeqOfGroundTruthImageMatrices))
		error("sdf 1");
	end

	if (numel(argSeqOfDepthImageMatrices) ~= numel(argSeqOfGroundTruthImageMatrices) ...
		|| numel(argSeqOfGroundTruthImageMatrices) == 0)
		warningMessage = sprintf("Warning: sdf:%s\n", numel(argSeqOfDepthImageMatrices));
		%uiwait(msgbox(warningMessage));
		error("sdf");
	end

	for i = 1 : numel(argSeqOfDepthImageMatrices)
		matDepthImage = argSeqOfDepthImageMatrices{i};
		matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
		
		if (~ismatrix(matDepthImage) || ~ismatrix(matGroundTruth))
			error("sdf 2");
		end
		
		szDepth = size(matDepthImage)
        disp("sdf");
		szGrTuth = size(matGroundTruth)
		
		if (numel(szDepth) ~= 2 || numel(szGrTuth) ~= 2 || ~isequal(size(matDepthImage), size(matGroundTruth)))
			error("sdf 3");
		end
	end

	seqMatDiff = {};
	
	szMatData = size(argSeqOfDepthImageMatrices{1});
    
	rowCount = szMatData(1, 1);
	colCount = szMatData(1, 2);

    	fprintf("rows: %d, cols: %d", rowCount, colCount);
	
	seqDiffValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
    	size(seqDiffValues);
	index = 0;
	
	for i = 1 : numel(argSeqOfDepthImageMatrices)
		matDepthImage = argSeqOfDepthImageMatrices{i};
		matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
		
		baseIndex = (i - 1) * rowCount * colCount;
		
		for (j = 1 : rowCount)
			for (k = 1 : colCount)
				index = (j - 1) * colCount + k;
				seqDiffValues(1, baseIndex + index) = matDepthImage(j, k) - matGroundTruth(j, k);
				seqGroundTruthValues(1, baseIndex + index) = matGroundTruth(j, k);
				seqMeasuredDepthValues(1, baseIndex + index) = matDepthImage(j, k);
			end
		end
		
		%matDiff = matDepthImage - matGroundTruth;
		%seqMatDiff{i} = matDiff;
	end
	
	[resMaxError, resRmse, resSdev] = fun_detect_error_stats(seqMeasuredDepthValues, seqGroundTruthValues);
	
	fprintf("\nFind diff values and plot them: \n");
	
    	scatter(seqGroundTruthValues, seqDiffValues);
	xlabel("Distance");
	ylabel("Error");
    	xlim([0, max(seqMeasuredDepthValues) * 1.25]);
    	ylim([-3 * resMaxError, 3 * resMaxError]);
    	ax = gca;
    	ax.XAxisLocation = "origin";
    	ax.YAxisLocation = "origin";

	fprintf("\nEND: fun_k4a_find_depth_error_distribution\n");
	return;
end
