% ******************************************************************
% fun_getfiles
%
% By invoking this function the user can select multiple files via file selection dialog box of the operation system.
% First argument of the method is used as the title of the file selection dialog window whereas second one is used
% to define the minimum number of files to be selected by the user. If zero is provided as second argument than
% minimum number file check is discarded and the user is free to select any number of files provided that at least
% one file is selected. Upon success this method returns an array of strings where each one is the selected file path.
%
% INPUT:
%   argStrTitle		-> The title of the user file selection dialog 
%   argMinNumberOfFiles	-> Minimum number of files to select for multiple selection.
%
% OUTPUT:
%   seqFiles		-> an array where each element is the full file path of the selected file(s) 
%
% ******************************************************************
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
