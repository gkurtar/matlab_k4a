
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
	DEPTH_DATA_PATH = 'c:\tmp\cal\depth';
	
	distances = [50; 100; 150]; %, 200, 250, 300, 350, 400, 450, 500];
	depthDataMatrixSize = [480, 640];
	seqDepthDataMatrixSizes = {};

	fprintf("\nStartig RGB camera calibration\n");

	%Read RGB IMAGES from folder and store in an image array

	%{
	seq_rgb_images = {};
	files_dir = dir(fullfile(RGB_PATH, '*.png'));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%seq_rgb_images = [seq_rgb_images, imread(filepath)];
		seq_rgb_images = [seq_rgb_images, string(filepath)];
	end
	fprintf("\nRead %d RGB Images from %s\n", numel(files_dir), RGB_PATH);
	disp(seq_rgb_images);
	%}
	
	seq_rgb_images = {};
	[sel_file, sel_path] = uigetfile("*.*", "Select multiple RGB images for RGB Camera Calibration!", 'MultiSelect', 'on');
	
	if (isequal(sel_file, 0) || isequal(sel_path, 0))
		error("Not any RGB Images are selected!")
	end;
	
	if (~iscell(sel_file))
		sel_file = {sel_file};
	end
	
	if (numel(sel_file) < 3)
		error("At least 3 RGB calibration image files are needed!");
	end;
	
	disp("numel files!");
	disp(numel(sel_file));
	
	for i = 1 : numel(sel_file)
		filepath = fullfile(sel_path, sel_file(i));
		seq_rgb_images = [seq_rgb_images, string(filepath)];
	end
	
	fprintf("\nSelected %d RGB Images from %s\n", numel(sel_file), sel_path);
	disp(seq_rgb_images);
	
	
	%Read IR IMAGES from folder and store in an image array
	%{
	files_dir = dir(fullfile(IR_PATH, '*.png'));
	seq_ir_images = {}; %zeros(numel(files_dir));
	for i = 1:numel(files_dir)
		filepath = fullfile(files_dir(i).folder, files_dir(i).name);
		%seq_ir_images = [seq_ir_images, imread(filepath)];
		seq_ir_images = [seq_ir_images, string(filepath)];
	end
	fprintf("\nRead %d IR Images from %s\n", numel(files_dir), IR_PATH);
	disp(seq_ir_images);
	%}
	
	seq_ir_images = {};
	[sel_file, sel_path] = uigetfile("*.*", "Select multiple IR images for IR Camera Calibration!", 'MultiSelect', 'on');
	
	if (isequal(sel_file, 0) || isequal(sel_path, 0))
		error("Not any IR Images are selected!")
	end;
	
	if (~iscell(sel_file))
		sel_file = {sel_file};
	end
	
	if (numel(sel_file) < 3)
		error("At least 3 IR calibration image files are needed!");
	end;
	
	disp("numel files!");
	disp(numel(sel_file));
	
	for i = 1 : numel(sel_file)
		filepath = fullfile(sel_path, sel_file(i));
		seq_ir_images = [seq_ir_images, string(filepath)];
	end
	
	fprintf("\nSelected %d IR Images from %s\n", numel(sel_file), sel_path);
	disp(seq_ir_images);
	
	prompt = {'Enter RGB calibration image square size (cm):',...
		'Enter IR calibration image square size (cm):', 'Enter depth image distances (cm):'};
	dlgtitle = 'Please enter input parameters!';
	dims = [1 45; 1 45; 1 45];
	definput = {'25', '25', '50 100 150'};
	answer = inputdlg(prompt, dlgtitle, dims, definput);
	
	rgb_sq_size	= str2num(answer{1});
	rgb_sq_size = uint16(rgb_sq_size);
	
	ir_sq_size	= str2num(answer{2});
	ir_sq_size = uint16(ir_sq_size);
	
	seq_distances = str2num(answer{3});
	disp(seq_distances);
	
	fprintf("\nCalibration image square sizes are IR: %d and RGB: %d, ",...
		ir_sq_size, rgb_sq_size);
		
	frmt=['distances: ' repmat(' %4d', 1, numel(seq_distances)) '\n'];
	fprintf(frmt, seq_distances);

	
	if (3 < 5) return; end;
	
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
	

	for i = 1 : numel(pbe_ir_files_dir)
		filepath = fullfile(pbe_ir_files_dir(i).folder, pbe_ir_files_dir(i).name);
		%seq_pbe_ir_images = [seq_pbe_ir_images, imread(filepath)];
		seq_pbe_ir_images = [seq_pbe_ir_images; string(filepath)];
	end
	

	
	seq_avg_point_clouds = {};
	seqPointClouds = {};
	seqPointCloudsForSpecificDistance = {};
	
	%read in depth data
	for i = 1 : numel(distances)
		strMatchPattern = sprintf("*_%d.txt", distances(i));
		point_cloud_files_dir = dir(fullfile(DEPTH_DATA_PATH, strMatchPattern));
		fprintf("\nnum of matched files for %d : %d\n", distances(i), numel(point_cloud_files_dir));
		seqPointClouds = {};
		for j = 1 : numel(point_cloud_files_dir)
			filepath = fullfile(point_cloud_files_dir(j).folder, point_cloud_files_dir(j).name);
			
			disp(filepath);
			if (contains(point_cloud_files_dir(j).name, 'avg'))
				seq_avg_point_clouds = [seq_avg_point_clouds; string(filepath)];
				disp(strcat("found ", point_cloud_files_dir(j).name));
			else
				seqPointClouds = [seqPointClouds, string(filepath)];
			end
			disp("sdf #");
			seqPointClouds
			disp("sdf $");
		end
		
		seqPointCloudsForSpecificDistance = [seqPointCloudsForSpecificDistance; seqPointClouds];
		
		seqDepthDataMatrixSizes = [seqDepthDataMatrixSizes; depthDataMatrixSize];
	end
	
	%disp(seqDepthDataMatrixSize(1));
	%datas = cell2struct(seqDepthDataMatrixSize, {'shortname', 'longname'}, 2);
	%disp(datas);
	
	disp("\n-------\n");
	disp(seqPointCloudsForSpecificDistance);
	disp("=======\n");
	
	stcMeasurement.ranges = distances;
	stcMeasurement.irFilePaths = seq_pbe_ir_images;
	%stcMeasurement.pcFilePaths = seq_pbe_point_clouds;
	stcMeasurement.pcAvgFilePaths = seq_avg_point_clouds;
	stcMeasurement.pcFilePaths = seqPointCloudsForSpecificDistance;
	%stcMeasurement.matsize = depthDataMatrixSize;%stcMeasurement.matsize = datas;
	stcMeasurement.depthDataSizes = seqDepthDataMatrixSizes;
	tblCalData = struct2table(stcMeasurement);

	fprintf("\nRead Data for probability based evaluation into a table:\n");
	disp(stcMeasurement);
	fprintf("\nTable:\n");
	disp(tblCalData);
	
	
	fun_k4a_calibration(seq_rgb_images, 25, seq_ir_images, 25, tblCalData);

fprintf("\nEND: k4a depth camera calibration script\n");