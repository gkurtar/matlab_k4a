%*******************************************************************************************
%
%*******************************************************************************************
function [ resCorrespondingPc ] = fun_pcshow_url(argDepthDataFileURL, argTitle)
	fprintf("\nBEGIN: fun_pcshow_url\n");
	
	if exist(argDepthDataFileURL, 'file') ~= 2
		error(sprintf("input file %s does not exist\n", argDepthDataFileURL));
	end

	idata = importdata(fullfile(argDepthDataFileURL));
	idata = filloutliers(idata, 'nearest', 'mean');
	
    ptCloud = pointCloud(idata);
     
    figure;
	hold on;
    %pcshow(ptCloud, 'VerticalAxis', 'X');
	pcshow(ptCloud, 'VerticalAxis', 'X', 'VerticalAxisDir', 'Down' );
	xlabel('X(px)');
	ylabel('Y(px)');
	zlabel('Z(mm)');
	title(argTitle);
	hold off;
	
    fprintf("\nEND: fun_pcshow_url\n");
	return;
end