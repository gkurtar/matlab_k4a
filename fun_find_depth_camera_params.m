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
%   argDistances			        -> an array of distance values in cm
%	argSeqOfDepthDataFilePathArray	-> a cell array where each element is an array consisting of Depth data file paths
%   argImageHeight                  -> Depth Image Height
%   argImageWidth                   -> Depth Image Width
%	argRoiVector                    -> Roi Vector which consists of X min, X max, Y min and Y max.
%   argFileID	                    -> file handle
%
% OUTPUT:
%	matMeanLinearModels	-> a 2D array (depth image sized) of linear model objects for mean values
%	matStdevLinearModels	-> a 2D array (depth image sized) of linear model objects for stddev values
%
% **********************************************************

%function [ matMeanLinearModels, matStdevLinearModels ] = fun_find_depth_camera_params(...
%	argDistances, argSeqOfDepthDataFilePathArray, argImageHeight, argImageWidth, argRoiVector, argFileID)

% ver 2	
function [ matMeanLinearModels, matStdevLinearModels ] = fun_find_depth_camera_params(...
	argDistances, argSeqOfDepthDataFilePathArray, argseqAverageDepthImageFilePath,...
	argImageHeight, argImageWidth, argRoiVector, argFileID)

	fprintf("\nBEGIN: fun_find_depth_camera_params\n");
	seqProbDistObjectMatrices = cell(1, numel(argDistances));
	%matMeanLinearModels = {}; 	%matStdevLinearModels = {};
	
	matMeanLinearModels = cell(argImageHeight, argImageWidth);
	matStdevLinearModels = cell(argImageHeight, argImageWidth);
	%matEvalPixels = zeros(argImageHeight, argImageWidth);
	
	vectorTmp = zeros(1, numel(argDistances));
	zero_pd_obj = fitdist (vectorTmp.', 'Normal');
	zero_linear_model = fitlm(vectorTmp, vectorTmp);
	
	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nProbabililty Distribution objects for each distance are to be evaluated.");
	fprintf(argFileID, "\nLinear models of these objects based on distances are to be evaluated.");
	%strROI = evalc('disp(argRoiVector)');
	%fprintf(argFileID, "\nEvaluations would be done for the ROI rectangle %s\n", strROI);
	fprintf(argFileID, "\nEvaluations would be done for the ROI rectangle:");
	fprintf(argFileID, "(x_min, y_min): (%d, %d) and (x_max, y_max): (%d, %d)\n\n", ...
		argRoiVector(1), argRoiVector(3), argRoiVector(2), argRoiVector(4));
	
	roi_x_min = argRoiVector(1);
	roi_x_max = argRoiVector(2);
	roi_y_min = argRoiVector(3);
	roi_y_max = argRoiVector(4);
	
	fprintf("roi points are x min: %d, x max: %d, y min: %d, y max: %d", roi_x_min, roi_x_max, roi_y_min, roi_y_max);

	tic;
	fprintf("\nGoing to evaluate prob dist objects for each pixel of each distance\n");
	
	avgValueDepthImage = zeros(argImageHeight, argImageWidth);
	avgValueDepthImagePc = zeros(argImageHeight * argImageWidth, 3);

	for i = 1 : numel(argDistances)
		fprintf("\nIterating %d, dist is %d\n", i, argDistances(i));
		
		seqDepthDataFilePaths = argSeqOfDepthDataFilePathArray{i};
		
		seqMatDepthData = cell(1, numel(seqDepthDataFilePaths));
		for j = 1 : numel(seqDepthDataFilePaths)
			fprintf("\nIterating %d, of %d , file to read is %s\n ", j, numel(seqDepthDataFilePaths), seqDepthDataFilePaths{j});
			%fprintf("\nGoing to process depth data file %s\n", seqDepthDataFilePaths(j));

			%matDepthData = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, argImageHeight, argImageWidth);
			%seqMatDepthData{j} = matDepthData;
			seqMatDepthData{j} = fun_read_point_cloud_data(seqDepthDataFilePaths{j}, argImageHeight, argImageWidth);
		end

		matProbDistObjects = cell(argImageHeight, argImageWidth);
		
		%vectorTmp is a row vector where each element would be the evaluated value for the corresponding pixel.
		vectorTmp = zeros(1, numel(seqMatDepthData));
		
		%to get actual value for a pixel: 
		% ver 1: simply use distance as actual value
		%			actual_value_for_pixel = argDistances(i);
		% ver 2: we need to find ground truth image based on the average image
		%			averageDepthImageFilePath = argseqAverageDepthImageFilePath(i);
		%			resGroundTruthImage = fun_get_ground_truth(...
		%				averageDepthImageFilePath, argImageHeight, argImageWidth, argDistances(i), argFileID);
		% ver 3: simply find the avg for each pixel
		%			The avg value for a pixel could be used as actual value.
		%			vectorTmpUpdated = filloutliers(vectorTmp, "linear");
		%			actual_value_for_pixel = mean(vectorTmpUpdated);
		% ver 4: simply find the avg for each pixel
		%			actual_value_for_pixel could also be evaluated via a fitting plane model
		%			Ground truth image could be evalauted based on these values and actual value is found from this image
		%

		

		% ver 4, is evaluated here
		%{
		for m = 1 : argImageHeight
			for n = 1 : argImageWidth
				rowIndex = (m - 1) * argImageWidth + n;
				
				%reset vectorTmp 
				vectorTmp(:) = 0;
				
				for k = 1 : numel(seqMatDepthData)
					matDepthData = seqMatDepthData{k};
					vectorTmp(k) = matDepthData(m, n);
				end
				
				vectorTmpUpdated = filloutliers(vectorTmp, "linear");
				avgValueDepthImage(m, n) = round(mean(vectorTmpUpdated));
				
				avgValueDepthImagePc(rowIndex, 1) = m;
				avgValueDepthImagePc(rowIndex, 2) = n;
				avgValueDepthImagePc(rowIndex, 3) = avgValueDepthImage(m, n);
			end;
		end;
		
		resAverageValuesFittedImage = fun_get_ground_truth_2(...
			avgValueDepthImagePc, argImageHeight, argImageWidth, argDistances(i), argFileID);
		%}

		averageDepthImageFilePath = argseqAverageDepthImageFilePath{i};
		resAverageValuesFittedImage = fun_get_ground_truth_3(...
			averageDepthImageFilePath, argImageHeight, argImageWidth, argRoiVector, argDistances(i), false, argFileID);

		% -------------------------------------------------
		% ver 1
		actual_value_for_pixel = argDistances(i);
		% -------------------------------------------------
		
		for m = 1 : argImageHeight		
			for n = 1 : argImageWidth
				
				% ------------------------------------------------------
				% ver 4, ver 2
				%actual_value_for_pixel = resAverageValuesFittedImage(m, n);
				% ------------------------------------------------------
				
				if (n < roi_x_min || n > roi_x_max ...
					|| m < roi_y_min || m > roi_y_max )
					matProbDistObjects{m, n} = zero_pd_obj;
					continue;
				end;

				%reset vectorTmp 
				vectorTmp(:) = 0;
				
				for k = 1 : numel(seqMatDepthData)
					matDepthData = seqMatDepthData{k};
					vectorTmp(k) = matDepthData(m, n);
				end
				%vectorTmp now contains measured values for the corresponding pixel.
				
				%vectorTmp = rmoutliers(vectorTmp);
				
				% ver 3
				%actual value could be evaluated by averaging values of vectorTmp
				%vectorTmpUpdated = filloutliers(vectorTmp, "linear");
				%actual_value_for_pixel = round(mean(vectorTmpUpdated));

				if (all(vectorTmp == 0)) %if all values are eq to zero
					matProbDistObjects{m, n} = zero_pd_obj;
				else
			
					if (all(vectorTmp)) %none are zero, we could simply evaluate
						vectorTmp = vectorTmp - actual_value_for_pixel;
						pdobj = fitdist(vectorTmp.', 'Normal');
						
						matProbDistObjects{m, n} = pdobj;
					else
						%there are zeroes extract them and evaluate
						b = vectorTmp(vectorTmp ~= 0);
						
						if (length(b) > 1)
							%vectorTmp = vectorTmp - actual_value_for_pixel;
							b = b - actual_value_for_pixel;
						
							pdobj = fitdist(b.', 'Normal');
							matProbDistObjects{m, n} = pdobj;
						else
							matProbDistObjects{m, n} = zero_pd_obj;
						end;
					end;
				end;
				
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
	fprintf("Probability Distribution Objects are evaluated \n");
	
	tic;
	fprintf("\nGoing to evaluate linear models based on distances\n");
	%for each pixel, iterate pd objects for each distance and evaluate linear models for mean and stdev 
	
	rowIndex = -1;
	colIndex = -1;
	meanVals = zeros(1, length(argDistances));
	stdevVals = zeros(1, length(argDistances));

	for i = 1 : argImageHeight %/ 2
		
		for j = 1 : argImageWidth %/ 2

			if (j < roi_x_min || j > roi_x_max ...
				|| i < roi_y_min || i > roi_y_max )
				matMeanLinearModels{i, j} = zero_linear_model;
				continue;
			end;
			
			meanVals = zeros(1, length(argDistances));
			stdevVals = zeros(1, length(argDistances));

			seqPdObjects = cell(1, numel(seqProbDistObjectMatrices));
			for p = 1 : numel(seqProbDistObjectMatrices)
				tmp = seqProbDistObjectMatrices{p};
				%fprintf("iterate %d", p);%disp (tmp);%disp ("+++++");%disp (tmp{i, j});%disp ("=====");
				seqPdObjects{p} = tmp{i, j};
			end

			meanValsTmp = [];
			distancesMeanTmp = [];
			stdevValsTmp = [];
			distancesStdevTmp = [];
			
			k = 1;
			t = 1;
			%check meanVals alongside distances, only store non-zero values with the corresponding distances
			for p = 1 : length(seqPdObjects)
				
				meanVals(p) = seqPdObjects{p}.mu;
				
				if (seqPdObjects{p}.mu ~= 0)
					meanValsTmp(k) = seqPdObjects{p}.mu;
					distancesMeanTmp(k) = argDistances(p);
					k = k + 1;
				end;
				
				stdevVals(p) = seqPdObjects{p}.sigma;
				
				if (seqPdObjects{p}.sigma ~= 0)
					stdevValsTmp(t) = seqPdObjects{p}.sigma;
					distancesStdevTmp(t) = argDistances(p);
					t = t + 1;
				end;
			end
			

			if (length(meanValsTmp) == 0)
			    matMeanLinearModels{i, j} = zero_linear_model;
			else
				meanValsTmpUpdated = [];
				distancesMeanTmpUpdated = [];
				%meanValsTmp = rmoutliers(meanValsTmp);
				%meanValsTmpUpdated = rmoutliers(meanValsTmp, "OutlierLocations", detect);
				%distancesMeanTmpUpdated = rmoutliers(distancesMeanTmp, "OutlierLocations", detect);
				%meanValsTmp = abs(meanValsTmp);
				detect = isoutlier(abs(meanValsTmp));
				idxGeneral = 1;
				for idxForOutlierDetection = 1 : length(meanValsTmp)
					if (detect(idxForOutlierDetection) ~= 1)
						meanValsTmpUpdated(idxGeneral) = meanValsTmp(idxForOutlierDetection);
						distancesMeanTmpUpdated(idxGeneral) = distancesMeanTmp(idxForOutlierDetection);
						idxGeneral = idxGeneral + 1;
					end
				end
			
				%mdlMeanLM = fitlm (distancesMeanTmp, meanValsTmp);
				mdlMeanLM = fitlm (distancesMeanTmpUpdated, meanValsTmpUpdated, 'quadratic');
				matMeanLinearModels{i, j} = mdlMeanLM;
			end;
			

			if (length(stdevValsTmp) == 0)
				matStdevLinearModels{i, j} = zero_linear_model;
			else
				stdevValsTmpUpdated = [];
				distancesStdevTmpUpdated = [];
				detect = isoutlier(stdevValsTmp);
				idxGeneral = 1;
				for idxForOutlierDetection = 1 : length(stdevValsTmp)
					if (detect(idxForOutlierDetection) ~= 1)
						stdevValsTmpUpdated(idxGeneral) = stdevValsTmp(idxForOutlierDetection);
						distancesStdevTmpUpdated(idxGeneral) = distancesStdevTmp(idxForOutlierDetection);
						idxGeneral = idxGeneral + 1;
					end
				end

				%mdlStdDevLM = fitlm (distancesStdevTmp, stdevValsTmp);
				mdlStdDevLM = fitlm (distancesStdevTmpUpdated, stdevValsTmpUpdated, 'quadratic');
				matStdevLinearModels{i, j} = mdlStdDevLM;
			end;
			
			%{
			if (length(meanValsTmp) == 0)
			    matMeanLinearModels{i, j} = zero_linear_model;
			else
				%mdlMeanLM = fitlm (distancesMeanTmp, meanValsTmp);
				mdlMeanLM = fitlm (distancesMeanTmp, meanValsTmp, 'quadratic');
				matMeanLinearModels{i, j} = mdlMeanLM;
				%matEvalPixels(i, j) = matEvalPixels(i, j) + 1;
			end;
			
			if (length(stdevValsTmp) == 0)
				matStdevLinearModels{i, j} = zero_linear_model;
			else
				%mdlStdDevLM = fitlm (distancesStdevTmp, stdevValsTmp);
				mdlStdDevLM = fitlm (distancesStdevTmp, stdevValsTmp, 'quadratic');
				matStdevLinearModels{i, j} = mdlStdDevLM;
			end;
			%}

			% {
			% logging is done here
			if (mod(i, 10) == 0 && mod(j, 10) == 0 )
				
				fprintf ("Iterating: %d, %d\nMean Vals:", i, j);
				disp(meanVals);
				disp(matMeanLinearModels{i, j});
				
				fprintf (argFileID, "Iterating: %d, %d\nMean Vals:\t", i, j);
				fprintf (argFileID, "%g ", meanVals);
				fprintf (argFileID, "\nMean Values Updated: ");
				fprintf (argFileID, "%g ", meanValsTmpUpdated);
				
				strPdLm = evalc('disp(matMeanLinearModels{i, j})');
				fprintf (argFileID, "\nLinear Model: %s\n", strPdLm);
			end;
			
			if (i == roi_y_min + int32( (roi_y_max - roi_y_min) / 2) ...
				&& j == roi_x_min + int32((roi_x_max - roi_x_min) / 2))
				figure;
				plot(mdlMeanLM);
				title(sprintf("Linear model of Mean Values"));
				xlabel('Distance');
				ylabel('Mean');
				
				%%figure;
				%%plotregression(distancesStdevTmp, stdevValsTmp, 'Regression');
				%figure;
				%plot(mdlStdDevLM);
				%title('Linear model of Std Dev Values');
				%xlabel('Distance');
				%ylabel('Std Dev');
			end			
			% }
		end
	end

	toc;
	fprintf("Linear models are evaluated \n");

	fprintf("\nEND: fun_find_depth_camera_params\n");
	return;
end
