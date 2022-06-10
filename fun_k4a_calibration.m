
% ***********************************************************
% MAIN OPERATION SCRIPT
% K4A Depth Camera Calibration and error analysis is done
% 10 Haziran 2020
%
% INPUT:
%
%   argRgbImages	-> an array of RGB images of a planar checkerboard pattern
%						(RGB camera calibration params are to be estimated)
%   argIrImages		-> an array of IR images of a planar checkerboard pattern
%						(IR camera calibration params are to be estimated)
%
%   argMeasurements -> a table where each row contains info for a specific distance
%							Col 1: Sampling Distance in mm
%							Col 2: IR Image (Average)
%							Col 3: Point Cloud (Average)
%
% OUTPUT: 
%  
%
%
% **********************************************************

function [ correctedImage ] = fun_k4a_calibration(argRgbImages, argIrImages, argMeasurements)
	fprintf("\nBEGIN: fun_k4a_calibration");

	fprintf("\nStartig RGB camera calibration");

	%Read RGB IMAGES



	fprintf("\nEND: fun_k4a_calibration");

	return;
end