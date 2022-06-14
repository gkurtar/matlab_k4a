% ***********************************************************
% 
% fun_undistort_depth_data function
% K4A Depth Camera Calibration and undistortion is done by this method
% 10 Haziran 2020
%
% INPUT:
%
%   argDepthData	-> Depth Point Cloud as an array imported from a file of triples
%					where each line contains coordinates of a pixel and the corresponding
%					depth value in it. The dims of this array should be [argRowCount * argColCount] [3].
%					
%   argRowCount		-> Row Count of the Depth Data
%   argColCount		-> Column Count of the Depth Data
%   argCameraParams -> IR(Depth) camera parameters
%
% OUTPUT: 
%   correctedImage  -> corrected image as a two dimensional (depth point cloud) array where its
%					sizes are eq to argRowCount and argColCount.
%
% **********************************************************

function [ correctedImage ] = fun_undistort_depth_data(argDepthData, argRowCount, argColCount, argCameraParams)

	RESULT_PATH = "c:\tmp\cal\";
	fprintf("\nBEGIN: fun_undistort_depth_data\n");

	%depthFile = fullfile('d:\', 'work', 'sample_depth_data.txt'); %sprintf('rgb%d.png', i));
	%depthFile = fullfile('sample_depth_data.txt'); %sprintf('rgb%d.png', i));
	%argDepthData = importdata(depthFile);
	[sz_rows, sz_cols] = size(argDepthData);
	%fprintf("%s file is imported, sizes are %d %d \n", depthFile, sz_rows, sz_cols);
	fprintf("depth data sizes are %d %d \n", sz_rows, sz_cols);

	colIndex = 3;
	seqDepthImage = zeros(argRowCount, argColCount);
	for i = 1:argRowCount
		for j = 1:argColCount
			rowIndex = (i - 1) * argColCount + j;
			%seqDepthImage(i, j) = 0;
			%if (j == 20)
			%    fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, argDepthData(rowIndex, colIndex));
			%end
			seqDepthImage(i, j) = argDepthData(rowIndex, colIndex);
		end
	end

	figure;
	title('Original');
	imgResult = imshow(seqDepthImage, []);

	figure;
	%size(imgResult.CData)
	%fprintf("\nresult_img %s %d", ...
	%    imgResult.Type, imgResult.CData(12, 34));

	imgTemp = undistortImage(imgResult.CData, argCameraParams);
	imgUndistortedDepthData = imshow(imgTemp);
	title('Corrected');

	%fprintf("\nresult_img %s %d", ...
	%    imgUndistortedDepthData.Type, imgUndistortedDepthData.CData(12, 34));

	%fileID = fopen('ud_depth.txt', 'w');
	fileID = fopen(strcat(RESULT_PATH, "ud_depth.txt"), 'w');
	
	correctedImage = zeros(argRowCount, argColCount);
	for i=1:argRowCount
		for j=1:argColCount
			%fprintf(fileID, "%d %d %d\n", i, j, imgUndistortedDepthData.CData(i, j));
			fprintf(fileID, "%d %d %d\n", i, j, cast(imgUndistortedDepthData.CData(i, j), "uint16"));
			correctedImage(i, j) = cast(imgUndistortedDepthData.CData(i, j), "uint16");
		end
	end
	
	imshow(correctedImage, []);
	
	fclose(fileID);
	fprintf("\ngenerated undistorted depth data");

	fprintf("\nEND: fun_undistort_depth_data");
	return;
end
