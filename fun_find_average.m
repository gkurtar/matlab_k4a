%*******************************************************************************************
%
%*******************************************************************************************
function [ resAverage ] = fun_find_average()

	fprintf("\nBEGIN: fun_get_gray_constant\n");
	
	%S = [1 1 128 128];  %the size of your ROI starts at point X1, Y1
    %depthData = fun_read_point_cloud_data('c:\tmp\gray.txt', 576, 640);
	
	imgWidth = 640;
	imgHeight = 576;

	depthDataFile = fun_ui_get_files('C:\work\article\data\GRAY_CONSTANT_IMAGES', "Select Depth Data File!", 0);
	
	depthData = fun_read_point_cloud_data(depthDataFile, imgHeight, imgWidth);

	%{
	figTemp = figure;
	hImg = imshow(depthData, []);
	hSP = imscrollpanel(figTemp, hImg);
	set(hSP,'Units', 'normalized', 'Position',[0 .1 1 .9]);
	hMagBox = immagbox(figTemp, hImg);
	pos = get(hMagBox, 'Position');
	set(hMagBox, 'Position', [0 0 pos(3) pos(4)]);
	imoverview(hImg);
	%}
	figure, imshow(depthData, []);
	impixelinfo;
	hold on;
	%h = imrect(gca, S);
	title('Depth Data as an Image');
	
	
	for k = 1 : 2
	
	p = drawrectangle('LineWidth', 2, 'Color', 'cyan');
	rectCoordinates = p.Position;
	rectCoordinates = cast(rectCoordinates, 'uint16');
	disp (rectCoordinates);
	
	
	roiTopLeftCornerX = rectCoordinates(1);
	roiTopLeftCornerY = rectCoordinates(2);
	roiWidth = rectCoordinates(3);
	roiHeight = rectCoordinates(4);
	
	roiSelected = zeros(rectCoordinates(3), rectCoordinates(4));
	
	sumDepth = 0;
	count = 0;
	for i = 1 : roiHeight
		for j = 1 : roiWidth
			roiSelected(i, j) = depthData(roiTopLeftCornerY + (i - 1), roiTopLeftCornerX + (j - 1));
			if (roiSelected(i, j) ~= 0)
				sumDepth = sumDepth + roiSelected(i, j);
				count = count + 1;
			end;
		end
	end
	
	%disp (roiSelected);
	
	fprintf ("\nSum is %d, count is %d, Avg:\n%f\n", sumDepth, count, sumDepth / count);
	%draw(p);
	
	end
	
	
	hold off;
	
	resAverage = sumDepth / count;
	
    fprintf("\nEND: fun_get_gray_constant\n");
	return;
end