% ***********************************************************
% 
% fun_find_depth_camera_params
% 
% Parameters of the proposed calibration method is evaluated by this method.
% A probability distribution object is evaluated for each pixel of each distance where each
% probability distance object consists of mean and stddev field.
% Based on the distance, linear model of mean and stddev values of the corresponding
% probability distribution object of a pixel is evalauted. A linear model matrix for mean values and a
% linear model matrix for stddev values are detected and returned.
%
% INPUT:
%
%	argMeasurements		-> a table where each row contains info for a specific distance
%					Col 1 (ranges) (Integer): Sampling Distance in cm
%					Col 2 (irFilePaths) (String): IR Image file path (Average)
%					Col 3 (pcFilePaths) (String): A sequence of depth data file paths for the specified distance
%
%	argDepthDataSize	-> argDepthDataSize, a 1 x 2 array which represents row and col sizes of depth data;
%
% OUTPUT: 
%	matMeanLinearModels	-> a 2D array (depth image sized) of linear model objects for mean values
%	matStdevLinearModels	-> a 2D array (depth image sized) of linear model objects for stddev values
%
% **********************************************************

function [ matMeanLinearModels, matStdevLinearModels ] = fun_find_depth_camera_params(argMeasurements, argDepthDataSize)

	fprintf("\nBEGIN: fun_find_depth_camera_params\n"); 

	seqProbDistObjectMatrices = {};
	matMeanLinearModels = {};
	matStdevLinearModels = {};
	
	tableRowCount = height(argMeasurements);
	seqDistances = argMeasurements.ranges;
	rowCount = argDepthDataSize(1);
	colCount = argDepthDataSize(2);
	%rowCount = cast( argDepthDataSize(1), 'int16') / 100;
	%colCount = cast( argDepthDataSize(2), 'int16') / 100;
	
	tic;

	for i = 1 : tableRowCount
		fprintf("\nIterating row %d, dist is %d\n", i, argMeasurements(i, :).ranges);

		%distance = argMeasurements(i, :).ranges;
		seqDepthDataFilePaths = argMeasurements(i, :).pcFilePaths;
		%depthDataDims = argMeasurements(i, :).depthDataSizes;
		%sizes = [depthDataDims{1}];

		seqMatDepthData = {};
		for j = 1 : numel(seqDepthDataFilePaths)
			disp(seqDepthDataFilePaths(j));
			fprintf("\nGoing to process depth data file %s\n", seqDepthDataFilePaths(j));

			%matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths(j), sizes(1), sizes(2));
			matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths(j), rowCount, colCount);
			seqMatDepthData{j} = matDepthData;
		end

		matProbDistObjects = {};
		%[rows, cols] = size(matDepthData);
		for m = 1 : rowCount / 50 %rows / 100
			%fprintf("processing row %d\n", m);
			for n = 1 : colCount / 50 % cols / 100
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

		%seqProbDistObjectMatrices{i, 1} = cast(distance, "int16");
		%seqProbDistObjectMatrices{i, 2} = matProbDistObjects;
		seqProbDistObjectMatrices{i} = matProbDistObjects;

		%disp (matProbDistObjects)
	end
	%disp (seqProbDistObjectMatrices);
	
	fprintf("\nGoing to evaluate linear models based on distances\n");
	
	%for each pixel, iterate pd objects for each distance and evaluate linear models for mean and stdev 
	for i = 1 : rowCount / 50 % argDepthDataSize(1) / 100
		
		for j = 1 : colCount / 50 % argDepthDataSize(2) / 100
		
			seqPdObjects = {};
			for p = 1 : numel(seqProbDistObjectMatrices)
				tmp = seqProbDistObjectMatrices{p};
				%fprintf	("iterate %d", p);
				
				%disp (tmp);
				%disp ("+++++");
				%disp (tmp{i, j});
				%disp ("=====");
				
				seqPdObjects{p} = tmp{i, j};
			end
			
			%disp ("=====");
			%disp (seqPdObjects);
			%disp ("=====");

			meanVals = zeros(1, length(seqPdObjects));
			for p = 1 : length(seqPdObjects)
				%pdObject = seqPdObjects{p};
				%disp (p);disp (pdObject);  disp (sprintf("xxxxx\n"));
				%fprintf("\nEND: fun_k4a_foo %s\n", pdObject);
				%meanVals(p) = pdObject.mu;
				meanVals(p) = seqPdObjects{p}.mu;
			end

			stdevVals = zeros(1, length(seqPdObjects));
			for p = 1 : length(seqPdObjects)
				stdevVals(p) = seqPdObjects{p}.sigma;
			end

			mdlMeanLM = fitlm (seqDistances, meanVals);
			%plot (mdlMeanLM);

			mdlStdDevLM = fitlm (seqDistances, stdevVals);
			%plot(mdlStdDevLM);
			
			matMeanLinearModels{i, j} = mdlMeanLM;
			matStdevLinearModels{i, j} = mdlStdDevLM;

		end
	end
	
	%disp(matMeanLinearModels);
	disp("sdf");
	%disp(matStdevLinearModels);

	toc;

	fprintf("\nEND: fun_find_depth_camera_params\n");
	return;
end
