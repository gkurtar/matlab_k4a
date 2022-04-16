

%
% Given a w x h x 3 vector of depth measurements where w and h are width and height of the
% input image respectively and w x h x 3 vector of linear model objects where each model
% represents the mean value of the evaluated probability distribution at the corresponding
% pixel this method returns the corrected measurements.
%
% Input Arguments:
%    depthImage     -> Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    imageWidth     -> Depth Image Width
%    imageHeight    -> Depth Image Height 
%    vecLinearModels -> w x h x 3 vector of linear models
%
% Output Values:
%    correctedImage -> w x h x 3 vector of corrected depth measurements
%
function [ correctedImage ] = fun_correct_measurements(depthImage, imageWidth, imageHeight, vecLinearModels)

	fprintf("\nBEGIN: fun_correct_measurements");

	if (isempty(depthImage) || isempty(argLinearModels))
		error('both input argument array sizes (%d and %d) should be gt zero',...
			size(depthImage), size(argLinearModels));
	elseif (isnan(str2double(imageWidth)) || isnan(str2double(imageHeight)))
		error('width (%s) and height (%s) arguments must be an integer', imageWidth, imageHeight);
	elseif ((size(depthImage, 1) ~= size(vecLinearModels, 1)) || (size(depthImage, 1) ~= imageHeight * imageWidth))
		fprintf('row sizes of input argument matrices (%d and %d) should be equal and match height argument (%d) ', ...
            size(depthImage, 1), size(vecLinearModels, 1));
	elseif ((size(depthImage, 2) ~= size(vecLinearModels, 2)) || (size(depthImage, 2) ~= 3))
		fprintf('column sizes of input argument matrices (%d and %d) should be equal and match width argument (%d) ', ...
            size(depthImage, 1), size(vecLinearModels, 1));
	else
		fprintf('going to correct depth data');
	end
	
	correctedImage=zeros(imageHeight * imageWidth, 3);
	
	for i = 1 : imageHeight
		for j = 1 : imageWidth
			rowIndex = (i - 1) * imageWidth + j;
			org_depth = depthImage(rowIndex, 3); %assign z val
			mean_lm = vecLinearModels(rowIndex, 3); %find linear model
			
			if (org_depth == 0 || mean_lm == 0)
				revised_depth = org_depth;
			else
				revised_depth = predict(mean_lm, org_depth);
			end
			
			correctedImage(rowIndex, 1) = j;
			correctedImage(rowIndex, 2) = i;
			correctedImage(rowIndex, 3) = int32(revised_depth);	
		end
	end
	
	fprintf("\nEND: fun_correct_measurements");
	return;
end