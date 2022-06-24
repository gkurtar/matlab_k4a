% ***********************************************************
%   fun_find_error_stats
%   
%   detects error stats such as max of the errors, RMSE and standard deviation by comparing
%   the input arguments. First argument is the measured depth values vector whereas second
%   one is the ground truth values for the corresponding index of the first argument.
%
% % Input Arguments:
%    argMeasuredDepthValues     -> a vector of Measured Sensor Depth Data for a number of points
%    argRealDepthValues         -> a vector of Real Depth Data for corresponding points
%
% % Output Values:
%    MAX_ERROR -> max valued error of the diff of the arguments. 
%    RMSE      -> root mean square errors evaluated for the arguments
%    SDEV      -> standard deviation of errors evaluated for the arguments
%
% **********************************************************
function [MAX_ERROR, RMSE, SDEV] = fun_find_error_stats(argMeasuredDepthValues, argRealDepthValues)

   fprintf("\nBEGIN: fun_find_error_stats\n");
   
   if (~isvector(argMeasuredDepthValues) || ~isvector(argRealDepthValues))
      fprintf('input arguments should be vectors\n');
      return;
   end
   
   if (~isnumeric(argMeasuredDepthValues) || ~isnumeric(argRealDepthValues))
      fprintf('Depth Positions should be numeric\n');
      return;
   end

   if (~eq(length(argMeasuredDepthValues), length(argRealDepthValues)))
      fprintf("input vector sizes should be same\n");
      return;
   end
   
   if (length(argMeasuredDepthValues) < 3)
      fprintf("input vector size should not be less than 3\n");
      return;
   end
   
   diff_data = argMeasuredDepthValues - argRealDepthValues;
   
   %compute for real to fitted diff matrix
   minVal = min(diff_data);
   maxVal = max(diff_data);
   MAX_ERROR = max(abs(minVal), abs(maxVal));
   SQE = diff_data.^2;
   MSE = mean(SQE(:));
   SDEV = std(diff_data(:));
   RMSE = sqrt(MSE);
   fprintf ("\nDepth Residuals\n\t; max_error %f, mse %f, rmse %f, std_dev: %f", MAX_ERROR, MSE, RMSE, SDEV);
   
   fprintf("\nMeasured_depth_distances\n");
   fprintf(" %d ", argMeasuredDepthValues.' );
   fprintf("\nReal_depth_distances\n");
   fprintf(" %d ", argRealDepthValues.' );
   
   fprintf("\nEND: fun_find_error_stats\n");
   return;

end
