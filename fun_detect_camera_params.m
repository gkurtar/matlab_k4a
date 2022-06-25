% ************************************************************************************
% 
% fun_detect_camera_params
% RGB and IR camera Params are estimated by this method.
% It uses builtin matlab functions such as estimateCameraParameters and
% returns the camera Parameters object.
% 
% INPUT:
%   argFiles		-> an array of strings where each element represents an image file path that is going to be used for calibration
%   argSquareSize	-> size of the checkerboard pattern squares in milimeters
%
% OUTPUT: 
%   cameraParams	-> estimated Camera Params
%
% **********************************************************

function [ cameraParams ] = fun_detect_camera_params(argFiles, argSquareSize)

	fprintf("\nBEGIN: fun_detect_camera_params\n");
	
	if (~isnumeric(argSquareSize) || mod(argRowCount, 1) ~= 0 || sign(argSquareSize) <= 0)
		error('SquareSize argument (%d) must be numeric and positive \n', argSquareSize);
	end
	
	%fs = matlab.io.datastore.FileSet(argFiles);%imgds = imageDatastore(fs);
	%imgds = imageDatastore({'im1_upd.png', 'im2_upd.png', 'im3_upd.png', 'im4_upd.png'});
	imgds = imageDatastore(argFiles);

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

	%{
	figure;
	imshow(I);
	title('Original');
	hold on;
	figure;
	imshow(J1);
	title('Corrected');
	%}
	disp(cameraParams);

	fprintf("\nEND: fun_detect_camera_params\n");
end
