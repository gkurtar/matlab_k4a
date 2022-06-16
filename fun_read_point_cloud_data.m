% ***********************************************************
% fun_read_point_cloud_data
%
% % Input Arguments:
%		argFilePath     -> Path of the file where each line consist of the triplets (row, col, depth)
%		argRowCount		-> Number of the rows in the depth image
%		argColCount		-> Number of the columns in the depth image
%
% % Output Values:
%		matDepthData	-> Depth Data matrix
%
% **********************************************************

function [matDepthData] = fun_read_point_cloud_data(argFilePath, argRowCount, argColCount)

	fprintf("\nBEGIN: fun_read_point_cloud_data\n");

	%input control
	if exist(argFilePath, 'file') ~= 2
		error(sprintf("input file %s does not exist\n", argFilePath));
	elseif (~isnumeric(argRowCount) || ~isnumeric(argColCount))
		error("arguments should be numeric\n");
	%elseif (~isinteger(int16(argRowCount)) || ~isinteger(int16(argColCount)))
	%	error("arguments should be integer");
	elseif (mod(argRowCount, 1) ~= 0 || mod(argColCount, 1) ~= 0)
		error(sprintf("both %d and %d should be of type integer \n", argRowCount, argColCount));
	elseif (argRowCount <= 0 || argColCount <= 0)
		error("Row and Col count arguments should be gt zero");
	end

	tmp = importdata(fullfile(argFilePath));
	[rows, cols] = size(tmp);
	
	%extra control
	if (argRowCount * argColCount ~= rows)
		error("Size of the data file does not match up with row and col count arguments provided");
	elseif (3 ~= cols)
		error("Input data file should consist of triplets.\n");
    	end
	
	fprintf("%s file is imported, sizes are %d %d \n", argFilePath, rows, cols);
	colIndex = 3;
	matDepthData = zeros(argRowCount, argColCount);

	for i = 1 : argRowCount
		for j = 1 : argColCount
			rowIndex = (i - 1) * cols + j;
			matDepthData(i, j) = tmp(rowIndex, colIndex);
			%if (j == 20) fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, matDepthData(i, j));
		end
	end

	fprintf("\nEND: fun_read_point_cloud_data\n");
end
