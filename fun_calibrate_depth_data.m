function [ correctedImage ] = fun_calibrate_depth_data(input_file_name, rows, cols)

	fprintf("\nBEGIN: fun_calibrate_depth_data");

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

    result_img = imshow(dimg_mat, []);
    figure;

    size(result_img.CData)
    

    fprintf("\nresult_img %s %s %d", ...
        size(result_img), result_img.Type, result_img.CData(12, 34));

    for i=1:rows
        for j=1:cols
 
            if (j > 120 && j < 240 && i < 320 && i > 180) 
               dimg_mat(i, j) = dimg_mat(i, j) * 1.3;
            end
            
        end
    end

    imshow(dimg_mat, []);

    fprintf("\nEND: fun_calibrate_depth_data");
	return;
end
