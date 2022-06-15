% ***********************************************************
% detect_errors metod compares two datasets to determine errors
%
% % Input Arguments:
%    argMeasuredDepthValues     -> Measured Sensor Depth Data for a number of points
%    argRealDepthValues     -> Real Depth Data for corresponding points
%
% % Output Values:
%    RMSE -> root mean square error for the datasets as arguments
%    SDEV ->  standard deviation
%
% **********************************************************
function [RMSE, SDEV] = fun_detect_error_stats(argMeasuredDepthValues, argRealDepthValues)

   fprintf("\nBEGIN: fun_detect_error_stats\n");
   

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
   SQE = diff_data.^2;
   MSE = mean(SQE(:));
   SDEV = std(diff_data(:));
   fprintf ("\nDepth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);
   RMSE = sqrt(MSE);
   
   fprintf("\nMeasured_depth_distances\n");
   fprintf(" %d ", argMeasuredDepthValues.' );
   fprintf("\nReal_depth_distances\n");
   fprintf(" %d ", argRealDepthValues.' );
   
  
   fprintf("\nEND: fun_detect_error_stats\n");
   return;

end
