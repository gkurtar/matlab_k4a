% ***********************************************************
% 
% fun_find_depth_camera_params
% 
% Parameters of the proposed calibration method is evaluated by this method.
% A probability distribution object is evaluated for each pixel of each distance where each
% probability distance object consists of mean and stddev field.
% Based on the distance, linear model of mean and stddev values of the corresponding
% probability distribution object of a pixel is evalauted. A linear model matrix for
% mean values and a linear model matrix for stddev values are detected and returned.
%
% INPUT:
%   argDistances			-> an array of distance values in cm
%	argSeqOfDepthDataFilePathArray	-> a cell array where each element is an array consisting of Depth data file paths
%	argDepthDataSize		-> a 1 x 2 array which represents row and col sizes of depth data;
%
% OUTPUT:
%	matMeanLinearModels	-> a 2D array (depth image sized) of linear model objects for mean values
%	matStdevLinearModels	-> a 2D array (depth image sized) of linear model objects for stddev values
%
% **********************************************************

function [ matMeanLinearModels, matStdevLinearModels ] = fun_find_depth_camera_params(argDistances, argSeqOfDepthDataFilePathArray, argDepthDataSize)

	fprintf("\nBEGIN: fun_find_depth_camera_params\n"); 
	
	%argument check could be added

	%seqProbDistObjectMatrices = {};
	seqProbDistObjectMatrices = cell(1, numel(argDistances));
	matMeanLinearModels = {};
	matStdevLinearModels = {};
	
	rowCount = argDepthDataSize(1);
	colCount = argDepthDataSize(2);
	
	tic;
	fprintf("\nGoing to evaluate prob dist objects for each pixel of each distance\n");

	for i = 1 : numel(argDistances)
		fprintf("\nIterating %d, dist is %d\n", i, argDistances(i));
		
		%seqDepthDataFilePaths = argMeasurements(i, :).pcFilePaths;
		seqDepthDataFilePaths = argSeqOfDepthDataFilePathArray{i};
		
		seqMatDepthData = {};
		%seqMatDepthData = cell(numel(seqDepthDataFilePaths));
		for j = 1 : numel(seqDepthDataFilePaths)
			fprintf("\nIterating %d, of %d , file is %s\n ", j, numel(seqDepthDataFilePaths), seqDepthDataFilePaths{j});
			disp(seqDepthDataFilePaths(j));
			%fprintf("\nGoing to process depth data file %s\n", seqDepthDataFilePaths(j));

			%matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, rowCount, colCount);
			%seqMatDepthData{j} = matDepthData;
			seqMatDepthData{j} = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, rowCount, colCount);
		end

		%matProbDistObjects = {};
		matProbDistObjects = cell(rowCount / 4, colCount / 4);
		
		%[rows, cols] = size(matDepthData);
		for m = 1 : rowCount / 4 %rows / 100
			%fprintf("processing row %d\n", m);
			for n = 1 : colCount / 4 % cols / 100
				vectorTmp = zeros(1, numel(seqMatDepthData));
				for k = 1 : numel(seqMatDepthData)
					matDepthData = seqMatDepthData{k};
					vectorTmp(k) = matDepthData(m, n);
				end
				
				%probability dist object is found
				pdobj = fitdist(vectorTmp.', 'Normal');
				matProbDistObjects{m, n} = pdobj;
			end
		end

		%Iterate seqMatDepthData and eval pd for pixel i, j and store it in a data structure
		%matProbDistObjects(i, j) = "some pd object";
		%add this data structure into a table where each row represents the
		%record for the corresponding distance

		seqProbDistObjectMatrices{i} = matProbDistObjects;
	end
	
	toc;
	fprintf("Prob Dist Objects are evaluated \n");
	
	tic;
	fprintf("\nGoing to evaluate linear models based on distances\n");
	%for each pixel, iterate pd objects for each distance and evaluate linear models for mean and stdev 
	for i = 1 : rowCount / 4 % argDepthDataSize(1) / 100
		
		for j = 1 : colCount / 4 % argDepthDataSize(2) / 100

			seqPdObjects = {};
			for p = 1 : numel(seqProbDistObjectMatrices)
				tmp = seqProbDistObjectMatrices{p};
				%fprintf("iterate %d", p);%disp (tmp);%disp ("+++++");%disp (tmp{i, j});%disp ("=====");
				seqPdObjects{p} = tmp{i, j};
			end
			
			%disp ("=====");%disp (seqPdObjects);%disp ("=====");

			meanVals = zeros(1, length(seqPdObjects));
			for p = 1 : length(seqPdObjects)
				%pdObject = seqPdObjects{p};
				%disp (p);disp (pdObject);  disp (sprintf("xxxxx\n"));
				%meanVals(p) = pdObject.mu;
				meanVals(p) = seqPdObjects{p}.mu;
			end
			
			mdlMeanLM = fitlm (argDistances, meanVals);
			%plot (mdlMeanLM);
			matMeanLinearModels{i, j} = mdlMeanLM;
			
			%{
			stdevVals = zeros(1, length(seqPdObjects));
			for p = 1 : length(seqPdObjects)
				stdevVals(p) = seqPdObjects{p}.sigma;
			end

			mdlStdDevLM = fitlm (argDistances, stdevVals);
			matStdevLinearModels{i, j} = mdlStdDevLM;
			%}
		end
	end
	
	%disp(matMeanLinearModels);
	%disp(matStdevLinearModels);

	toc;
	fprintf("Linear models are evaluated \n");

	fprintf("\nEND: fun_find_depth_camera_params\n");
	return;
end
