
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
	argPlaneDistance)

	fprintf("\nBEGIN: fun_k4a_calibration\n");
	
	fprintf("\n____depth data is %s\n\theight: %d, width: %d",...
				argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
	
	depthData = fun_read_point_cloud_data(argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
	undistortedDepthData = fun_undistort_depth_data(depthData, argDepthDataSize(1), argDepthDataSize(2), argIrCamParams);

	%correct measurements
	resCorrectedImage = fun_correct_measurements(...
		undistortedDepthData, argDepthDataSize(1), argDepthDataSize(2), argMatMeanLinearModels, argRoiVector);
	
	%find ground truth data
	resGroundTruthImage = fun_get_ground_truth(argDepthDataFilePath, argDepthDataSize(1), argDepthDataSize(2), argPlaneDistance);
	
	%analyse errors
	fprintf("\nAnalysing errors\n");
	fun_inspect_errors(resCorrectedImage, resGroundTruthImage);
	
	fprintf("\nEND: fun_k4a_calibration\n");
	return;
end