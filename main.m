
% ***********************************************************
% MAIN OPERATION SCRIPT
% K4A Depth Camera Calibration and error analysis is done
% 10 Haziran 2020
%
% reads input files and store them in related data structures.
% calls fun_k4a_calibration after this step to determine error related types.
% returned objects from this function are written to the disk and shown in various figures 
% 
% **********************************************************

fprintf("\nBEGIN: k4a depth camera calibration script\n");

	%constants
	RGB_PATH = 'c:\tmp\cal\RGB';
	IR_PATH = 'c:\tmp\cal\IR';
	PBCAL_DATA_PATH = 'c:\tmp\CAL\AVG';
	distances = [50; 100; 150]; %, 200, 250, 300, 350, 400, 450, 500];
	depthDataMatrixSize = [480, 640];
	seqDepthDataMatrixSizes = {};

	fprintf("\nStartig RGB camera calibration\n");

	%Read RGB IMAGES from folder and store in an image array
	seq_rgb_images = {};
	files_dir = dir(fullfile(RGB_PATH, '*.png'));
	%seq_rgb_images = zeros(numel(files_dir));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%seq_rgb_images = [seq_rgb_images, imread(filepath)];
		seq_rgb_images = [seq_rgb_images, string(filepath)];
	end
	fprintf("\nRead %d RGB Images from %s\n", numel(files_dir), RGB_PATH);
	disp(seq_rgb_images);
	
	%Read IR IMAGES from folder and store in an image array
	files_dir = dir(fullfile(IR_PATH, '*.png'));
	seq_ir_images = {}; %zeros(numel(files_dir));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%seq_ir_images = [seq_ir_images, imread(filepath)];
		seq_ir_images = [seq_ir_images, string(filepath)];
	end
	fprintf("\nRead %d IR Images from %s\n", numel(files_dir), IR_PATH);
	disp(seq_ir_images);
	
	%Read Average IR images and Average Depth Point Clouds from the specified folder and store in a table
	%They are going to be used for probability based evaluation.
	
	%ir images going to be used for probability based evaluation
	pbe_ir_files_dir = dir(fullfile(PBCAL_DATA_PATH, '*.png'));
	%point clouds going to be used for probability based evaluation
	pbe_point_cloud_files_dir = dir(fullfile(PBCAL_DATA_PATH, '*.txt'));
	seq_pbe_ir_images = {}; %zeros(numel(pbe_ir_files_dir));
	seq_pbe_point_clouds = {}; %zeros(numel(pbe_point_cloud_files_dir));
	
	fprintf("PBCAL_DATA_PATH %s, IR: %d, PC: %d, DIST: %d\n", PBCAL_DATA_PATH,  ...
		numel(pbe_ir_files_dir), numel(pbe_point_cloud_files_dir), numel(distances));
	
	if (numel(pbe_ir_files_dir) ~= numel(pbe_point_cloud_files_dir) ...
		|| numel(pbe_ir_files_dir) ~= numel(distances))
		   error('Error. \nInput files count should be eq to %d.\n', numel(distances));
	end

	for i = 1 : numel(pbe_ir_files_dir)
		filepath = fullfile(pbe_ir_files_dir(i).folder, pbe_ir_files_dir(i).name);
		%seq_pbe_ir_images = [seq_pbe_ir_images, imread(filepath)];
		seq_pbe_ir_images = [seq_pbe_ir_images; string(filepath)];
	end
	
	for i = 1 : numel(pbe_point_cloud_files_dir)
		filepath = fullfile(pbe_point_cloud_files_dir(i).folder, pbe_point_cloud_files_dir(i).name);
		%seq_pbe_point_clouds = [seq_pbe_point_clouds, importdata(filepath)];
		seq_pbe_point_clouds = [seq_pbe_point_clouds; string(filepath)];
		seqDepthDataMatrixSizes = [seqDepthDataMatrixSizes; depthDataMatrixSize];
	end
	
	%disp(seqDepthDataMatrixSize(1));
	%datas = cell2struct(seqDepthDataMatrixSize, {'shortname', 'longname'}, 2);
	%disp(datas);
	
	stcMeasurement.ranges = distances;
	stcMeasurement.irFilePaths = seq_pbe_ir_images;
	stcMeasurement.pcFilePaths = seq_pbe_point_clouds;
	%stcMeasurement.matsize = depthDataMatrixSize;%stcMeasurement.matsize = datas;
	stcMeasurement.depthDataSizes = seqDepthDataMatrixSizes;
	tblCalData = struct2table(stcMeasurement);

	fprintf("\nRead Data for probability based evaluation into a table:\n");
	disp(stcMeasurement);
	fprintf("\nTable:\n");
	disp(tblCalData);
	
	fun_k4a_calibration(seq_rgb_images, 25, seq_ir_images, 25, tblCalData);

fprintf("\nEND: k4a depth camera calibration script\n");
