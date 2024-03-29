
% ***********************************************************
% MAIN OPERATION SCRIPT
% K4A Depth Camera Calibration and error analysis is done by this script
%
% Various input files are selected which are used to determine RGB, IR and Depth Camera parameters.
% After estimating these camera paramters, fun_k4a_calibration is called to correct a depth data
% and to determine various error stats. Some of the returned objects from these functions and
% some logs are written to a file named "results.txt" and shown in various figures.
% 
% **********************************************************
% **********************************************************

	fprintf("\nBEGIN: k4a depth camera calibration script\n");
 
	RGB_FILE_NAME = 'data';
	RGB_FILE_SUFFIX = 'png';
	RGB_FILES_DIR = 'C:\work\article\data\cal\rgb';
	RGB_FILE_COUNT = 15;
	
	IR_FILE_NAME = 'data';
	IR_FILE_SUFFIX = 'png';
	IR_FILES_DIR = 'C:\work\article\data\cal\ir';
	IR_FILE_COUNT = 15;
	
	%DEPTH_PC_FILE_NAMES = {'Depth_50', 'Depth_75', 'Depth_100', 'Depth_125', 'Depth_150', 'Depth_175', 'Depth_200' ...
	%						'Depth_225', 'Depth_250', 'Depth_275', 'Depth_300', 'Depth_325', 'Depth_350' };
	DEPTH_PC_FILE_NAMES = {'Depth_50', 'Depth_75', 'Depth_100', 'Depth_125', 'Depth_150', 'Depth_175', 'Depth_200' ...
							'Depth_225', 'Depth_250', 'Depth_275', 'Depth_300', 'Depth_325', 'Depth_350', 'Depth_375' };
	DEPTH_PC_FILE_SUFFIX = 'txt';
	DEPTH_PC_FILES_DIR = 'C:\work\article\data\cal\depth';
	DEPTH_PC_FILE_COUNT = 10;

	fileID = fopen("results.txt", 'w');
	local_test_flag = true;
	
	seqRgbImages = {};
	seqIrImages = {};
	seqAvgDepthDataFilePaths = {};
	DEPTH_PC_SAMPLE_DATA = {};
	
	if (local_test_flag)

		for i = 1 : RGB_FILE_COUNT
			file_url = sprintf('%s\\%s%d.%s', RGB_FILES_DIR, RGB_FILE_NAME, i, RGB_FILE_SUFFIX);
			%fprintf("file name is %s\n", file_url);
			seqRgbImages{i} = file_url;
		end
		
		for i = 1 : IR_FILE_COUNT
			file_url = sprintf('%s\\%s%d.%s', IR_FILES_DIR, IR_FILE_NAME, i, IR_FILE_SUFFIX);
			seqIrImages{i} = file_url;
		end


		for i = 1 : numel(DEPTH_PC_FILE_NAMES)
			fname = DEPTH_PC_FILE_NAMES{i};
			
			for j = 1 : DEPTH_PC_FILE_COUNT
				file_url = sprintf('%s\\%s_%d.%s', DEPTH_PC_FILES_DIR, fname, j, DEPTH_PC_FILE_SUFFIX);
				seqDepthImages{j} = file_url;
			end
			DEPTH_PC_SAMPLE_DATA{i} = seqDepthImages;
			
			file_url = sprintf('%s\\%s_Avg.%s', DEPTH_PC_FILES_DIR, fname, DEPTH_PC_FILE_SUFFIX);
			fprintf("avg file %s \n", file_url);
			seqAvgDepthDataFilePaths{i} = file_url;
		end

		rgbSqSize = 44;
		irSqSize = 44;
		%seqDistances = [500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3250, 3500];
		seqDistances = [503, 750, 1000, 1250, 1500, 1750, 1990, 2240, 2485, 2735, 2980, 3220, 3450, 3690];
		depthDataMatrixSize =  [576, 640];
		%depthDataFileToBeCorrected = 'C:\work\article\data\cal\depth\sample_225.txt';
		%depthDataToCorrectPlaneDistance = 2250;
		%depthDataFileToBeCorrected = 'C:\work\article\data\cal\depth\Sample_160.txt';
		%depthDataToCorrectPlaneDistance = 1600;
		%depthDataFileToBeCorrected = 'C:\work\article\data\cal\depth\Sample_320.txt';
		%depthDataToCorrectPlaneDistance = 3180;
		depthDataFileToBeCorrected = 'C:\work\article\data\cal\depth\Depth_50_Avg.txt';
		depthDataToCorrectPlaneDistance = 503;
		
		seqAllPointClouds = DEPTH_PC_SAMPLE_DATA;
		%roiVector = [300, 335, 225, 270]; % [320, 350, 220, 240];
		%roiVector = [280, 370, 225, 290]; % x1, x2, y1, y2 => x is width, y is height, => data gtu blak bg olcumler icin ROI
		%roiVector = [285, 365, 230, 290]; % x1, x2, y1, y2 => x is width, y is height => data gtu black bg olcumler icin ROI
		
		roiVector = [295, 350, 240, 280]; % roiVector = [295, 375, 240, 285]

	else
		%Select RGB IMAGES from disk and store in an image array
		seqRgbImages = fun_ui_get_files("C:\", "Select multiple RGB images for RGB Camera Calibration!", 3);
		fprintf("\nSelected %d RGB calibration Images\n", numel(seqRgbImages));
		disp(seqRgbImages);

		%Select IR IMAGES from disk and store in an image array
		seqIrImages = fun_ui_get_files("C:\", "Select multiple IR images for IR Camera Calibration!", 3);
		fprintf("\nSelected %d IR calibration Images\n", numel(seqIrImages));
		disp(seqIrImages);
		
		prompt = {'Enter RGB calibration image square size (mm):',...
				'Enter IR calibration image square size (mm):',...
				'Enter depth image distances (mm):',...
				'Enter depth data size:',...
				'Enter ROI vector positions :'};
				
		dlgtitle = 'Please enter input parameters!';
		dims = [1 45; 1 45; 1 45; 1 45; 1 45];
		definput = {'35', '35', '500 750 1000', '576 640', '300 335 225 270'};
		answer = inputdlg(prompt, dlgtitle, dims, definput);
		
		rgbSqSize = str2num(answer{1});
		rgbSqSize = uint16(rgbSqSize);
		
		irSqSize = str2num(answer{2});
		irSqSize = uint16(irSqSize);
		
		seqDistances = str2num(answer{3});
		disp(seqDistances);
		
		depthDataMatrixSize = str2num(answer{4});
		disp(depthDataMatrixSize);
		
		roiVector = str2num(answer{5});
		disp(roiVector);
		
		fprintf("\nCalibration image square sizes are IR: %d and RGB: %d, ", irSqSize, rgbSqSize);
		frmt=['Distances: ' repmat(' %4d', 1, numel(seqDistances)) '\n'];
		fprintf(frmt, seqDistances);
		
		%Select point clouds for each distance from disk and store in the corresponding array
		%%point clouds are going to be used for detecting parameters of probability based evaluation
		seqAllPointClouds = {};
		for i = 1 : numel(seqDistances)
			fprintf("\nDistances: %d , \n", seqDistances(i));	
			strTitle = sprintf("Select multiple point cloud data files for %d mm distance!", seqDistances(i));
			seqPointClouds = fun_ui_get_files("C:\", strTitle, 3);
			fprintf("\nSelected %d point cloud files for distance %d mm\n", numel(seqPointClouds), seqDistances(i));
			disp(seqPointClouds);
			seqAllPointClouds{i} = seqPointClouds;
		end
		
		fprintf("\nSelected %d point cloud files\n", numel(seqAllPointClouds));
		disp(seqAllPointClouds);

		%Select point cloud files for correction from disk and store in an array
		depthDataFileToBeCorrected = fun_ui_get_files("C:\", "Select depth data file to correct!", 0);
		disp(depthDataFileToBeCorrected);
		
		prompt = {'Enter plane distance for which depth data to be corrected and analysed:'};
		dlgtitle = 'Please enter input parameters!';
		dims = [1 45];
		definput = {'2250'};
		answer = inputdlg(prompt, dlgtitle, dims, definput);
		
		depthDataToCorrectPlaneDistance	= str2num(answer{1});
		%depthDataToCorrectPlaneDistance = uint16(depthDataToCorrectPlaneDistance);
    end

	fprintf("\nStarting RGB camera calibration\n");
	fprintf(fileID, "\n\nSTARTED\n\nRGB camera parameters:\n");
	[rgbCamParams] = fun_detect_camera_params(seqRgbImages, rgbSqSize, fileID);

	fprintf("\nStarting IR camera calibration\n");
	fprintf(fileID, "\n\nIR camera parameters:\n");
	[irCamParams] = fun_detect_camera_params(seqIrImages, irSqSize, fileID);

	fprintf("\nProcessing Depth Images to find depth cam params\n");
	
	%[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(...
	%				seqDistances, seqAllPointClouds, depthDataMatrixSize(1),...
	%				depthDataMatrixSize(2), roiVector, fileID);
					
	[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(...
		seqDistances, seqAllPointClouds, seqAvgDepthDataFilePaths, depthDataMatrixSize(1),...
		depthDataMatrixSize(2), roiVector, fileID);
	
	fprintf("\nCorrect an image with the parameters\n");
	fun_k4a_calibration(irCamParams, matMeanLinearModels, depthDataMatrixSize, roiVector,...
		depthDataFileToBeCorrected, depthDataToCorrectPlaneDistance, fileID);
	
	fprintf(fileID, "\n\nEND\n");
	fclose(fileID);

	fprintf("\nEND: k4a depth camera calibration script\n");
	
% **********************************************************
