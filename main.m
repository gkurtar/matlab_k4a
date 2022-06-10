
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
%							Col 1: Sampling Distance in cm
%							Col 2: IR Image (Average)
%							Col 3: Point Cloud (Average)
%
% OUTPUT: 
%  
%
%
% **********************************************************

fprintf("\nBEGIN: k4a_calibration operation");

	fprintf("\nStartig RGB camera calibration");

	%Read RGB IMAGES from folder and store in an image array
	RGB_PATH = 'd:\IMAGES\CAL\RGB';
	seq_rgb_images = {};
	files_dir = dir(fullfile(RGB_PATH, '*.png'));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%img = imread(filepath);
		seq_rgb_images = [seq_rgb_images, imread(filepath)];
	end
	fprintf("\nRead RGB Images: %s", seq_rgb_images);

	%Read IR IMAGES from folder and store in an image array
	IR_PATH = 'd:\IMAGES\CAL\IR';
	seq_ir_images = {};
	files_dir = dir(fullfile(IR_PATH, '*.png'));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		seq_ir_images = [seq_ir_images, imread(filepath)];
	end
	fprintf("\nRead IR Images: %s", seq_ir_images);

	%Read Average IR images and Average Depth Point Clouds from the specified folder and store in a table
	%They are going to be used for probability based evaluation.
	sz = [numel(distances) 3];
	varTypes = ["int", "image", "fileID"];
	varNames = ["Distance", "IrAvgImage", "PointCloud"];
	cal_data_table = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
	
	distances = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500];
	PBCAL_DATA_PATH = 'd:\IMAGES\CAL\AVG';
	seq_pbe_ir_images = {}; %going to be used for prob based evaluation
	files_dir = dir(fullfile(PBCAL_DATA_PATH, '*.png'));
	for i = 1 : numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		seq_pbe_ir_images = [seq_pbe_ir_images, imread(filepath)];
	end
	fprintf("\nRead IR Images: %s", seq_pbe_ir_images);
	
	

fprintf("\nEND: k4a_calibration operation");