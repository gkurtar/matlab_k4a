%*******************************************************************************************
%
% This function returns Ground Truth
%
% Input Arguments:
%    argDepthDataFile	-> full file path of the depth data (point cloud)
%    argDepthDataSize   -> a 1x2 vector denoting the size ( row and col count) of the depth data image matrix
%
% Output Values:
%    resGroundTruth		-> Ground Truth
%
%*******************************************************************************************
function [ resGroundTruth ] = fun_get_ground_truth(argDepthDataFilePath, argDepthDataSize, argFrameDistance)

	fprintf("\nBEGIN: fun_get_ground_truth\n");
	
	img_height = argDepthDataSize(1);
	img_width = argDepthDataSize(2);

	depthData = fun_read_point_cloud_data(argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));

    pointPositions = importdata(fullfile(argDepthDataFilePath));
    
    figure;
    ptCloud = pointCloud(pointPositions);
    pcshow(ptCloud);
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title('Original Point Cloud');

    roi_x_min = 0;
    roi_x_max = argDepthDataSize(2);
    roi_y_min = 0;
    roi_y_max = argDepthDataSize(1);
    roi_z_min = argFrameDistance - (argFrameDistance / 10);
    roi_z_max = argFrameDistance + (argFrameDistance / 10);
    
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
	title('Derinlik verisi icin en uygun duzlem');
	hold on;
	plot(fittedPlaneModel);
	hold off;
	
	%--------------------------------------------------------------------------
	%------------------ Compute Diff and rmse for both ------------------------
   
	FITTED_DATA=zeros(img_height, img_width);
	REAL_TO_FITTED_DIFF=zeros(img_height, img_width); %diff between real and fitted
   
	colIndex = 3;
	diffBtwRealDepthAndFitted = 0;
	sumOfSqOfDiffsBtwDepthAndFitted = 0;
   
	sumResidualReal=0;

	for i = 1:img_height
	  for j = 1:img_width

         rowIndex = (i - 1) * img_width + j;
      
	     if (i >= roi_y_min && i <= roi_y_max ...
	        && j >= roi_x_min && j <= roi_x_max)
		 
		    FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
			FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
			
		    if (pointPositions(rowIndex, colIndex) ~= 0)
			   diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - pointPositions(rowIndex, colIndex);
		       %REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
		    else
			   diffBtwRealDepthAndFitted = 0;
		    end

	     else
	        FITTED_DATA(i, j) = 0;
		    diffBtwRealDepthAndFitted = 0;
	     end

	     REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
		 sumResidualReal = sumResidualReal + diffBtwRealDepthAndFitted;

	     %fprintf("%d \t %d \t %d \t %7.4f \t %4.4f \n", ...
		%	   i, j, pointPositions(rowIndex, colIndex), ...
		%	   FITTED_DATA(i, j), diffBtwRealDepthAndFitted);
		end
	end
	
    fprintf("\nEND: fun_get_ground_truth\n");
	return;
end
