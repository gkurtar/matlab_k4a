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
%	argDistance          -> Distance of the plane
%   argRoiVector         -> ROI vector 
%   argFileID            -> file handle
%
% OUTPUT:
%   resDiffData          -> Diff between Depth Data argument and Ground Truth Data
%
% ******************************************************************
function [ resDiffData, resDiffDataComparedWithDistance ] = fun_inspect_errors(argDepthImage, argGroundTruthImage, argDistance, argRoiVector, argFileID)

	fprintf("\nBEGIN: fun_inspect_errors\n");
	
	
	if (~ismatrix(argDepthImage) || ~ismatrix(argGroundTruthImage))
		error("Each element should be a matrix.");
	end
	
	szDepth = size(argDepthImage);
	szGrTuth = size(argGroundTruthImage);
	
	if (numel(szDepth) ~= 2 || numel(szGrTuth) ~= 2 || ~isequal(szDepth, szGrTuth))
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

	
	seqDiffValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	seqGroundTruthValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	seqMeasuredDepthValues = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	
	seqDiffValuesComparedWithDistance = zeros(1, (roi_x_max - roi_x_min + 1) * (roi_y_max - roi_y_min + 1));
	
	index = 0;
	evalIndex = 0;
	
	resDiffData = zeros(rowCount, colCount); %diff between depth data and ground truth
	resDiffDataComparedWithDistance = zeros(rowCount, colCount); %diff between depth data and ground truth (distance)
	
	for (j = 1 : rowCount)
		for (k = 1 : colCount)

			if (k < roi_x_min || k > roi_x_max || j < roi_y_min || j > roi_y_max )
				continue;
			end;
			
			evalIndex = evalIndex + 1;
			
			if (argDepthImage(j, k) == argGroundTruthImage(j, k))
				continue;
			elseif (isequal(0, argDepthImage(j, k)) || isequal(0, argGroundTruthImage(j, k)) )
				continue;
			%elseif ( abs( argDepthImage(j, k) - argGroundTruthImage(j, k) ) >  250)
			%	continue;
			end
			
			resDiffData(j, k) = argDepthImage(j, k) - argGroundTruthImage(j, k);
			resDiffDataComparedWithDistance(j, k) = argDepthImage(j, k) - argDistance;
			
			seqDiffValues(1, evalIndex) = abs( argDepthImage(j, k) - argGroundTruthImage(j, k) );
			seqGroundTruthValues(1, evalIndex) = argGroundTruthImage(j, k);
			seqMeasuredDepthValues(1, evalIndex) = argDepthImage(j, k);

			seqDiffValuesComparedWithDistance(1, evalIndex) = abs( argDepthImage(j, k) - argDistance );

		end
	end
	%end
	
	%compute for real to fitted diff matrix
	minVal = min(seqDiffValues);
	maxVal = max(seqDiffValues);
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


	%---------------------------------------------------
	% diff values compared to distance
	%---------------------------------------------------
	minVal = min(seqDiffValuesComparedWithDistance);
	maxVal = max(seqDiffValuesComparedWithDistance);
	maxErrorVal = max(minVal, maxVal);
	MEANVAL = mean(seqDiffValuesComparedWithDistance);
	SQE = seqDiffValuesComparedWithDistance.^2;
	MSE = mean(SQE(:));
	RMSE = sqrt(MSE);
	SDEV = std(seqDiffValuesComparedWithDistance(:));
	
	fprintf ("\nMin diff is %f max_diff is %f, diff vector size %d, measured %d ",...
			minVal, maxVal, length(seqDiffValuesComparedWithDistance), evalIndex);
	fprintf ("\nDepth Residual Stats are:\n\tMax_error: %f\tMEAN: %f\tMSE: %f\tRMSE: %f\tSTD DEV: %f", ...
		maxErrorVal, MEANVAL, MSE, RMSE, SDEV);
	
	fprintf (argFileID, "\nDiff values evaluated by assuming ground truth values as distance %d ", argDistance);
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
