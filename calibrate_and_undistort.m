images = imageDatastore({'image1.gif', 'image2.gif', 'image3.gif', 'image4.gif', 'image5.gif'});

%detect calibration pattern
[imagePoints, boardSize] = detectCheckerboardPoints(images.Files);

% Generate world coordinates of the corners of the squares. The square size is in millimeters.
squareSize = 30;

worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
I = readimage(images,1); 
imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints, 'ImageSize',imageSize);

%Remove lens distortion and display results

I = images.readimage(1);
J1 = undistortImage(I,cameraParams);

figure; imshowpair(I, J1, image);
title('Original vs Corrected');
