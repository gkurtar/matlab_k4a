
% ***********************************************************
% 
% fun_k4a_foo function
% K4A Depth Camera Calibration is done by this method.
% Parameters for probability Based depth camera cal scheme is detected by
% this method.
% 16 Haziran 2020
%
% INPUT:
%
%   argIrCampParams -> an array of IR images of a planar checkerboard pattern 	(IR camera params are to be estimated)
%   argMeasurements -> a table where each row contains info for a specific distance
%							Col 1 (ranges) (Integer): Sampling Distance in cm
%							Col 2 (irFilePaths) (String): IR Image file path (Average)
%							Col 3 (pcFilePaths) (String):  a sequence of depth data (point cloud) files
%							Col 4 (depthDataSizes) (1x2 double): Point Cloud matrix dimensions
%
% OUTPUT: 
%   depthCameraCalibrationParamMatrix -> TBD
%
% **********************************************************

function [ depthCameraCalibrationParamMatrix ] = fun_k4a_foo(argMeasurements)
%function [ correctedImage ] = fun_k4a_calibration(...
%	argRgbImages, argRgbSquareSize, argIrImages, argIrSquareSize, argMeasurements)

	fprintf("\nBEGIN: fun_k4a_calibration\n");
    
    %if (3 < 5) return;

	%fprintf("\nStarting RGB camera calibration\n");
	%disp(argRgbImages);
	%rgbCamParams = fun_detect_camera_params(argRgbImages, argRgbSquareSize);

	%fprintf("\nStarting IR camera calibration\n");
	%disp(argIrImages);
	%irCamParams = fun_detect_camera_params(argIrImages, argIrSquareSize);

	fprintf("\nUndistorting Depth Image\n");
	%seqUndistortedDepthData = {};
	tableRowCount = height(argMeasurements);

    matProbDistObjects = {};
    seqMatDepthData = {};
	for i = 1 : tableRowCount
        %depthDataAvgFilePath = argMeasurements(i, :).pcAvgFilePaths;

		seqDepthDataFilePaths = argMeasurements(i, :).pcFilePaths;
        depthDataDim = argMeasurements(i, :).depthDataSizes;
		sizes = [depthDataDim{1}];
		
        %disp(seqDepthDataFilePaths);

        disp ("____")
        disp (sizes)
        
        matDepthData = {};
        for j = 1 : numel(seqDepthDataFilePaths)
            disp(seqDepthDataFilePaths(j));
            %matDepthData = [matDepthData ; importdata(seqDepthDataFilePaths(j))];
            tmp = importdata(seqDepthDataFilePaths(j));

            [rows, cols] = size(tmp);
	        fprintf("%s file is imported, sizes are %d %d \n", seqDepthDataFilePaths(j), rows, cols);

    
            colIndex = 3;
            matDepthData = zeros(rows, cols);
            for m=1:rows
                for n=1:cols
                    rowIndex = (i - 1) * cols + j;
                    %dimg_mat(i, j) = 0;
                    %if (j < 20)
                        %fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, depthData(rowIndex, colIndex));
                    %end
                    matDepthData(i, j) = tmp(rowIndex, colIndex);
                end
            end


        end
        disp ("++++")


        %matTmp = matDepthData(1);
        %disp(matTmp);


		%fprintf("\ndepthDataFilePath: %s, Depth Data Dim:  %d __ \n", depthDataFilePath, depthDataDim{1, :});

		%if (~exist(depthDataAvgFilePath, 'file'))
        %    warningMessage = sprintf("Warning: file does not exist:\n%s", depthDataAvgFilePath);
		%	error(warningMessage); %uiwait(msgbox(warningMessage));
        %end

		% File exists.  Do stuff....
		%depthData = importdata(depthDataFilePath);
		%undistortedDepthData = fun_undistort_depth_data(depthData, sizes(1), sizes(2), irCamParams);
		
        %seqUndistortedDepthData = [seqUndistortedDepthData ; undistortedDepthData];
		%fprintf("%s is undistorted:\n", depthDataFilePath);
		
    end

    %{
    for i = 1 : tableRowCount
		depthDataFilePath = argMeasurements(i, :).pcFilePaths;
		depthDataDim = argMeasurements(i, :).depthDataSizes;
		sizes = [depthDataDim{1}];
		fprintf("\ndepthDataDim:\n");
		%disp(depthDataDim{1});
		%disp(sizes(1)); %disp(sizes(2));
		%fprintf("\ndepthDataFilePath: %s, Depth Data Dim:  %d __ \n", depthDataFilePath, depthDataDim{1, :});

		if exist(depthDataFilePath, 'file')
			% File exists.  Do stuff....
			depthData = importdata(depthDataFilePath);
			undistortedDepthData = fun_undistort_depth_data(depthData, sizes(1), sizes(2), irCamParams);
			seqUndistortedDepthData = [seqUndistortedDepthData ; undistortedDepthData];
			fprintf("%s is undistorted:\n", depthDataFilePath);
		else
			warningMessage = sprintf("Warning: file does not exist:\n%s", depthDataFilePath);
			error(warningMessage); %uiwait(msgbox(warningMessage));
		end
    end
    %}

	fprintf("\nEND: fun_k4a_calibration\n");
	return;
end
