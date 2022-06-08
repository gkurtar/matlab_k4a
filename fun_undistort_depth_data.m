function [ correctedImage ] = fun_undistort_depth_data(cameraParams, rows, cols)

	fprintf("\nBEGIN: fun_undistort_depth_data");

	%depthFile = fullfile('d:\', 'work', 'sample_depth_data.txt'); %sprintf('rgb%d.png', i));
	depthFile = fullfile('sample_depth_data.txt'); %sprintf('rgb%d.png', i));
	depthData = importdata(depthFile);
	[sz_rows, sz_cols] = size(depthData);
	fprintf("%s file is imported, sizes are %d %d \n", depthFile, sz_rows, sz_cols);

    colIndex = 3;
    dimg_mat = zeros(rows, cols);
    for i=1:rows
        for j=1:cols
            rowIndex = (i - 1) * cols + j;
            %dimg_mat(i, j) = 0;
            if (j < 20)
                fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, depthData(rowIndex, colIndex));
            end
            dimg_mat(i, j) = depthData(rowIndex, colIndex);
        end
    end

    figure;
    title('Original');
    result_img = imshow(dimg_mat, []);
    figure;

    size(result_img.CData)
    
    fprintf("\nresult_img %s %d", ...
        result_img.Type, result_img.CData(12, 34));

    J1 = undistortImage(result_img.CData, cameraParams);
    UD_DEPTH_IMAGE = imshow(J1);
    title('Corrected');

    fprintf("\nresult_img %s %d", ...
        UD_DEPTH_IMAGE.Type, UD_DEPTH_IMAGE.CData(12, 34));

    fileID = fopen('ud_depth.txt', 'w');
    for i=1:rows
        for j=1:cols
            %fprintf(fileID, "%d %d %d\n", i, j, UD_DEPTH_IMAGE.CData(i, j));
            fprintf(fileID, "%d %d %d\n", i, j, cast(UD_DEPTH_IMAGE.CData(i, j), "uint16"));
        end
    end
    %imshow(dimg_mat, []);

	fclose(fileID);
	fprintf("\ngenerated undistorted depth data");

	fprintf("\nEND: fun_undistort_depth_data");
	return;
end
