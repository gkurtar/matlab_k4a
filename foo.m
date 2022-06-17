
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

	fprintf("\nBEGIN: fun_k4a_foo\n"); 

	tableRowCount = height(argMeasurements);
	resultCellArray = {};

	for i = 1 : tableRowCount
		fprintf("\nIterating row %d, dist is %d\n", i, argMeasurements(i, :).ranges);

		distance = argMeasurements(i, :).ranges;
		seqDepthDataFilePaths = argMeasurements(i, :).pcFilePaths;
		depthDataDims = argMeasurements(i, :).depthDataSizes;
		sizes = [depthDataDims{1}];
		
		%disp(seqDepthDataFilePaths);

		seqMatDepthData = {};
		for j = 1 : numel(seqDepthDataFilePaths)
			disp(seqDepthDataFilePaths(j));
			fprintf("\nGoing to process depth data file %s\n", seqDepthDataFilePaths(j));

			matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths(j), sizes(1), sizes(2));
			seqMatDepthData{j} = matDepthData;
		end

		matProbDistObjects = {};
		[rows, cols] = size(matDepthData);
		for m = 1 : rows / 100
			%fprintf("processing row %d\n", m);
			for n = 1 : cols / 100
				vectorTmp = zeros(1, numel(seqMatDepthData));
				for k = 1 : numel(seqMatDepthData)
					matDepthData = seqMatDepthData{k};
					vectorTmp(k) = matDepthData(m, n);
					%fprintf("checking %d %d and %d\n", m, n, k);
				end
				%disp(vectorTmp);
				
				%probability dist object is found
				pdobj = fitdist(vectorTmp.', 'Normal');
				matProbDistObjects{m, n} = pdobj;
			end
		end

		%Iterate seqMatDepthData and eval pd for pixel i, j and store it in a data structure
		%matProbDistObjects(i, j) = "some pd object";
		%add this data structure into a table where each row represents the
		%record for the corresponding distance

		resultCellArray{i, 1} = cast(distance, "int16");
		resultCellArray{i, 2} = matProbDistObjects;

		%disp (matProbDistObjects)
	end
	disp (resultCellArray);

	fprintf("\nEND: fun_k4a_foo\n");
	return;
end
