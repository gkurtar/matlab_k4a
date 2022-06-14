% ************************************************************************************
% 
% fun_detect_camera_params function
% camera Params are estimated by this method
%
% INPUT:
%
%   argFiles		-> an array of strings where each element represents an image file that is going to be used for calibration
%   argSquareSize	-> size of the checkerboard pattern squares in milimeters
%
% OUTPUT: 
%   cameraParams	-> estimated Camera Params
%
% **********************************************************

function [ cameraParams ] = fun_detect_camera_params(argFiles, argSquareSize)

	fprintf("\nBEGIN: fun_detect_camera_params\n");
	
	%arguments
	%	argFiles string
	%    argSquareSize  double {mustBeNumeric, mustBeReal, mustBePositive}
	%end
	
	fprintf("\nBEGIN: fun_detect_camera_params 2\n");
	
	%cameraParams = "";
	
	%if (isnan(str2double(argSquareSize)))
	%	fprintf('SquareSize argument (%d) must be an integer\n', argSquareSize);
	%	return;
	%end
	
	if (~isnumeric(argSquareSize) || ~(sign(argSquareSize) > 0))
		error('SquareSize argument (%d) must be numeric and positive \n', argSquareSize);
	end
	%squareSize = str2num(argSquareSize);

	%fs = matlab.io.datastore.FileSet(argFiles);
	%imgds = imageDatastore(fs);
	imgds = imageDatastore(argFiles);
	%imgds = imageDatastore({'im1_upd.png', 'im2_upd.png', 'im3_upd.png', 'im4_upd.png'});

	%detect calibration pattern
	[imagePoints, boardSize] = detectCheckerboardPoints(imgds.Files);

	% Generate world coordinates of the corners of the squares. The square size is in millimeters.
	worldPoints = generateCheckerboardPoints(boardSize, argSquareSize);

	% Calibrate the camera.
	I = readimage(imgds, 1); %Read one of them 
	imageSize = [size(I, 1), size(I, 2)];
	cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize',imageSize);

	%Remove lens distortion and display results
	I = imgds.readimage(1);
	J1 = undistortImage(I, cameraParams);

	imshow(I);
	figure;
	title('Original');
	imshow(J1);
	title('Corrected');
	%figure; imshowpair(I, J1, image);
	%title('Original vs Corrected');
	disp(cameraParams);

	fprintf("\nEND: fun_detect_camera_params\n");
end
