
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
% **********************************************************

	fprintf("\nBEGIN: k4a depth camera calibration script\n");

	%constants
	RGB_FILES = {'c:\tmp\cal\rgb\rgb1.png'; 'c:\tmp\cal\rgb\rgb2.png'; 'c:\tmp\cal\rgb\rgb3.png'};
	IR_FILES = {'c:\tmp\cal\ir\ir1.png'; 'c:\tmp\cal\ir\ir2.png'; 'c:\tmp\cal\ir\ir3.png'};
	
	%{
	DEPTH_PC_SAMPLE_DATA = {{'c:\tmp\CAL\depth\pc_1_50.txt', 'c:\tmp\CAL\depth\pc_2_50.txt', 'c:\tmp\CAL\depth\pc_3_50.txt'}, ...
				{'c:\tmp\CAL\depth\pc_1_75.txt', 'c:\tmp\CAL\depth\pc_2_75.txt', 'c:\tmp\CAL\depth\pc_3_75.txt'}, ...
				{'c:\tmp\CAL\depth\pc_1_100.txt', 'c:\tmp\CAL\depth\pc_2_100.txt', 'c:\tmp\CAL\depth\pc_3_100.txt'}, ...
				{'c:\tmp\CAL\depth\pc_1_125.txt', 'c:\tmp\CAL\depth\pc_2_125.txt', 'c:\tmp\CAL\depth\pc_3_125.txt'}, ...
				{'c:\tmp\CAL\depth\pc_1_150.txt', 'c:\tmp\CAL\depth\pc_2_150.txt', 'c:\tmp\CAL\depth\pc_3_150.txt'} };
	%}
				
	DEPTH_PC_SAMPLE_DATA = {...
	{'c:\tmp\CAL\depth\pc_50_1.txt', 'c:\tmp\CAL\depth\pc_50_2.txt', 'c:\tmp\CAL\depth\pc_50_3.txt', 'c:\tmp\CAL\depth\pc_50_4.txt', ...
	 'c:\tmp\CAL\depth\pc_50_5.txt', 'c:\tmp\CAL\depth\pc_50_6.txt', 'c:\tmp\CAL\depth\pc_50_7.txt', 'c:\tmp\CAL\depth\pc_50_8.txt', ...
	 'c:\tmp\CAL\depth\pc_50_9.txt', 'c:\tmp\CAL\depth\pc_50_10.txt' ...
	 }, ...
	 
	 
	 {'c:\tmp\CAL\depth\pc_75_1.txt', 'c:\tmp\CAL\depth\pc_75_2.txt','c:\tmp\CAL\depth\pc_75_3.txt', 'c:\tmp\CAL\depth\pc_75_4.txt', ...
	 'c:\tmp\CAL\depth\pc_75_5.txt', 'c:\tmp\CAL\depth\pc_75_6.txt', 'c:\tmp\CAL\depth\pc_75_7.txt', 'c:\tmp\CAL\depth\pc_75_8.txt', ...
	 'c:\tmp\CAL\depth\pc_75_9.txt', 'c:\tmp\CAL\depth\pc_75_10.txt' ...
	 }, ...
	 
	 {'c:\tmp\CAL\depth\pc_100_1.txt','c:\tmp\CAL\depth\pc_100_2.txt','c:\tmp\CAL\depth\pc_100_3.txt',...
	 'c:\tmp\CAL\depth\pc_100_4.txt','c:\tmp\CAL\depth\pc_100_5.txt', 'c:\tmp\CAL\depth\pc_100_6.txt',...
	 'c:\tmp\CAL\depth\pc_100_7.txt', 'c:\tmp\CAL\depth\pc_100_8.txt','c:\tmp\CAL\depth\pc_100_9.txt','c:\tmp\CAL\depth\pc_100_10.txt' ...
	 }, ...
	 
	 {'c:\tmp\CAL\depth\pc_125_1.txt','c:\tmp\CAL\depth\pc_125_2.txt','c:\tmp\CAL\depth\pc_125_3.txt',...
	 'c:\tmp\CAL\depth\pc_125_4.txt','c:\tmp\CAL\depth\pc_125_5.txt','c:\tmp\CAL\depth\pc_125_6.txt',...
	 'c:\tmp\CAL\depth\pc_125_7.txt', 'c:\tmp\CAL\depth\pc_125_8.txt','c:\tmp\CAL\depth\pc_125_9.txt',...
	 'c:\tmp\CAL\depth\pc_125_10.txt' ...
	 },
	 
	 {'c:\tmp\CAL\depth\pc_150_1.txt','c:\tmp\CAL\depth\pc_150_2.txt','c:\tmp\CAL\depth\pc_150_3.txt',...
	 'c:\tmp\CAL\depth\pc_150_4.txt','c:\tmp\CAL\depth\pc_150_5.txt','c:\tmp\CAL\depth\pc_150_6.txt',...
	 'c:\tmp\CAL\depth\pc_150_7.txt', 'c:\tmp\CAL\depth\pc_150_8.txt','c:\tmp\CAL\depth\pc_150_9.txt','c:\tmp\CAL\depth\pc_150_10.txt' ...
	 }, ...
	 
	 {'c:\tmp\CAL\depth\pc_175_1.txt','c:\tmp\CAL\depth\pc_175_2.txt','c:\tmp\CAL\depth\pc_175_3.txt',...
	 'c:\tmp\CAL\depth\pc_175_4.txt','c:\tmp\CAL\depth\pc_175_5.txt','c:\tmp\CAL\depth\pc_175_6.txt',...
	 'c:\tmp\CAL\depth\pc_175_7.txt', 'c:\tmp\CAL\depth\pc_175_8.txt','c:\tmp\CAL\depth\pc_175_9.txt','c:\tmp\CAL\depth\pc_175_10.txt' ...
	 }, ...
	 
	 {'c:\tmp\CAL\depth\pc_200_1.txt','c:\tmp\CAL\depth\pc_200_2.txt','c:\tmp\CAL\depth\pc_200_3.txt',...
	 'c:\tmp\CAL\depth\pc_200_4.txt','c:\tmp\CAL\depth\pc_200_5.txt','c:\tmp\CAL\depth\pc_200_6.txt',...
	 'c:\tmp\CAL\depth\pc_200_7.txt', 'c:\tmp\CAL\depth\pc_200_8.txt','c:\tmp\CAL\depth\pc_200_9.txt','c:\tmp\CAL\depth\pc_200_10.txt' ...
	 } ...
	 
	 };
	
	% rois for 5 agust data
	%{
	roi = 170,  74  361 x 248 ==>  50
	roi = 218, 132  249 x 187 ==>  75
	roi = 239, 163  200 x 143 ==> 100
	roi = 239, 189  154 x 106 ==> 125
	roi = 285, 203  132 x  94 ==> 150
	roi = 294, 212  110 x  76 ==> 175
	roi = 275, 223   95 x  65 ==> 200
	
	common rectangle: 300, 225  35 x 45
	%}
	
	%DEPTH_DATA_TO_CORRECT = ['c:\tmp\cal\depth\sample_225.txt'];
	%depthDataToCorrectPlaneDistance = 2250;
	
	%distances = [500, 750, 1000, 1250, 1500, 1750, 2000];
	%depthDataMatrixSize = [576, 640];
	%rgbSqSize = 35;
	%irSqSize = 35;
	%roi_vector = [300, 335, 225, 270]; % [320, 350, 220, 240];

	fileID = fopen("results.txt", 'w');
	
	local_test_flag = true;
	
	if (local_test_flag)
		
		%fprintf("\nProcessing Depth Images to find depth cam params\n");
		%[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(...
		%		distances, DEPTH_PC_SAMPLE_DATA, depthDataMatrixSize(1), depthDataMatrixSize(2), [320, 350, 220, 240]);
		
		seqRgbImages = RGB_FILES;
		seqIrImages = IR_FILES;
		
		rgbSqSize = 35;
		irSqSize = 35;
		seqDistances = [500, 750, 1000, 1250, 1500, 1750, 2000];
		depthDataMatrixSize =  [576, 640];
		depthDataFileToBeCorrected = 'c:\tmp\cal\depth\sample_225.txt';
		depthDataToCorrectPlaneDistance = 2250;
		seqAllPointClouds = DEPTH_PC_SAMPLE_DATA;
		roiVector = [300, 335, 225, 270]; % [320, 350, 220, 240];

	else
		%Select RGB IMAGES from disk and store in an image array
		seqRgbImages = fun_ui_get_files("C:\", "Select multiple RGB images for RGB Camera Calibration!", 3);
		fprintf("\nSelected %d RGB calibration Images\n", numel(seqRgbImages));
		disp(seqRgbImages);

		%Select IR IMAGES from disk and store in an image array
		seqIrImages = fun_ui_get_files("C:\", "Select multiple IR images for IR Camera Calibration!", 3);
		fprintf("\nSelected %d IR calibration Images\n", numel(seqIrImages));
		disp(seqIrImages);
		
		prompt = {'Enter RGB calibration image square size (cm):',...
				'Enter IR calibration image square size (cm):',...
				'Enter depth image distances (cm):',...
				'Enter depth data size:'};
		dlgtitle = 'Please enter input parameters!';
		dims = [1 45; 1 45; 1 45; 1 45; 1 45];
		definput = {'25', '25', '50 100 150', '480 640', '300 335 225 270'};
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
			strTitle = sprintf("Select multiple point cloud data files for %d cm distance!", seqDistances(i));
			seqPointClouds = fun_ui_get_files(strTitle, 3);
			fprintf("\nSelected %d point cloud files for distance %d cm\n", numel(seqPointClouds), seqDistances(i));
			disp(seqPointClouds);
			seqAllPointClouds{i} = seqPointClouds;
		end
		
		fprintf("\nSelected %d point cloud files\n", numel(seqAllPointClouds));
		disp(seqAllPointClouds);

		%Select point cloud files for correction from disk and store in an array
		depthDataFileToBeCorrected = fun_ui_get_files("Select depth data file to correct!", 0);
		disp(depthDataFileToBeCorrected);
		
		prompt = {'Enter plane distance for which depth data to be corrected and analysed:'};
		dlgtitle = 'Please enter input parameters!';
		dims = [1 45];
		definput = {'2250'};
		answer = inputdlg(prompt, dlgtitle, dims, definput);
		
		depthDataToCorrectPlaneDistance	= str2num(answer{1});
		depthDataToCorrectPlaneDistance = uint16(depthDataToCorrectPlaneDistance);
		
    end

	fprintf("\nStarting RGB camera calibration\n");
	fprintf(fileID, "\n\nSTARTED\n\nRGB camera parameters:\n");
	[rgbCamParams] = fun_detect_camera_params(seqRgbImages, rgbSqSize, fileID);

	fprintf("\nStarting IR camera calibration\n");
	fprintf(fileID, "\n\nIR camera parameters:\n");
	[irCamParams] = fun_detect_camera_params(seqIrImages, irSqSize, fileID);

	fprintf("\nProcessing Depth Images to find depth cam params\n");
	[matMeanLinearModels, matStdevLinearModels] = fun_find_depth_camera_params(...
					seqDistances, seqAllPointClouds, depthDataMatrixSize(1),...
					depthDataMatrixSize(2), roiVector, fileID);
	
	fprintf("\nCorrect an image with the parameters\n");
	fun_k4a_calibration(irCamParams, matMeanLinearModels, depthDataMatrixSize, roiVector,...
		depthDataFileToBeCorrected, depthDataToCorrectPlaneDistance, fileID);
	
	fprintf(fileID, "\n\nEND\n");
	fclose(fileID);

	fprintf("\nEND: k4a depth camera calibration script\n");
	
% **********************************************************
