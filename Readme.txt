
iş akışı
-------------------------------------------------------------------------------------------------------------------		
1. start processing script çağrılır.
%	a) input dosyalar kontrol edilir. hata varsa sonlanır.
%	b) fun_k4a_calibration çağrılır.
%
-------------------------------------------------------------------------------------------------------------------			
2. fun_k4a_calibration
%
% a) RGB ve IR goruntulerden kamera parametreleri fun_detect_camera_params metodu kullanılarak tespit edilir.
%	 Bulunan değerler bir dosyaya yazılır.
% b) IR kamera parametreleri kullanılarak fun_undistort_depth_data metodu ile depth image "undistort" edilir.
% c) argSeqDistances ve argSeqOfPcFilePaths array'lerinin boyları aynı olmalıdır.
%	 uzaklığa bağlı olarak yapılan ölçümler kullanılarak depth camera
%	 parametreleri bulunur. bu parametreler, her bir pixel için bir
%	 linear model içeren bir look up table olarak elde edilir. Bu linear
%	 model ler probability distribution object lerin mesafeye bağlı olarak
%	 değişimini ifade etmektedir.
% d) Bir önceki adımda bulunan parametreler kullanılarak depth image'ler düzeltilir.
%	 Düzeltilen image'lar ekranda gösterilir.
% e) Bu aşamada her bir depth image'a bağlı olarak bir ground truth image de elde edilir.
%	 Düzeltilen image'ler ile Ground Truth image'ler karsılastırılarak error stats bulunur ve bir dosyaya yazılır.
%
% K4A Depth Camera Calibration and depth image correction error analysis is done by this method.
% RGB camera parameters are estimated first, After this step IR camera parameters
% are estimated. Depth camera data could be undistorted by using these IR camera paramters.
% Depth Camera measurements are also processed and analysed.
% Linear models of mean and std deviation for each pixel is evaluated as depth camera parameters.
% Depth images which are to be corrected would be processed after these steps.
% Using these input images ground truth data is determined.
% First step involves undistorting depth data via IR camera Parameters.
% In second step these depth images are corrected via depth camera parameters.
% After these steps corrected data are compared with ground truth data and residual values are further analysed
% and depth error stats are acquired.
%
% INPUT:
%   argRgbImages        -> an array of RGB image file paths of a planar checkerboard pattern 	
%   argRgbSquareSize    -> an integer which is the size of the square (centimeter) in the RGB checkerboard pattern
%   argIrImages         -> an array of IR image file paths of a planar checkerboard pattern
%   argIrSquareSize     -> an integer which is the size of the square (centimeter) in the IR checkerboard pattern
%   argSeqDistances     -> an array of distances in cm.
%   argSeqOfPcFilePathArray -> a cell array where each element is a string array and each string denotes the depth data file path
%                          of the corresponding indexed distances array i.e. { [da1.txt, da2.txt, da3.txt], [db1.txt, db2.txt, db3.txt] }
%   argSeqOfDepthDataToBeCorrected -> an array of Depth Image file paths to be corrected
%   argDepthDataSize	-> a 1x2 vector denoting the size ( row and col count) of the depth data image matrix
%
% OUTPUT:
%   resCorrectedImages	-> corrected images in measurements
%
-------------------------------------------------------------------------------------------------------------------			   
3. fun_detect_camera_params
%
% a) matlab'ta tanımlı olan calibration işlemi bu metodla gerçekleştirilir.
% estimateCameraParams metodu ile bulunan cameraParams objesi return value olarak dönülür.
%
% Photogrammetric calibration based on Zhang method is done and camera parameters are estimated by this function.
% RGB and IR camera Params are estimated by this method.
% It uses builtin matlab functions such as detectCheckerboardPoints and estimateCameraParameters
% and returns the camera Parameters object.
% 
% INPUT:
%   argFiles		-> an array of strings where each element represents an image file path that is going to be used for calibration
%   argSquareSize	-> size of the checkerboard pattern squares in milimeters
%
% OUTPUT: 
%   resCameraParams	-> estimated Camera Parameters object
%
-------------------------------------------------------------------------------------------------------------------			
4. fun_undistort_depth_data
%
% a) depth image data matrisi, IR camera parametreleri kullanılarak undistort edilir.
% b) data matrisini image formatinda elde etmek için imshow kullanılır.
%
% K4A depth images are undistorted via IR camera params by this method.
% Corrected image is returned as an m by n matrix where its sizes are same with the input array.
%
% INPUT:
%   argDepthData	-> a 2D array of size [argRowCount * argColCount] which represents Depth Point Cloud.
%   argRowCount		-> Row Count of the Depth Data
%   argColCount		-> Column Count of the Depth Data
%   argCameraParams -> IR(Depth) camera parameters
%
% OUTPUT: 
%   resCorrectedImage	-> a 2D array of size [argRowCount * argColCount] which represents corrected image (depth point cloud) 
%
-------------------------------------------------------------------------------------------------------------------		
5. fun_find_depth_camera_params
%
% a) depth camera calibration işlemi için camera parametreleri bu metodla elde edilir.
% b) input depth image'ler analiz edilerek her bir distance için probability distribution object'ler elde edilir.
% c) her bir probability distribution objesi bir matlab struct yapısında olup, mean ve stddev alanlarından oluşmaktadır.
% d) her bir pixel için, farklı distance'larda elde edilen p.d. objelerindeki mean ve stddev değerleri için bir linear model fit edilir.
% e) sonuç olarak  mean ve stddev değerleri için pixel bazında linear model ler elde edilir.
% f) Bu linear model'ler kullanılarak depth image'lar için düzeltme işlemi yapılabilir.
%
% Parameters of the proposed calibration method is evaluated by this method.
% A probability distribution object is evaluated for each pixel of each distance where each
% probability distance object consists of mean and stddev field.
% Based on the distance, linear model of mean and stddev values of the corresponding
% probability distribution object of a pixel is evalauted. A linear model matrix for
% mean values and a linear model matrix for stddev values are detected and returned.
%
% INPUT:
% argDistances					-> an array of distance values in cm
%	argSeqOfDepthDataFilePathArray	-> a cell array where each element is an array consisting of Depth data file paths
%	argDepthDataSize				-> a 1 x 2 array which represents row and col sizes of depth data;
%
% OUTPUT:
%	matMeanLinearModels				-> a 2D array (depth image sized) of linear model objects for mean values
%	matStdevLinearModels			-> a 2D array (depth image sized) of linear model objects for stddev values
%
-------------------------------------------------------------------------------------------------------------------		
6. fun_inspect_errors
%
% a) argüman olarak verilen (sensorden alınmış veya undistort edilmiş ve p.d. objeleri kullanılarak düzeltme yapılmış) depth image data,
%	Ground truth data ile karşılaştırılır.
% b) her bir ölçüm için bulunan fark değerleri scatter fonksiyonu ile gösterilir.
% c) ayrıca residual değerler için mean, sdev, RMSE gibi değerler bulunur.
%
% Compares measured depth values and corresponding ground truth values and 
% shows the figure for the errors based on distance by scatter function.
% Also finds statistics for the depth measurement errors such as rmse and stdev and prints them.
% 
% INPUT:
%   argSeqOfDepthImageMatrices			-> cell array where each element is a 2D array of measured depth values 
%   argSeqOfGroundTruthImageMatrices	-> cell array where each element is a 2D array of gr.truth values of the corresponding measurements 
%
% OUTPUT: __
%
-------------------------------------------------------------------------------------------------------------------		
7. fun_correct_measurements
%
% Bu metod her bir pixel için hesaplanmış mean linear modeller kullanarak input olarak verilen
% iki boyutlu depth image data'yı düzelterek, yeni bir depth data matrix sonucu verir.
%
% Given a 2D (w x h) array of depth measurements where w and h are width and height of the
% input image respectively and a 2D (w x h) array of  linear model objects where each model
% represents the mean value of the evaluated probability distribution at the corresponding
% pixel this method returns the corrected measurements.
%
% Input Arguments:
%   argDepthImage            -> Depth Image Data of size (argHeight x argWidth)
%   argWidth                 -> Depth Image Width
%   argHeight                -> Depth Image Height 
%   argMeanLinearModelMatrix -> 2D array of size (argHeight x argWidth) where each element
%								is a linear model object of the corresponding pixel
%
% Output Values:
%   resCorrectedImage        -> Corrected Depth Image Data of size (argHeight x argWidth).
%
-------------------------------------------------------------------------------------------------------------------		
8. fun_read_point_cloud_data
%
% a) Input argumanı olarak verilen dosyayı importdata fonksiyonu ile okur.
% b) Yine arguman olarak belirtilen rowCount ve colCount boyutlarında bir 2d array ile okunan data return edilir.
% 
% given a txt file path which represnts a 2d image this method calls importdata after various checks and reads
% this data as a matrix and returns it. Each line of the input file consists of triplets where 1st element is row number,
% second one is column number and third one is the corresponding value at that pixel position.
% The number of lines in this file should be eq to argRowCount * argColCount.
%
% INPUT:
%	argFilePath     -> Path of the point cloud file which contains triplets (row, col, depth) in each line
%	argRowCount		-> Number of the rows in the depth image
%	argColCount		-> Number of the columns in the depth image
%
% OUTPUT:
%	resDepthDataMatrix	-> a 2D array of size [argRowCount * argColCount] which represents Depth Point Cloud
%
-------------------------------------------------------------------------------------------------------------------		
9. fun_ui_get_files
%
% a) matlab ta bulunan uigetfile metodu cagrilir. 
% b) arguman olarak verilen diger parametreler ile dialog penceresi başlığı ve
%    minimum dosya sayısı gibi ayarlar tanımlanır.
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
