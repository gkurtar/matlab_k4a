%*******************************************************************************************
%
% This function returns Ground Truth
%
% Input Arguments:
%    argDepthDataFile	-> full file path of the depth data (point cloud)
%    argDepthDataSize   -> a 1x2 vector denoting the size ( row and col count) of the depth data image matrix
%
% Output Values:
%    resGroundTruth		-> Ground Truth
%
%*******************************************************************************************
function [ resGroundTruth ] = fun_get_ground_truth(argDepthDataFile, argDepthDataSize)

	fprintf("\nBEGIN: fun_get_ground_truth\n");
	
	depthData = fun_read_point_cloud_data(depthDataFilePath, argDepthDataSize(1), argDepthDataSize(2));
	
	fprintf("\nEND: fun_get_ground_truth\n");
	return;
end
