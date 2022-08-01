% ******************************************************************
% fun_inspect_errors
%
% Compares measured depth values and corresponding ground truth values and 
% shows the figure for the errors based on distance by scatter function.
% Also finds statistics for the depth measurement errors such as rmse and stdev and prints them.
% 
% INPUT:
%   argSeqOfDepthImageMatrices		-> a cell array where each element is a 2D array of measured depth values 
%   argSeqOfGroundTruthImageMatrices	-> a cell array where each element is a 2D array of ground truth values of the corresponding measurements 
%
% ******************************************************************
function fun_inspect_errors(argSeqOfDepthImageMatrices, argSeqOfGroundTruthImageMatrices)

	fprintf("\nBEGIN: fun_inspect_errors\n");
	

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

	szMatData = size(argSeqOfDepthImageMatrices{1});
	rowCount = szMatData(1, 1);
	colCount = szMatData(1, 2);

	fprintf("rows: %d, cols: %d", rowCount, colCount);
	
	seqDiffValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	index = 0;
	
	for i = 1 : numel(argSeqOfDepthImageMatrices)
		matDepthImage = argSeqOfDepthImageMatrices{i};
		matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
		
		baseIndex = (i - 1) * rowCount * colCount;
		
		for (j = 1 : rowCount)
			for (k = 1 : colCount)
				index = (j - 1) * colCount + k;
				if (matDepthImage(j, k) == matGroundTruth(j, k))
					continue;
				elseif (isequal(0, matDepthImage(j, k)) || isequal(0, matGroundTruth(j, k)) )
					continue;
				elseif (matDepthImage(j, k) / matGroundTruth(j, k) < 0.8 || matDepthImage(j, k) / matGroundTruth(j, k) > 1.2 )
					continue;
				end
				seqDiffValues(1, baseIndex + index) = matDepthImage(j, k) - matGroundTruth(j, k);
				seqGroundTruthValues(1, baseIndex + index) = matGroundTruth(j, k);
				seqMeasuredDepthValues(1, baseIndex + index) = matDepthImage(j, k);
			end
		end
		
		%matDiff = matDepthImage - matGroundTruth;
		%seqMatDiff{i} = matDiff;
	end
	
	%[resMaxError, resRmse, resSdev] = fun_detect_error_stats(seqMeasuredDepthValues, seqGroundTruthValues);
	%diff_data = argMeasuredDepthValues - argRealDepthValues;
	
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
	scatter(seqGroundTruthValues, seqDiffValues);
	xlabel("Distance");
	ylabel("Error");
	xlim([0, max(seqMeasuredDepthValues) * 1.25]);
	ylim([-3 * maxErrorVal, 3 * maxErrorVal]);
	ax = gca;
	ax.XAxisLocation = "origin";
	ax.YAxisLocation = "origin";

	fprintf("\nEND: fun_inspect_errors\n");
	return;
end
