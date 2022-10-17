% ***********************************************************
% 
% fun_undistort_depth_data
%
% K4A depth images are undistorted via IR camera params by this method.
% Corrected image is returned as an m by n matrix where its sizes are same with the input array.
%
% INPUT:
%   argDepthData	-> a 2D array of size [argRowCount * argColCount] which represents Depth Point Cloud.
%   argRowCount		-> Row Count of the Depth Data
%   argColCount		-> Column Count of the Depth Data
%   argCameraParams -> IR(Depth) camera parameters
%
% OUTPUT: 
%   resCorrectedImage	-> corrected image as a two dimensional (depth point cloud) array where its size is eq to [argRowCount] [argColCount]
%
% **********************************************************

function [ resCorrectedImage ] = fun_undistort_depth_data(argDepthData, argRowCount, argColCount, argCameraParams)

	fprintf("\nBEGIN: fun_undistort_depth_data\n");

	figure;
	title('Original Depth Data');
	hold on;
	imgResult = imshow(argDepthData, []);
	hold off;
	
	figure;
	title('Corrected Depth Data');
	hold on;
	imgTemp = undistortImage(imgResult.CData, argCameraParams);
	imgUndistortedDepthData = imshow(imgTemp, []);
	hold off;

	fileID = fopen('undistorted_depth_data.txt', 'w');
	%RESULT_PATH = "c:\work\article\data\cal\";
	%fileID = fopen(strcat(RESULT_PATH, "ud_depth.txt"), 'w');
	
	resCorrectedImage = zeros(argRowCount, argColCount);
	for i=1:argRowCount
		for j=1:argColCount
			%fprintf(fileID, "%d %d %d\n", i, j, imgUndistortedDepthData.CData(i, j));
			fprintf(fileID, "%d %d %d\n", i, j, cast(imgUndistortedDepthData.CData(i, j), "uint16"));
			resCorrectedImage(i, j) = cast(imgUndistortedDepthData.CData(i, j), "uint16");
		end
	end
	
	%imshow(seqDepthImage, []);
	
	fclose(fileID);
	fprintf("\ngenerated undistorted depth data");

	fprintf("\nEND: fun_undistort_depth_data");
	return;
end
