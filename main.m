
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

	%constants
	RGB_PATH = 'c:\tmp\cal\RGB';
	IR_PATH = 'c:\tmp\cal\IR';
	PBCAL_DATA_PATH = 'd:\tmp\CAL\AVG';
	distances = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500];

	fprintf("\nStartig RGB camera calibration");

	%Read RGB IMAGES from folder and store in an image array
	%seq_rgb_images = {};
	
	files_dir = dir(fullfile(RGB_PATH, '*.png'));
	seq_rgb_images = zeros(numel(files_dir));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%img = imread(filepath);
		seq_rgb_images = [seq_rgb_images, imread(filepath)];
	end
	fprintf("\nRead %d RGB Images from %s", numel(files_dir), RGB_PATH);
	
	%Read IR IMAGES from folder and store in an image array
	
	files_dir = dir(fullfile(IR_PATH, '*.png'));
	seq_ir_images = zeros(numel(files_dir));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		seq_ir_images = [seq_ir_images, imread(filepath)];
	end
	fprintf("\nRead %d IR Images from %s", numel(files_dir), IR_PATH);
	

	%Read Average IR images and Average Depth Point Clouds from the specified folder and store in a table
	%They are going to be used for probability based evaluation.
	sz = [numel(distances) 3];
	%varTypes = ["int", "image", "fileID"];
	%varNames = ["Distance", "IrAvgImage", "PointCloud"];
	%cal_data_table = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
	
	%seq_pbe_ir_images = {}; %ir images going to be used for probability based evaluation
	%seq_pbe_point_clouds = {}; %point clouds going to be used for probability based evaluation
	pbe_ir_files_dir = dir(fullfile(PBCAL_DATA_PATH, '*.png'));
	pbe_point_cloud_files_dir = dir(fullfile(PBCAL_DATA_PATH, '*.txt'));
	seq_pbe_ir_images = zeros(numel(pbe_ir_files_dir));
	seq_pbe_point_clouds = zeros(numel(pbe_point_cloud_files_dir));
	
	if (numel(seq_pbe_ir_images) ~= numel(seq_pbe_point_clouds) ...
		|| numel(seq_pbe_ir_images) ~= numel(distances))
		   error('Error. \nInput files count should be eq to %d.', numel(distances));
	end

	for i = 1 : numel(pbe_ir_files_dir)
		%file_name = sprintf('%s_%d.png', pbe_ir_files_dir(i).name, distances{i});
		%file_name = pbe_ir_files_dir(i).name;
		filepath = fullfile(pbe_ir_files_dir(i).folder, pbe_ir_files_dir(i).name);
		seq_pbe_ir_images = [seq_pbe_ir_images, imread(filepath)];
		
		filepath = fullfile(pbe_point_cloud_files_dir(i).folder, pbe_point_cloud_files_dir(i).name);
		seq_pbe_point_clouds = [seq_pbe_point_clouds, importdata(filepath)];
		%cal_data_table(i, :) = {distances{i}, seq_pbe_ir_images{i},  seq_pbe_point_clouds{i}};
	end
	
	tmp_struct.dists = distances;
	tmp_struct.irs = seq_pbe_ir_images;
	tmp_struct.pcs = seq_pbe_point_clouds;
	cal_data_table = struct2table(tmp_struct);

	fprintf("\nRead Data for probability based evaluation in a table");
	disp(tmp_struct);

fprintf("\nEND: k4a_calibration operation");
