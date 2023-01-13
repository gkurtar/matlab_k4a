
% ***********************************************************
% 
% fun_k4a_calibration
%
% K4A Depth Camera Calibration and depth image correction error analysis is done by this method.
% RGB camera parameters are estimated first, After this step IR camera parameters
% are estimated. Depth camera data could be undistorted by using these IR camera paramters.
% Depth Camera measurements are also processed and analysed.
% Linear models of mean and std deviation for each pixel is evaluated as depth camera parameters.
% Depth images which are to be corrected would be processed after these steps.
% Using these input images ground truth data is determined.
% First step involves undistorting depth data via IR camera Parameters.
% In second step these depth images are corrected via depth camera parameters.
% After these steps corrected data are compared with ground truth data and residual values are further analysed
% and depth error stats are acquired.
%
% INPUT:
%   argRgbImages        -> an array of RGB image file paths of a planar checkerboard pattern 	
%   argRgbSquareSize    -> an integer which is the size of the square (centimeter) in the RGB checkerboard pattern
%   argIrImages         -> an array of IR image file paths of a planar checkerboard pattern
%   argIrSquareSize     -> an integer which is the size of the square (centimeter) in the IR checkerboard pattern
%   argSeqDistances     -> an array of distances in cm.
%   argSeqOfPcFilePathArray -> a cell array where each element is a string array and each string denotes the depth data (point cloud) file path
%                          of the corresponding indexed distances array i.e. { [da1.txt, da2.txt, da3.txt], [db1.txt, db2.txt, db3.txt] }
%   argDepthDataSize    -> a 1x2 vector denoting the size ( row and col count) of the depth data image matrix
%   argSeqOfDepthDataToBeCorrected -> an array of Depth Image file paths to be corrected
%
% OUTPUT:
%   resCorrectedImages	-> an array of corrected images whose size is eq to argument named argSeqOfDepthDataToBeCorrected
%
% **********************************************************

function [ resCorrectedImage, resGroundTruthImage ] = fun_k4a_calibration(...
	argIrCamParams, ...
	argMatMeanLinearModels,...
	argDepthDataSize, ...
	argRoiVector, ...
	argDepthDataFilePath,...
	argPlaneDistance, ...
	argFileID)

	fprintf("\nBEGIN: fun_k4a_calibration\n");
	
	fprintf("\n____depth data is %s\n\theight: %d, width: %d",...
				argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));

	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to undistort and correct depth data by camera parameters.");
	fprintf(argFileID, "\n\nGenerating a ground truth data and comparing measurements are followed.");
	fprintf(argFileID, "\n\nDepth data file is %s, W x H is (%d x %d), plane distance is %d",...
		argDepthDataFilePath, argDepthDataSize(2), argDepthDataSize(1), argPlaneDistance);
	
	depthData = fun_read_point_cloud_data(argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
	undistortedDepthData = fun_undistort_depth_data(depthData, argDepthDataSize(1), argDepthDataSize(2), argIrCamParams);

	%correct measurements
	resCorrectedImage = fun_correct_measurements(...
		undistortedDepthData, argDepthDataSize(1), argDepthDataSize(2), argMatMeanLinearModels, argRoiVector, argFileID);
	
	%find ground truth data
	resGroundTruthImage = fun_get_ground_truth_3(...
		argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2), argRoiVector, argPlaneDistance, true, argFileID);
	
	%analyse errors
	fprintf("\nAnalysing errors\n");

	
	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to compare measurements between Original depth data and Ground Truth data");
	fprintf("\nGoing to compare measurements between Original depth data and Ground Truth data");
	[orgDataDiff, orgDataDiffComparedWithDistance] = fun_inspect_errors_2(depthData, resGroundTruthImage, argPlaneDistance, argRoiVector, argFileID);
	
	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nGoing to compare measurements between Corrected depth data and Ground Truth data");
	fprintf("\nGoing to compare measurements between Corrected depth data and Ground Truth data");
	[correctedDataDiff, correctedDataDiffComparedWithDistance]  = fun_inspect_errors_2(resCorrectedImage, resGroundTruthImage, argPlaneDistance, argRoiVector, argFileID);
	

	fidDiff = fopen('diffData.txt', 'w');
	for (i = 1 : argDepthDataSize(1)) % height, rows
		for (j = 1 : argDepthDataSize(2)) % width, cols
		
			if (j < argRoiVector(1) || j > argRoiVector(2) ...
				|| i < argRoiVector(3) || i > argRoiVector(4) )
				continue;
			end;

			fprintf(fidDiff, "Row: %3d, Col: %3d, org: %4d, corr:%4d, gt: %4d, diffOrg: %4d, diffCorr:%4d, diffOrgCwd: %4d, diffCorrCwd: %4d\n",...
					i, j, depthData(i, j), resCorrectedImage(i, j), resGroundTruthImage(i, j),...
					orgDataDiff(i, j), correctedDataDiff(i, j), ...
					orgDataDiffComparedWithDistance(i, j), correctedDataDiffComparedWithDistance(i, j) );
		end
	end
	fclose(fidDiff);

	fprintf("\nEND: fun_k4a_calibration\n");
	return;
end