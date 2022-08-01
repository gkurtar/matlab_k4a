%
% fun_correct_measurements
%
% Given a 2D (w x h) array of depth measurements where w and h are width and height of the
% input image respectively and a 2D (w x h) array of  linear model objects where each model
% represents the mean value of the evaluated probability distribution at the corresponding
% pixel this method returns the corrected measurements.
%
% Input Arguments:
%   argDepthImage            -> Depth Image Data of size (argHeight x argWidth)
%   argWidth                 -> Depth Image Width
%   argHeight                -> Depth Image Height 
%   argMeanLinearModelMatrix -> 2D array of size (argHeight x argWidth) where each element
%								is a linear model object of the corresponding pixel
%
% Output Values:
%   resCorrectedImage        -> Corrected Depth Image Data of size (argHeight x argWidth).
%
function [ resCorrectedImage ] = fun_correct_measurements(argDepthImage, argHeight, argWidth, argMeanLinearModelMatrix)

	fprintf("\nBEGIN: fun_correct_measurements\n");

	if (isempty(argDepthImage) || isempty(argMeanLinearModelMatrix))
		error('both input argument array sizes (%d and %d) should be gt zero',...
			size(argDepthImage), size(argMeanLinearModelMatrix));
	%elseif (isnan(str2double(argWidth)) || isnan(str2double(argHeight)))
	%	error('width (%s) and height (%s) arguments must be an integer', argWidth, argHeight);
	%{
	elseif ((size(argDepthImage, 1) ~= size(argMeanLinearModelMatrix, 1)) || (size(argDepthImage, 1) ~= argHeight * argWidth))
		fprintf('row sizes of input argument matrices (%d and %d) should be equal and match height argument (%d) ', ...
            size(argDepthImage, 1), size(argMeanLinearModelMatrix, 1));
	elseif ((size(argDepthImage, 2) ~= size(argMeanLinearModelMatrix, 2)) || (size(argDepthImage, 2) ~= 3))
		fprintf('column sizes of input argument matrices (%d and %d) should be equal and match width argument (%d) ', ...
            size(argDepthImage, 1), size(argMeanLinearModelMatrix, 1));
	%}
	else
		fprintf("going to correct depth data");
	end
	
	resCorrectedImage=zeros(argHeight, argWidth);
	
	for i = 1 : argHeight
		for j = 1 : argWidth
			%{
			rowIndex = (i - 1) * argWidth + j;
			org_depth = argDepthImage(rowIndex, 3); %assign z val
			mean_lm = argMeanLinearModelMatrix(rowIndex, 3); %find linear model
			
			if (org_depth == 0 || mean_lm == 0)
				revised_depth = org_depth;
			else
				revised_depth = predict(mean_lm, org_depth);
			end
			
			resCorrectedImage(rowIndex, 1) = j;
			resCorrectedImage(rowIndex, 2) = i;
			resCorrectedImage(rowIndex, 3) = int32(revised_depth);
			%}
			
			org_depth = argDepthImage(i, j); %assign z val
			mean_lm = argMeanLinearModelMatrix{i, j}; %find linear model
			
			%if (org_depth == 0 || mean_lm == 0)
			if (org_depth == 0)
				revised_depth = org_depth;
			else
				revised_depth = predict(mean_lm, org_depth);
			end

			resCorrectedImage(i, j) = int32(revised_depth);
		end
	end
	
	fprintf("\nEND: fun_correct_measurements\n");
	return;
end