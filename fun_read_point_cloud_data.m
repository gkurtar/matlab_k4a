% ***********************************************************
% detect_errors metod compares two datasets to determine errors
%
% % Input Arguments:
%    argMeasuredDepthValues     -> Measured Sensor Depth Data for a number of points
%    argRealDepthValues     -> Real Depth Data for corresponding points
%
% % Output Values:
%    RMSE -> root mean square error for the datasets as arguments
%    SDEV ->  standard deviation
%
% **********************************************************

function [matDepthData] = fun_read_point_cloud_data(argFilePath, argRowCount, argColCount)

	fprintf("\nBEGIN: fun_read_point_cloud_data\n");

	%input control
	if exist(argFilePath, 'file') ~= 2
		error("input file does not exist");
	elseif (~isnumeric(argRowCount) || ~isnumeric(argColCount))
		error("arguments should be numeric\n");
	elseif (argRowCount <= 0 || argColCount <= 0)
		error("Row and Col count arguments should be gt zero \n");
	end

	tmp = importdata(fullfile(argFilePath));
	[rows, cols] = size(tmp);
	fprintf("%s file is imported, sizes are %d %d \n", argFilePath, rows, cols);

	%extra control
	if (argRowCount * argColCount ~= rows)
		error("Size of the data file does not match up with row and col count arguments provided");
	elseif (3 ~= cols)
		error("Input data file should consist of triplets.\n");
    end

	colIndex = 3;
	matDepthData = zeros(argRowCount, argColCount);

	for i = 1 : argRowCount
		for j = 1 : argColCount
			rowIndex = (i - 1) * cols + j;
			matDepthData(i, j) = tmp(rowIndex, colIndex);
			%if (j == 20)
			%	fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, matDepthData(i, j));
			%end
		end
	end

	fprintf("\nEND: fun_read_point_cloud_data\n");
end

