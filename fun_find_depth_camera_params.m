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

	%seqProbDistObjectMatrices = {};
	seqProbDistObjectMatrices = cell(1, numel(argDistances));
	matMeanLinearModels = {};
	matStdevLinearModels = {};
	
	rowCount = argDepthDataSize(1);
	colCount = argDepthDataSize(2);
	
	vectorTmp = zeros(1, 6);
	zero_pd_obj = fitdist (vectorTmp.', 'Normal');
	
	tic;
	fprintf("\nGoing to evaluate prob dist objects for each pixel of each distance\n");

	for i = 1 : numel(argDistances)
		fprintf("\nIterating %d, dist is %d\n", i, argDistances(i));
		
		%seqDepthDataFilePaths = argMeasurements(i, :).pcFilePaths;
		seqDepthDataFilePaths = argSeqOfDepthDataFilePathArray{i};
		
		%seqMatDepthData = {};
		seqMatDepthData = cell(1, numel(seqDepthDataFilePaths));
		for j = 1 : numel(seqDepthDataFilePaths)
			fprintf("\nIterating %d, of %d , file to read is %s\n ", j, numel(seqDepthDataFilePaths), seqDepthDataFilePaths{j});
			%disp(seqDepthDataFilePaths(j));
			%fprintf("\nGoing to process depth data file %s\n", seqDepthDataFilePaths(j));

			%matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, rowCount, colCount);
			%seqMatDepthData{j} = matDepthData;
			seqMatDepthData{j} = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, rowCount, colCount);
		end


		%matProbDistObjects = cell(rowCount / 2 , colCount / 2);
		matProbDistObjects = cell(rowCount, colCount);
		
		vectorTmp = zeros(1, numel(seqMatDepthData));
		
		for m = 1 : rowCount %/ 2
			for n = 1 : colCount %/ 2
				
				%vectorTmp = zeros(1, numel(seqMatDepthData));
				vectorTmp(:) = 0;
				
				for k = 1 : numel(seqMatDepthData)
					matDepthData = seqMatDepthData{k};
					vectorTmp(k) = matDepthData(m, n);
				end
				
				if (all(vectorTmp == 0)) %if all values are eq to zero
					matProbDistObjects{m, n} = zero_pd_obj;
				else
					if (all(vectorTmp)) %none are zero, we could simply evaluate
						pdobj = fitdist(vectorTmp.', 'Normal');
						matProbDistObjects{m, n} = pdobj;
					else
						%there are zeroes extract them and evaluate
						b = vectorTmp(vectorTmp ~= 0);
						pdobj = fitdist(b.', 'Normal');
						matProbDistObjects{m, n} = pdobj;
					end;
				end;
				
				%{
				vectorTmp(vectorTmp == 0) = [];
				if (isempty(vectorTmp))
					matProbDistObjects{m, n} = zero_pd_obj;
				else
					%probability dist object is found
					pdobj = fitdist(vectorTmp.', 'Normal');
					matProbDistObjects{m, n} = pdobj;
				end;
				%}
				
				%probability dist object is found
				%pdobj = fitdist(vectorTmp.', 'Normal');
				%matProbDistObjects{m, n} = pdobj;
			end
		end

		%Iterate seqMatDepthData and eval pd for pixel i, j and store it in a data structure
		%matProbDistObjects(i, j) = "some pd object";
		% add this matrix object into a cell array which coincides with distances vector
		% by means of indices, so the matrix at index 1 is the evaluated for the distance
		% at the index 1 of the distances 
		
		seqProbDistObjectMatrices{i} = matProbDistObjects;
	end
	
	toc;
	fprintf("Prob Dist Objects are evaluated \n");
	
	tic;
	fprintf("\nGoing to evaluate linear models based on distances\n");
	%for each pixel, iterate pd objects for each distance and evaluate linear models for mean and stdev 
	
	rowIndex = -1;
	colIndex = -1;
	meanVals = zeros(1, length(argDistances));
	
	for i = 1 : rowCount %/ 2
		
		for j = 1 : colCount %/ 2

			seqPdObjects = cell(1, numel(seqProbDistObjectMatrices));
			for p = 1 : numel(seqProbDistObjectMatrices)
				tmp = seqProbDistObjectMatrices{p};
				%fprintf("iterate %d", p);%disp (tmp);%disp ("+++++");%disp (tmp{i, j});%disp ("=====");
				seqPdObjects{p} = tmp{i, j};
			end
			
			%disp ("=====");%disp (seqPdObjects);%disp ("=====");

			%meanVals = zeros(1, length(seqPdObjects));
			meanVals(:) = 0;
			
			for p = 1 : length(seqPdObjects)
				%pdObject = seqPdObjects{p};
				%disp (p);disp (pdObject);  disp (sprintf("xxxxx\n"));
				%meanVals(p) = pdObject.mu;
				meanVals(p) = seqPdObjects{p}.mu;
			end
			

			%check meanVals, if all values are same and they are zero then
			%	check for an evaluation that has been done already and use that value again 
			
			if (all(meanVals == 0))
				if (rowIndex > 0 && colIndex > 0)
					matMeanLinearModels{i, j} = matMeanLinearModels{rowIndex, colIndex};
				else
					mdlMeanLM = fitlm (argDistances, meanVals);
					matMeanLinearModels{i, j} = mdlMeanLM;
					rowIndex = i;
					colIndex = j;
				end;
				
			else
				mdlMeanLM = fitlm (argDistances, meanVals);
				matMeanLinearModels{i, j} = mdlMeanLM;
			end;
			
			%{
			mdlMeanLM = fitlm (argDistances, meanVals);
			matMeanLinearModels{i, j} = mdlMeanLM;
			%}
			
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
	
	toc;
	fprintf("Linear models are evaluated \n");

	fprintf("\nEND: fun_find_depth_camera_params\n");
	return;
end
