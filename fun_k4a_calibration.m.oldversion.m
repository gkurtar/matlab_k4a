
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

function [ resCorrectedImages ] = fun_k4a_calibration(...
	argRgbImages, ...
	argRgbSquareSize, ...
	argIrImages, ...
	argIrSquareSize, ...
	argSeqDistances, ...
	argSeqOfPcFilePathArray, ...
	argDepthDataSize, ...
	argSeqOfDepthDataToBeCorrected, ...
	argRoiVector)

	fprintf("\nBEGIN: fun_k4a_calibration\n");
	
	fprintf("\nStarting RGB camera calibration\n");
	%disp(argRgbImages);
	rgbCamParams = fun_detect_camera_params(argRgbImages, argRgbSquareSize);

	fprintf("\nStarting IR camera calibration\n");
	%disp(argIrImages);
	irCamParams = fun_detect_camera_params(argIrImages, argIrSquareSize);

	fprintf("\nProcessing Depth Images to find depth cam params\n");
	[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(...
						argSeqDistances, argSeqOfPcFilePathArray, argDepthDataSize(1), argDepthDataSize(2), argRoiVector);
	
	%if (3 < 5) return; end;
	
	% get one file for each distance;
	seqOfDepthDataToBeCorrected = {};
	for i = 1 : numel(argSeqDistances)
		fprintf("\nIterating %d, dist is %d\n", i, argSeqDistances(i));
		seqDepthDataFilePaths = argSeqOfPcFilePathArray{i};
		%disp(seqDepthDataFilePaths(1));
		%seqOfDepthDataToBeCorrected{i} = seqDepthDataFilePaths(1);
		seqOfDepthDataToBeCorrected = [seqOfDepthDataToBeCorrected, seqDepthDataFilePaths(1) ]; 	
	end
	
	disp(seqOfDepthDataToBeCorrected);
	
	for i = 1 : numel(seqOfDepthDataToBeCorrected)
		%fprintf("\nIterating %d, depth data is %d\n", i, seqOfDepthDataToBeCorrected(i));
		fprintf("\nIterating %d, depth data is \n", i);
		disp(seqOfDepthDataToBeCorrected(i));
	end

	

	fprintf("\nProcessing Depth Images to correct them.\n");
	seqOfCorrectedImages = {};
	seqOfGroundTruthImages = {};
	
	%control for argSeqDistances length with seqOfDepthDataToBeCorrected
	if (length(argSeqDistances) ~= length(seqOfDepthDataToBeCorrected))
		error("sdfsdf");
	end;
	
	for i = 1 : numel(seqOfDepthDataToBeCorrected)

		fprintf("\n____Iterating %d, depth data is %s\n\theight: %d, width: %d",...
					i, seqOfDepthDataToBeCorrected{i}, argDepthDataSize(1), argDepthDataSize(2));
		%disp(seqOfDepthDataToBeCorrected{i});

		depthDataFilePath = seqOfDepthDataToBeCorrected{i};
		depthData = fun_read_point_cloud_data(depthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
		
		undistortedDepthData = fun_undistort_depth_data(depthData, argDepthDataSize(1), argDepthDataSize(2), irCamParams);

		%correct measurements // width ve height degerleri arguman verilmeden de bulunabilir.
		resCorrectedImage = fun_correct_measurements(undistortedDepthData, argDepthDataSize(1), argDepthDataSize(2), matMeanLinearModels);
		seqOfCorrectedImages = [seqOfCorrectedImages ; resCorrectedImage];
		
		%find ground truth data
		[ groundTruthImage ] = fun_get_ground_truth(depthDataFilePath, argDepthDataSize(1), argDepthDataSize(2), argSeqDistances(i))
		seqOfGroundTruthImages = [seqOfGroundTruthImages; groundTruthImage];
	end
	
	fprintf("\nAnalysing errors\n");
	fun_inspect_errors(seqOfCorrectedImages, seqOfGroundTruthImages);
	
	fprintf("\nEND: fun_k4a_calibration\n");
	return;
end