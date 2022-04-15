a= [ 32 32 34 35 31 33 36 32 33 34 31];

pd_a = fitdist(a.', 'Normal');

b= [ 44 45 43 41 40 46 45 43 44 41 40];

pd_b = fitdist(b.', 'Normal');

pds = [pd_a, pd_b];

distances=[32, 45];

fun_detect_prob_params_based_on_distance (distances, pds);

pred_res = predict(mdl_stddev, 40);
