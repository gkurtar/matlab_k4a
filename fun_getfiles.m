

function [seqFiles] = fun_getfiles(argStrTitle, argMinNumberOfFiles)

	fprintf("\nBEGIN: fun_getfiles\n");

	seqFiles = {};
	[sel_file, sel_path] = uigetfile("*.*", argStrTitle, 'MultiSelect', 'on');
	
	if (isequal(sel_file, 0) || isequal(sel_path, 0))
		error("Not any RGB Images are selected!")
	end;
	
	if (~iscell(sel_file))
		sel_file = {sel_file};
	end
	
	if (numel(sel_file) < argMinNumberOfFiles)
		error(sprintf("At least %d RGB calibration image files are needed!", argMinNumberOfFiles));
	end;
	
	%disp("numel files!");
	%disp(numel(sel_file));
	
	for i = 1 : numel(sel_file)
		filepath = fullfile(sel_path, sel_file(i));
		seqFiles = [seqFiles, string(filepath)];
	end
	
	%fprintf("\nSelected %d RGB Images from %s\n", numel(sel_file), sel_path);
	%disp(seq_rgb_images);
	
	fprintf("\nEND: fun_getfiles\n");
	return;
end
