%*******************************************************************************************
%
% This function returns Ground Truth
%
% Input Arguments:
%    argDepthDataFilePath -> full file path of the depth data (point cloud)
%    argHeight            -> depth data matrix height
%    argWidth             -> depth data matrix width
%    argDistance          -> Distance of the planar board in mm
%    argFileID            -> file handle
%
% Output Values:
%    resGroundTruth       -> Ground Truth Depth Data in matrix form
%
%*******************************************************************************************

function [ resGroundTruth ] = fun_get_ground_truth(argDepthDataFilePath, argHeight, argWidth, argDistance, argDisplayFlag, argFileID)

	fprintf("\nBEGIN: fun_get_ground_truth\n");
	
	resGroundTruth = zeros(argHeight, argWidth);
    resGroundTruthPc = zeros(argHeight * argWidth, 3);
    pointPositions = importdata(fullfile(argDepthDataFilePath));
	
	pointPositions = filloutliers(pointPositions, 'previous'); %'nearest','mean');	
    ptCloud = pointCloud(pointPositions);

	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to generate ground truth data for the depth data provided");
	fprintf(argFileID, "\nFile path is %s, size is (%d x %d) and the plane distance is %d.", ...
		argDepthDataFilePath, argWidth, argHeight, argDistance);

% { 
	if (argDisplayFlag)
		[fPath, fName, fExt] = fileparts(argDepthDataFilePath);
		%strTitle = sprintf("Point Cloud for %s", fName);
		strTitle = fName; 
		figure;   
		pcshow(ptCloud, 'VerticalAxis', 'X', 'VerticalAxisDir', 'Down' );
		xlabel('X(px)');
		ylabel('Y(px)');
		zlabel('Z(mm)');
		title(strTitle);
	end
% }

    %roi_x_min = 240; roi_x_max = 390;
    %roi_y_min = 190; roi_y_max = 297;
	
	roiVector = [280, 370, 225, 290]; % x1, x2, y1, y2 => x is width, y is height
	%roiVector = [0, argWidth, 0, argHeight]; % x1, x2, y1, y2 => x is width, y is height
	
	roi_x_min = roiVector(1);
	roi_x_max = roiVector(2);
    roi_y_min = roiVector(3);
	roi_y_max = roiVector(4);
    %roi_z_min = argDistance - 200 ;%(argDistance / 100);
    %roi_z_max = argDistance + 200; % (argDistance / 100);
	roi_z_min = argDistance - round( argDistance / 100);
    roi_z_max = argDistance + round( argDistance / 100);
	
	
    roi_vector = [roi_x_min, roi_x_max; roi_y_min, roi_y_max; roi_z_min, roi_z_max];

    sampleIndicesOfROI = findPointsInROI(ptCloud, roi_vector);

    [fittedPlaneModel, inlierIndices, outlierIndices] = pcfitplane(ptCloud, 1, 'SampleIndices', sampleIndicesOfROI);
    pointCloudNearPlane = select(ptCloud, inlierIndices);
	%[fittedPlaneModel] = pcfitplane(ptCloud, 1, [0 0 1]);

    x_plmdl = fittedPlaneModel.Parameters(1);
    y_plmdl = fittedPlaneModel.Parameters(2);
    z_plmdl = fittedPlaneModel.Parameters(3);
    delta_val_plmdl = fittedPlaneModel.Parameters(4);
	
	%{
	x_plmdl = 0;
    y_plmdl = 0;
    z_plmdl = 1;
    delta_val_plmdl = argDistance * -1;
	%}
	
    fprintf ("\nOrg Data fitted plane model parameters are\n\t");
    fprintf ("%f ", fittedPlaneModel.Parameters);
	
	fprintf(argFileID, "\nFitted Plane Model parameters are found as: ");
	fprintf (argFileID, "%f ", fittedPlaneModel.Parameters);
	
	%{
	figure;
	pcshow(pointCloudNearPlane);
	title('Optimum fitted plane');
	hold on;
	plot(fittedPlaneModel);
	hold off;
	%}
	
	%--------------------------------------------------------------------------
	%------------------ FIT PLANE ------------------------
   
	FITTED_DATA=zeros(argHeight, argWidth);
	REAL_TO_FITTED_DIFF=zeros(argHeight, argWidth); %diff between real and fitted
   
	colIndex = 3;
	diffBtwRealDepthAndFitted = 0;
	seqDiffValues = zeros(1, (roi_x_max - roi_x_min) * (roi_y_max - roi_y_min));
	idx = 1;

	for i = 1:argHeight
		for j = 1:argWidth

			rowIndex = (i - 1) * argWidth + j;
			orgDepthVal = pointPositions(rowIndex, colIndex);
			
			%{
			if (orgDepthVal < argDistance + argDistance / 20 && orgDepthVal > argDistance - argDistance / 20)
				FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
				FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
				diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - pointPositions(rowIndex, colIndex);
            else
				FITTED_DATA(i, j) = orgDepthVal;
				diffBtwRealDepthAndFitted = 0;
            end
			
			REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
			%}
			
			%if (i >= roi_y_min && i <= roi_y_max ...
				%&& j >= roi_x_min && j <= roi_x_max ...
				%&& orgDepthVal < argDistance + argDistance / 100 && orgDepthVal > argDistance - argDistance / 100)
			
			if (i >= roi_y_min && i <= roi_y_max && j >= roi_x_min && j <= roi_x_max)
			 
				FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
				FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
				
				if (pointPositions(rowIndex, colIndex) ~= 0)
				   diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - pointPositions(rowIndex, colIndex);
				else
				   diffBtwRealDepthAndFitted = 0;
				end
				
				%fprintf("i: %d \tj: %d \t org: %d \t fit: %7.4f \t diff: %4.4f \n", ...
				%	   i, j, pointPositions(rowIndex, colIndex), ...
				%   FITTED_DATA(i, j), diffBtwRealDepthAndFitted);

			else
				FITTED_DATA(i, j) = orgDepthVal;
				diffBtwRealDepthAndFitted = 0;
			end

			REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
			
			if (diffBtwRealDepthAndFitted ~= 0)
				seqDiffValues(idx) = abs(cast(diffBtwRealDepthAndFitted, "uint16"));
				idx = idx + 1;
			end

			resGroundTruthPc(rowIndex, 1) = i;
			resGroundTruthPc(rowIndex, 2) = j;
			resGroundTruthPc(rowIndex, 3) = cast(FITTED_DATA(i, j), "uint16");

			resGroundTruth(i, j) = cast(FITTED_DATA(i, j), "uint16");
		end
	end

	
	% {
	if (argDisplayFlag)
	
	figure;
	pcshow(pointCloudNearPlane);
	title('Optimum fitted plane');
	hold on;
	plot(fittedPlaneModel);
	hold off;
	
	figure;
	pcshow(resGroundTruthPc, 'VerticalAxis', 'X', 'VerticalAxisDir', 'Down' );
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title('Ground Truth');
	
	figure;
	imagesc(REAL_TO_FITTED_DIFF);
	xlabel('X(px)');
	ylabel('Y(px)');
	colorbar('southoutside');
	title('Residuals (mm), Fitted Data minus Real Data');
	end
% }

	fidTemp = fopen("c:\tmp\sil2.txt", 'w');
	for i = 1:argHeight
		for j = 1:argWidth
			if (i >= roi_y_min && i <= roi_y_max && j >= roi_x_min && j <= roi_x_max)
			rowIndex = (i - 1) * argWidth + j;
			orgDepthVal = pointPositions(rowIndex, colIndex);
			fprintf(fidTemp, "%4d %4d %5d %5d %7.4f\n", ...
				i, j, orgDepthVal, cast(FITTED_DATA(i, j), "uint16"), ...
				FITTED_DATA(i, j) - orgDepthVal );
			end
		end
	end
	
	MER = mean( abs(seqDiffValues));
	SQE = seqDiffValues.^2;
	MSE = mean(SQE(:));
	RMSE = sqrt(MSE);
	SDEV = std(seqDiffValues(:));
	
	fprintf (fidTemp, "\nStats are:\n\t mean %f, mse %f, rmse %f, std_dev: %f", MER, MSE, RMSE, SDEV);
	fclose(fidTemp);
	
	fprintf ("\nStats are:\n\t mean %f, mse %f, rmse %f, std_dev: %f", MER, MSE, RMSE, SDEV);

    fprintf("\nEND: fun_get_ground_truth\n");
	return;
end