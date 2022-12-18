%*******************************************************************************************
%
%*******************************************************************************************
function [ resCorrespondingPc ] = fun_pcshow_mat(argDepthData, argHeight, argWidth, argTitle)

	fprintf("\nBEGIN: fun_matpcshow\n");
	
    resCorrespondingPc = zeros(argHeight * argWidth, 3);
	
	for i = 1:argHeight
		for j = 1:argWidth

			rowIndex = (i - 1) * argWidth + j;
			
			resCorrespondingPc(rowIndex, 1) = i;
			resCorrespondingPc(rowIndex, 2) = j;
			resCorrespondingPc(rowIndex, 3) = argDepthData(i, j);
		end
	end
	
    ptCloud = pointCloud(resCorrespondingPc);
     
    figure;
	hold on;
    pcshow(ptCloud, 'VerticalAxis', 'X');
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title(argTitle);
	hold off;
	
    fprintf("\nEND: fun_matpcshow\n");
	return;
end