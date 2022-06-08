function [ cameraParams ] = fun_detect_camera_params()

    fprintf("\nBEGIN: fun_detect_camera_params\n");

    images = imageDatastore({'im1_upd.png', 'im2_upd.png', 'im3_upd.png', 'im4_upd.png'});
    
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
    
    imshow(I);
    figure;
    title('Original');
    imshow(J1);
    title('Corrected');
    %figure; imshowpair(I, J1, image);
    %title('Original vs Corrected');

    fprintf("\nEND: fun_detect_camera_params\n");
end
