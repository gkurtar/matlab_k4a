
iş akışı

1. start processing script çağrılır.
	a) input dosyalar kontrol edilir. hata varsa sonlanır.
	b) fun_k4a_calibration çağrılır.
	
2. fun_k4a_calibration
	a) RGB ve IR goruntulerden kamera parametreleri fun_detect_camera_params metodu kullanılarak tespit edilir.
		Bulunan değerler bir dosyaya yazılır.
	b) IR kamera parametreleri kullanılarak fun_undistort_depth_data metodu ile depth image "undistort" edilir.
	c) uzaklığa bağlı olarak yapılan ölçümler kullanılarak depth camera
		parametreleri bulunur. bu parametreler, her bir pixel için bir
		linear model içeren bir look up table olarak elde edilir. Bu linear
		model ler probability distribution object lerin mesafeye bağlı olarak
		değişimini ifade etmektedir.
	d) Bir önceki adımda bulunan parametreler kullanılarak depth image'ler düzeltilir.
		Düzeltilen image'lar ekranda gösterilir.
	e) Bu aşamada her bir depth image'a bağlı olarak bir ground truth image de elde edilir.
	   Düzeltilen image'ler ile Ground Truth image'ler karsılastırılarak error stats bulunur ve bir dosyaya yazılır.
	   
	   
3. fun_detect_camera_params
	a) matlab'ta tanımlı olan calibration işlemi bu metodla gerçekleştirilir.
		estimateCameraParams metodu ile bulunan cameraParams objesi return value olarak dönülür.
	
4. fun_undistort_depth_data
	a) depth image data matrisi, IR camera parametreleri kullanılarak undistort edilir.
	b) data matrisini image formatinda elde etmek için imshow kullanılır.
	
5. fun_find_depth_camera_params

	a) depth camera calibration işlemi için camera parametreleri bu metodla elde edilir.
	b) input depth image'ler analiz edilerek her bir distance için probability distribution object'ler elde edilir.
	c) her bir probability distribution objesi bir matlab struct yapısında olup, mean ve stddev alanlarından oluşmaktadır.
	d) her bir pixel için, farklı distance'larda elde edilen p.d. objelerindeki mean ve stddev değerleri için bir linear model fit edilir.
	e) sonuç olarak  mean ve stddev değerleri için pixel bazında linear model ler elde edilir.
	f) Bu linear model'ler kullanılarak depth image'lar için düzeltme işlemi yapılabilir.
		
6. fun_inspect_errors

	a) argüman olarak verilen (sensorden alınmış veya undistort edilmiş ve p.d. objeleri kullanılarak düzeltme yapılmış) depth image data,
		Ground truth data ile karşılaştırılır.
	b) her bir ölçüm için bulunan fark değerleri scatter fonksiyonu ile gösterilir.
	c) ayrıca residual değerler için mean, sdev, RMSE gibi değerler bulunur.
	
		
7. fun_read_point_cloud_data

	a) Input argumanı olarak verilen dosyayı importdata fonksiyonu ile okur.
	b) Yine arguman olarak belirtilen rowCount ve colCount boyutlarında bir 2d array ile okunan data return edilir.
	
