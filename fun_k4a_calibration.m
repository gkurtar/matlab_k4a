
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
%   argSeqOfPcFilePaths -> a cell array where each element is a string array and each string denotes the depth data file path
%                          of the corresponding indexed distances array i.e. { [da1.txt, da2.txt, da3.txt], [db1.txt, db2.txt, db3.txt] }
%   argSeqOfDepthDataToBeCorrected -> an array of Depth Image file paths to be corrected
%   argDepthDataSize	-> a 1x2 vector denoting the size ( row and col count) of the depth data image matrix
%
% OUTPUT:
%   resCorrectedImages	-> corrected images in measurements
%
% **********************************************************

function [ resCorrectedImages ] = fun_k4a_calibration(...
	argRgbImages,
	argRgbSquareSize,
	argIrImages,
	argIrSquareSize,
	argSeqDistances,
	argSeqOfPcFilePaths,
	argSeqOfDepthDataToBeCorrected,
	argDepthDataSize)

	fprintf("\nBEGIN: fun_k4a_calibration\n");

	fprintf("\nStarting RGB camera calibration\n");
	%disp(argRgbImages);
	rgbCamParams = fun_detect_camera_params(argRgbImages, argRgbSquareSize);

	fprintf("\nStarting IR camera calibration\n");
	%disp(argIrImages);
	irCamParams = fun_detect_camera_params(argIrImages, argIrSquareSize);

	%{
	fprintf("\nUndistorting Depth Image\n");
	seqUndistortedDepthData = {};
	tableRowCount = height(argMeasurements);
	fprintf("\nRow Count: %d\n", tableRowCount);
	for i = 1 : tableRowCount
		depthDataFilePath = argMeasurements(i, :).pcFilePaths;
		depthDataDim = argMeasurements(i, :).depthDataSizes;
		%sizes = [depthDataDim{1}];
		fprintf("\ndepthDataDim:\n");
		%disp(depthDataDim{1});
		%disp(sizes(1)); %disp(sizes(2));
		%fprintf("\ndepthDataFilePath: %s, Depth Data Dim:  %d __ \n", depthDataFilePath, depthDataDim{1, :});

		if exist(depthDataFilePath, 'file')
			% File exists.  Do stuff....
			depthData = importdata(depthDataFilePath);
			%undistortedDepthData = fun_undistort_depth_data(depthData, sizes(1), sizes(2), irCamParams);
			undistortedDepthData = fun_undistort_depth_data(depthData, argDepthDataSize(1), argDepthDataSize(2), irCamParams);
			seqUndistortedDepthData = [seqUndistortedDepthData ; undistortedDepthData];
			%fprintf("%s is undistorted:\n", depthDataFilePath);
		else
			warningMessage = sprintf("Warning: file does not exist:\n%s", depthDataFilePath);
			%uiwait(msgbox(warningMessage));
			error(warningMessage);
		end
	end
	%}

	fprintf("\nProcessing Depth Images to find depth cam params\n");
	[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(argSeqDistances, argSeqOfPcFilePaths, argDepthDataSize);

	fprintf("\nProcessing Depth Images to correct them.\n");
	seqOfCorrectedImages = {};
	seqOfGroundTruthImages = {};
	
	for i = 1 : numel(argSeqOfDepthDataToBeCorrected)

		depthDataFilePath = argSeqOfDepthDataToBeCorrected(i);
		%depthData = importdata(depthDataFilePath);
		depthData = fun_read_point_cloud_data(depthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
		
		%undistortedDepthData = fun_undistort_depth_data(depthData, sizes(1), sizes(2), irCamParams);
		undistortedDepthData = fun_undistort_depth_data(depthData, argDepthDataSize(1), argDepthDataSize(2), irCamParams);

		%find ground truth data
		% sample code
		%seqOfGroundTruthImages = [seqOfGroundTruthImages ; someGTImage];

		%correct measurements // width ve height degerleri arguman verilmeden de bulunabilir.
		resCorrectedImage = fun_correct_measurements(undistortedDepthData, argDepthDataSize(1), argDepthDataSize(2), matMeanLinearModels);
		seqOfCorrectedImages = [seqOfCorrectedImages ; resCorrectedImage];
	end
	
	fprintf("\nAnalysing errors\n");
	fun_inspect_errors(argSeqOfDepthImageMatrices, argSeqOfGroundTruthImageMatrices);
	
	fprintf("\nEND: fun_k4a_calibration\n");
	return;
end
