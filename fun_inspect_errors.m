% ******************************************************************
% fun_inspect_errors
%
% Compares measured depth values and corresponding ground truth values and 
% shows the figure for the errors based on distance by scatter function.
% Also finds statistics for the depth measurement errors such as rmse and stdev and prints them.
% 
% INPUT:
%   argSeqOfDepthImageMatrices		 -> a cell array where each element is a 2D array of measured depth values 
%   argSeqOfGroundTruthImageMatrices -> a cell array where each element is a 2D array of ground truth values of the corresponding measurements 
%   argFileID                        -> file handle
%
% ******************************************************************
function fun_inspect_errors(argDepthImage, argGroundTruthImage, argFileID)

	fprintf("\nBEGIN: fun_inspect_errors\n");
	
	%{
	if (~iscell(argSeqOfDepthImageMatrices) || ~iscell(argSeqOfGroundTruthImageMatrices))
		error("Each argument must be a cell-array");
	end

	if (numel(argSeqOfDepthImageMatrices) ~= numel(argSeqOfGroundTruthImageMatrices) ...
		|| numel(argSeqOfGroundTruthImageMatrices) == 0)
		warningMessage = sprintf("Element count of the arguments should be equal and gt zero: %d, %d\n", ...
				numel(argSeqOfDepthImageMatrices), numel(argSeqOfGroundTruthImageMatrices));
		error(warningMessage);
	end
	
	for i = 1 : numel(argSeqOfDepthImageMatrices)
		matDepthImage = argSeqOfDepthImageMatrices{i};
		matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
		
		if (~ismatrix(matDepthImage) || ~ismatrix(matGroundTruth))
			error("Each cell-array element should be a matrix.");
		end
		
		szDepth = size(matDepthImage);
		%disp("sdf");
		szGrTuth = size(matGroundTruth);
		
		if (numel(szDepth) ~= 2 || numel(szGrTuth) ~= 2 || ~isequal(size(matDepthImage), size(matGroundTruth)))
			error("Matrix dimensions should be equal and size of each matrix must have two elements.");
		end
	end
	%}
	
	if (~ismatrix(argDepthImage) || ~ismatrix(argGroundTruthImage))
		error("Each cell-array element should be a matrix.");
	end
	
	szDepth = size(argDepthImage);
	szGrTuth = size(argGroundTruthImage);
	
	if (numel(szDepth) ~= 2 || numel(szGrTuth) ~= 2 || ~isequal(size(argDepthImage), size(argGroundTruthImage)))
		error("Matrix dimensions should be equal and size of each matrix must have two elements.");
	end

	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to compare depth data argument and corresponding ground truth data");

	%{
	szMatData = size(argSeqOfDepthImageMatrices{1});
	rowCount = szMatData(1, 1);
	colCount = szMatData(1, 2);
	%}
	szMatData = size(argDepthImage);
	rowCount = szMatData(1);
	colCount = szMatData(2);

	fprintf("rows: %d, cols: %d", rowCount, colCount);
	
	%seqDiffValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	%seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	%seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	
	seqDiffValues = zeros(1, szMatData(1) * szMatData(2));
	seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2));
	seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2));
	index = 0;
	
	%for i = 1 : numel(argSeqOfDepthImageMatrices)
	%	matDepthImage = argSeqOfDepthImageMatrices{i};
	%	matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
		
	%	baseIndex = (i - 1) * rowCount * colCount;
		
	for (j = 1 : rowCount)
		for (k = 1 : colCount)
			index = (j - 1) * colCount + k;
			if (argDepthImage(j, k) == argGroundTruthImage(j, k))
				continue;
			elseif (isequal(0, argDepthImage(j, k)) || isequal(0, argGroundTruthImage(j, k)) )
				continue;
			elseif (argDepthImage(j, k) / argGroundTruthImage(j, k) < 0.8 || argDepthImage(j, k) / argGroundTruthImage(j, k) > 1.2 )
				continue;
			end
			seqDiffValues(1, index) = argDepthImage(j, k) - argGroundTruthImage(j, k);
			seqGroundTruthValues(1, index) = argGroundTruthImage(j, k);
			seqMeasuredDepthValues(1, index) = argDepthImage(j, k);
		end
	end
		
	%end
	
	%compute for real to fitted diff matrix
	minVal = min(seqDiffValues);
	maxVal = max(seqDiffValues);
	maxErrorVal = max(abs(minVal), abs(maxVal));
	SQE = seqDiffValues.^2;
	MSE = mean(SQE(:));
	RMSE = sqrt(MSE);
	SDEV = std(seqDiffValues(:));
	
	fprintf ("\nMin diff is %f max_diff is %f ", minVal, maxVal);
	fprintf ("\nDepth Residual Stats are:\n\tmax_error %f, mse %f, rmse %f, std_dev: %f", maxErrorVal, MSE, RMSE, SDEV);

	figure;
	fprintf("\nFind diff values and plot them: \n");
	scatter(seqGroundTruthValues, seqDiffValues, '+');
	xlabel("Distance");
	ylabel("Error");
	xlim([0, max(seqMeasuredDepthValues) * 1.25]);
	ylim([-2 * maxErrorVal, 2 * maxErrorVal]);
	ax = gca;
	ax.XAxisLocation = "origin";
	ax.YAxisLocation = "origin";

	fprintf("\nEND: fun_inspect_errors\n");
	return;
end
