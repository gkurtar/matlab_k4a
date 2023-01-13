% ******************************************************************
% fun_inspect_errors
%
% Compares measured depth values and corresponding ground truth values and 
% shows the figure for the errors based on distance by scatter function.
% Also finds statistics for the depth measurement errors such as rmse and stdev and prints them.
% 
% INPUT:
%   argDepthImage		 -> a 2D array of measured depth values 
%   argGroundTruthImage  -> a 2D array of ground truth values of the corresponding measurements
%   argRoiVector         -> ROI vector 
%   argFileID            -> file handle
%
% OUTPUT:
%   resDiffData          -> Diff between Depth Data argument and Ground Truth Data
%
% ******************************************************************
function [ resDiffData ] = fun_inspect_errors(argDepthImage, argGroundTruthImage, argRoiVector, argFileID)

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
		error("Each element should be a matrix.");
	end
	
	szDepth = size(argDepthImage);
	szGrTuth = size(argGroundTruthImage);
	
	if (numel(szDepth) ~= 2 || numel(szGrTuth) ~= 2 || ~isequal(size(argDepthImage), size(argGroundTruthImage)))
		error("Matrix dimensions should be equal and size of each matrix must have two elements.");
	end

	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to compare depth data argument and corresponding ground truth data\n");

	szMatData = size(argDepthImage);
	rowCount = szMatData(1);
	colCount = szMatData(2);
	
	roi_x_min = argRoiVector(1);
	roi_x_max = argRoiVector(2);
	roi_y_min = argRoiVector(3);
	roi_y_max = argRoiVector(4);

	%fprintf("rows: %d, cols: %d", rowCount, colCount);
	
	%seqDiffValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	%seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	%seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2) * numel(argSeqOfDepthImageMatrices));
	
	%for i = 1 : numel(argSeqOfDepthImageMatrices)
	%	matDepthImage = argSeqOfDepthImageMatrices{i};
	%	matGroundTruth = argSeqOfGroundTruthImageMatrices{i};
	%	baseIndex = (i - 1) * rowCount * colCount;
	
	%seqDiffValues = zeros(1, szMatData(1) * szMatData(2));
	%seqGroundTruthValues = zeros(1, szMatData(1) * szMatData(2));
	%seqMeasuredDepthValues = zeros(1, szMatData(1) * szMatData(2));
	
	seqDiffValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	seqGroundTruthValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	seqMeasuredDepthValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	
	index = 0;
	evalIndex = 0;
	
	resDiffData = zeros(rowCount, colCount); %diff between depth data and ground truth
	
	for (j = 1 : rowCount)
		for (k = 1 : colCount)

			%fprintf(argDiffFileId, "Row: %d, Col: %d, depth: %d, gt: %d, diff: %d\n",...
			%		j, k, argDepthImage(j, k), argGroundTruthImage(j, k), ...
			%		argDepthImage(j, k) - argGroundTruthImage(j, k) 	);
			
			if (k < roi_x_min || k > roi_x_max || j < roi_y_min || j > roi_y_max )
				continue;
			end;
			
			evalIndex = evalIndex + 1;
			
			if (argDepthImage(j, k) == argGroundTruthImage(j, k))
				continue;
			elseif (isequal(0, argDepthImage(j, k)) || isequal(0, argGroundTruthImage(j, k)) )
				continue;
			%elseif (argDepthImage(j, k) / argGroundTruthImage(j, k) < 0.5 || argDepthImage(j, k) / argGroundTruthImage(j, k) > 1.8 )
			elseif ( abs( argDepthImage(j, k) - argGroundTruthImage(j, k) ) >  250)
				continue;
			end
			
			resDiffData(j, k) = argDepthImage(j, k) - argGroundTruthImage(j, k);
			
			%%seqDiffValues(1, index) = argDepthImage(j, k) - argGroundTruthImage(j, k);
			%seqDiffValues(1, index) = abs( argDepthImage(j, k) - argGroundTruthImage(j, k) );
			%seqGroundTruthValues(1, index) = argGroundTruthImage(j, k);
			%seqMeasuredDepthValues(1, index) = argDepthImage(j, k);
			
			seqDiffValues(1, evalIndex) = abs( argDepthImage(j, k) - argGroundTruthImage(j, k) );
			seqGroundTruthValues(1, evalIndex) = argGroundTruthImage(j, k);
			seqMeasuredDepthValues(1, evalIndex) = argDepthImage(j, k);
			

			% logging is done here
			%if (mod(j, 10) == 0 && mod(k, 10) == 0)
			%	fprintf(argFileID, "Row: %d, Col: %d, check: %d, gt: %f, diff: %d\n",...
			%		j, k, argDepthImage(j, k), argGroundTruthImage(j, k), resDiffData(j, k));
			%end
		end
	end
	%end
	
	%compute for real to fitted diff matrix
	minVal = min(seqDiffValues);
	maxVal = max(seqDiffValues);
	%maxErrorVal = max(abs(minVal), abs(maxVal));
	maxErrorVal = max(minVal, maxVal);
	MEANVAL = mean(seqDiffValues);
	SQE = seqDiffValues.^2;
	MSE = mean(SQE(:));
	RMSE = sqrt(MSE);
	SDEV = std(seqDiffValues(:));
	
	fprintf ("\nMin diff is %f max_diff is %f, diff vector size %d, measured %d ", minVal, maxVal, length(seqDiffValues), evalIndex);
	fprintf ("\nDepth Residual Stats are:\n\tMax_error: %f\tMEAN: %f\tMSE: %f\tRMSE: %f\tSTD DEV: %f", ...
		maxErrorVal, MEANVAL, MSE, RMSE, SDEV);
	
	fprintf (argFileID, "\nMin diff is %f Max diff is %f ", minVal, maxVal);
	fprintf (argFileID, "\nDepth Values Comparison Stats:");
	fprintf (argFileID, "\nMax_error: %f\nMEAN: %f\nMSE: %f\nRMSE: %f\nSTD DEV: %f", maxErrorVal, MEANVAL, MSE, RMSE, SDEV);

%{
	figure;
	fprintf("\nFind diff values and plot them: \n");
	scatter(seqGroundTruthValues, seqDiffValues, '+');
	xlabel("Distance (mm)");
	ylabel("Error (mm)");
	xlim([0, max(seqMeasuredDepthValues) * 1.25]);
	ylim([-2 * maxErrorVal, 2 * maxErrorVal]);
	title('Errors based on the distance');
	ax = gca;
	ax.XAxisLocation = "origin";
	ax.YAxisLocation = "origin";
%}	
	
	% {
	figure;
	imagesc(resDiffData);
	xlabel('X(px)');
	ylabel('Y(px)');
	colorbar('southoutside');
	title('Residuals (mm)');
	% }

	fprintf("\nEND: fun_inspect_errors\n");
	return;
end
