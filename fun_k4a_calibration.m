
% ***********************************************************
% 
% fun_k4a_calibration function
% K4A Depth Camera Calibration and error analysis is done by this method
% 10 Haziran 2020
%
% INPUT:
%
%   argRgbImages	-> an array of RGB images of a planar checkerboard pattern 	(RGB camera params are to be estimated)
%   argIrImages		-> an array of IR images of a planar checkerboard pattern 	(IR camera params are to be estimated)
%   argMeasurements -> a table where each row contains info for a specific distance
%							Col 1 (Integer): Sampling Distance in cm
%							Col 2 (String): IR Image file paths (Average)
%							Col 3 (String): Point Cloud file paths (Average)
%
% OUTPUT: 
%   correctedImages -> corrected images in measurements
%   errorResults    -> a structure containing error values such as mean, rmse etc.
%
% **********************************************************

function [ correctedImage ] = fun_k4a_calibration(...
	argRgbImages, argRgbSquareSize, argIrImages, argIrSquareSize, argMeasurements)

	fprintf("\nBEGIN: fun_k4a_calibration\n");

	fprintf("\nStartig RGB camera calibration\n");
	disp(argRgbImages);
	rgbCamParams = fun_detect_camera_params(argRgbImages, argRgbSquareSize);

	fprintf("\nStartig IR camera calibration\n");
	disp(argIrImages);
	irCamParams = fun_detect_camera_params(argIrImages, argIrSquareSize);

	fprintf("\nEND: fun_k4a_calibration\n");

	return;
end
