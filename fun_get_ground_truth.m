%*******************************************************************************************
%
% This function returns Ground Truth
%
% Input Arguments:
%    argDepthDataFile	-> full file path of the depth data (point cloud)
%    argHeight          -> depth data matrix height
%    argWidth           -> depth data matrix width
%    argDistance        -> Distance of the planar board in mm
%
% Output Values:
%    resGroundTruth		-> Ground Truth
%
%*******************************************************************************************
function [ resGroundTruth ] = fun_get_ground_truth(argDepthDataFilePath, argHeight, argWidth, argDistance)

	fprintf("\nBEGIN: fun_get_ground_truth\n");
	
	%img_height = argDepthDataSize(1);
	%img_width = argDepthDataSize(2);
	resGroundTruth = zeros(argHeight, argWidth);
    resGroundTruthPc = zeros(argHeight * argWidth, 3);
    pointPositions = importdata(fullfile(argDepthDataFilePath));
    
    figure;
    ptCloud = pointCloud(pointPositions);
    pcshow(ptCloud, 'VerticalAxis', 'X');
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title('Original Point Cloud');

    roi_x_min = 0;
    roi_x_max = argWidth;
    roi_y_min = 0;
    roi_y_max = argHeight;
    roi_z_min = argDistance - (argDistance / 10);
    roi_z_max = argDistance + (argDistance / 10);
    
    roi_vector = [roi_x_min, roi_x_max; roi_y_min, roi_y_max; roi_z_min, roi_z_max];

    sampleIndicesOfROI = findPointsInROI(ptCloud, roi_vector);

    [fittedPlaneModel, inlierIndices, outlierIndices] = pcfitplane(ptCloud, 10, 'SampleIndices', sampleIndicesOfROI);
    pointCloudNearPlane = select(ptCloud, inlierIndices);

    x_plmdl = fittedPlaneModel.Parameters(1);
    y_plmdl = fittedPlaneModel.Parameters(2);
    z_plmdl = fittedPlaneModel.Parameters(3);
    delta_val_plmdl = fittedPlaneModel.Parameters(4);

    fprintf ("\nOrg Data fitted plane model parameters are\n\t");
    fprintf ("%f ", fittedPlaneModel.Parameters);

	figure;
	pcshow(pointCloudNearPlane);
	title('Optimum fitted plane');
	hold on;
	plot(fittedPlaneModel);
	hold off;
	
	%--------------------------------------------------------------------------
	%------------------ FIT PLANE ------------------------
   
	FITTED_DATA=zeros(argHeight, argWidth);
	REAL_TO_FITTED_DIFF=zeros(argHeight, argWidth); %diff between real and fitted
   
	colIndex = 3;
	diffBtwRealDepthAndFitted = 0;

	for i = 1:argHeight
		for j = 1:argWidth

			rowIndex = (i - 1) * argWidth + j;
			orgDepthVal = pointPositions(rowIndex, colIndex);
			 
			if (orgDepthVal < argDistance + argDistance / 10 && orgDepthVal > argDistance - argDistance / 10)
				FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
				FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
				diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - pointPositions(rowIndex, colIndex);
            else
				FITTED_DATA(i, j) = orgDepthVal;
				diffBtwRealDepthAndFitted = 0;
            end
			
			REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
			%{
			if (i >= roi_y_min && i <= roi_y_max ...
				&& j >= roi_x_min && j <= roi_x_max)
			 
				FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
				FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
				
				if (pointPositions(rowIndex, colIndex) ~= 0)
				   diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - pointPositions(rowIndex, colIndex);
				else
				   diffBtwRealDepthAndFitted = 0;
				end

			else
				FITTED_DATA(i, j) = 0;
				diffBtwRealDepthAndFitted = 0;
			end

			REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;

			%fprintf("%d \t %d \t %d \t %7.4f \t %4.4f \n", ...
			%	   i, j, pointPositions(rowIndex, colIndex), ...
			%	   FITTED_DATA(i, j), diffBtwRealDepthAndFitted);
			%}
			
			resGroundTruthPc(rowIndex, 1) = i;
			resGroundTruthPc(rowIndex, 2) = j;
			resGroundTruthPc(rowIndex, 3) = FITTED_DATA(i, j);
			
			resGroundTruth(i, j) = FITTED_DATA(i, j);
		end
	end

	figure;
	pcshow(resGroundTruthPc, 'VerticalAxis', 'X');
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title('Ground Truth');
	
	figure;
	imagesc(REAL_TO_FITTED_DIFF);
	title('diff');
	
    fprintf("\nEND: fun_get_ground_truth\n");
	return;
end