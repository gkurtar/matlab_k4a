% ************************************************************************************
% 
% fun_detect_camera_params
%
% Photogrammetric calibration based on Zhang method is done and camera parameters are estimated by this function.
% RGB and IR camera Params are estimated by this method.
% It uses builtin matlab functions such as detectCheckerboardPoints and estimateCameraParameters
% and returns the camera Parameters object.
% 
% INPUT:
%   argFiles        -> an array of strings where each element represents an image file path that is going to be used for calibration
%   argSquareSize   -> size of the checkerboard pattern squares in milimeters
%   argFileID	    -> file handle
%
% OUTPUT: 
%   resCameraParams	-> estimated Camera Parameters object
%
% **********************************************************

function [ resCameraParams ] = fun_detect_camera_params(argFiles, argSquareSize, argFileID)

	fprintf("\nBEGIN: fun_detect_camera_params\n");
	
	if (~isnumeric(argSquareSize) || mod(argSquareSize, 1) ~= 0 || sign(argSquareSize) <= 0)
		error('SquareSize argument (%d) must be numeric and positive \n', argSquareSize);
	end
	
	imgds = imageDatastore(argFiles);

	%detect calibration pattern
	[imagePoints, boardSize] = detectCheckerboardPoints(imgds.Files);

	% Generate world coordinates of the corners of the squares. The square size is in millimeters.
	worldPoints = generateCheckerboardPoints(boardSize, argSquareSize);

	% Calibrate the camera.
	I = readimage(imgds, 1); %Read one of them 
	imageSize = [size(I, 1), size(I, 2)];
	resCameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize',imageSize);

	%Remove lens distortion and display results
	I = imgds.readimage(1);
	J1 = undistortImage(I, resCameraParams);

	%{
	figure;
	imshow(I);
	title('Original');
	hold on;
	figure;
	imshow(J1);
	title('Corrected');
	%}
	disp(resCameraParams);
	
	fprintf(argFileID, "\n\n==============================\n==============================");
	fprintf(argFileID, "\n\nCamera Intrinsics\nIntrinsicMatrix:\n");
	fprintf(argFileID, "%f ", resCameraParams.IntrinsicMatrix.');
	fprintf(argFileID, "\nFocalLength: ");
	fprintf(argFileID, "%f ", resCameraParams.FocalLength.');
	fprintf(argFileID, "\nPrincipalPoint: ");
	fprintf(argFileID, "%f ", resCameraParams.PrincipalPoint.');
	fprintf(argFileID, "\nSkew: %0.3f", resCameraParams.Skew);
	fprintf(argFileID, "\nRadialDistortion: ");
	fprintf(argFileID, "%0.4f ", resCameraParams.RadialDistortion.');
	fprintf(argFileID, "\nTangentialDistortion: ");
	fprintf(argFileID, "%0.4f ", resCameraParams.TangentialDistortion.');
	fprintf(argFileID, "\nImageSize: ");
	fprintf(argFileID, "%d ", resCameraParams.ImageSize.');
	fprintf(argFileID, "\n\nCamera Extrinsics ");
	fprintf(argFileID, "\nRotationMatrices: ");
	fprintf(argFileID, "%d ", size(resCameraParams.RotationMatrices).');
	fprintf(argFileID, "matrix\nTranslationVectors: ");
	fprintf(argFileID, "%d ", size(resCameraParams.TranslationVectors).');

	fprintf(argFileID, "matrix\n\nAccuracy of Estimation");
	fprintf(argFileID, "\nMeanReprojectionError: %0.3f", resCameraParams.MeanReprojectionError);
	fprintf(argFileID, "\nReprojectionErrors: ");
	fprintf(argFileID, "%d ", size(resCameraParams.ReprojectionErrors).');
	fprintf(argFileID, "matrix\nReprojectedPoints: ");
	fprintf(argFileID, "%d ", size(resCameraParams.ReprojectedPoints).');

	fprintf(argFileID, "matrix\n\nCalibration Settings");
	fprintf(argFileID, "\nNumPatterns: %d", resCameraParams.NumPatterns);
	fprintf(argFileID, "\nWorldUnits: %s", resCameraParams.WorldUnits);
	fprintf(argFileID, "\nWorldPoints: ");
	fprintf(argFileID, "%d ", size(resCameraParams.WorldPoints).');
	fprintf(argFileID, "matrix\nEstimateSkew: %d", resCameraParams.EstimateSkew);
	fprintf(argFileID, "\nNumRadialDistortionCoefficients: %d", resCameraParams.NumRadialDistortionCoefficients);
	fprintf(argFileID, "\nEstimateTangentialDistortion: %d\n", resCameraParams.EstimateTangentialDistortion);

	fprintf("\nEND: fun_detect_camera_params\n");
end
