// generated with brms 2.0.2
functions { 
  /* cumulative-logit log-PDF for a single response 
   * Args: 
   *   y: response category 
   *   mu: linear predictor 
   *   thres: ordinal thresholds 
   *   disc: discrimination parameter 
   * Returns: 
   *   a scalar to be added to the log posterior 
   */ 
   real cumulative_logit_lpmf(int y, real mu, vector thres, real disc) { 
     int ncat = num_elements(thres) + 1; 
     vector[ncat] p; 
     p[1] = inv_logit(disc * (thres[1] - mu)); 
     for (k in 2:(ncat - 1)) { 
       p[k] = inv_logit(disc * (thres[k] - mu)) - 
              inv_logit(disc * (thres[k - 1] - mu)); 
     } 
     p[ncat] = 1 - inv_logit(disc * (thres[ncat - 1] - mu)); 
     return categorical_lpmf(y | p); 
   } 
  /* cumulative-logit log-PDF for a single response 
   * including category specific effects 
   * Args: 
   *   y: response category 
   *   mu: linear predictor 
   *   mucs: predictor for category specific effects 
   *   thres: ordinal thresholds 
   *   disc: discrimination parameter 
   * Returns: 
   *   a scalar to be added to the log posterior 
   */ 
   real cumulative_logit_cs_lpmf(int y, real mu, row_vector mucs, vector thres, real disc) { 
     int ncat = num_elements(thres) + 1; 
     vector[ncat] p; 
     p[1] = inv_logit(disc * (thres[1] - mucs[1] - mu)); 
     for (k in 2:(ncat - 1)) { 
       p[k] = inv_logit(disc * (thres[k] - mucs[k] - mu)) - 
              inv_logit(disc * (thres[k - 1] - mucs[k - 1] - mu)); 
     } 
     p[ncat] = 1 - inv_logit(disc * (thres[ncat - 1] - mucs[ncat - 1] - mu)); 
     return categorical_lpmf(y | p); 
   } 
} 
data { 
  int<lower=1> N;  // total number of observations 
  int Y_Speech[N];  // response variable 
  int<lower=2> ncat_Speech;  // number of categories 
  int<lower=1> K_Speech;  // number of population-level effects 
  matrix[N, K_Speech] X_Speech;  // population-level design matrix 
  real<lower=0> disc_Speech;  // discrimination parameters 
  int Y_Salivation[N];  // response variable 
  int<lower=2> ncat_Salivation;  // number of categories 
  int<lower=1> K_Salivation;  // number of population-level effects 
  matrix[N, K_Salivation] X_Salivation;  // population-level design matrix 
  real<lower=0> disc_Salivation;  // discrimination parameters 
  int Y_Swallowing[N];  // response variable 
  int<lower=2> ncat_Swallowing;  // number of categories 
  int<lower=1> K_Swallowing;  // number of population-level effects 
  matrix[N, K_Swallowing] X_Swallowing;  // population-level design matrix 
  real<lower=0> disc_Swallowing;  // discrimination parameters 
  int Y_Handwriting[N];  // response variable 
  int<lower=2> ncat_Handwriting;  // number of categories 
  int<lower=1> K_Handwriting;  // number of population-level effects 
  matrix[N, K_Handwriting] X_Handwriting;  // population-level design matrix 
  real<lower=0> disc_Handwriting;  // discrimination parameters 
  int Y_Cutting[N];  // response variable 
  int<lower=2> ncat_Cutting;  // number of categories 
  int<lower=1> K_Cutting;  // number of population-level effects 
  matrix[N, K_Cutting] X_Cutting;  // population-level design matrix 
  real<lower=0> disc_Cutting;  // discrimination parameters 
  int Y_Dressing[N];  // response variable 
  int<lower=2> ncat_Dressing;  // number of categories 
  int<lower=1> K_Dressing;  // number of population-level effects 
  matrix[N, K_Dressing] X_Dressing;  // population-level design matrix 
  real<lower=0> disc_Dressing;  // discrimination parameters 
  int Y_Turning[N];  // response variable 
  int<lower=2> ncat_Turning;  // number of categories 
  int<lower=1> K_Turning;  // number of population-level effects 
  matrix[N, K_Turning] X_Turning;  // population-level design matrix 
  real<lower=0> disc_Turning;  // discrimination parameters 
  int Y_Walking[N];  // response variable 
  int<lower=2> ncat_Walking;  // number of categories 
  int<lower=1> K_Walking;  // number of population-level effects 
  matrix[N, K_Walking] X_Walking;  // population-level design matrix 
  real<lower=0> disc_Walking;  // discrimination parameters 
  int Y_Climbing[N];  // response variable 
  int<lower=2> ncat_Climbing;  // number of categories 
  int<lower=1> K_Climbing;  // number of population-level effects 
  matrix[N, K_Climbing] X_Climbing;  // population-level design matrix 
  real<lower=0> disc_Climbing;  // discrimination parameters 
  int Y_Respiratory[N];  // response variable 
  int<lower=2> ncat_Respiratory;  // number of categories 
  int<lower=1> K_Respiratory;  // number of population-level effects 
  matrix[N, K_Respiratory] X_Respiratory;  // population-level design matrix 
  real<lower=0> disc_Respiratory;  // discrimination parameters 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_Speech_1; 
  vector[N] Z_1_Speech_2; 
  vector[N] Z_1_Salivation_3; 
  vector[N] Z_1_Salivation_4; 
  vector[N] Z_1_Swallowing_5; 
  vector[N] Z_1_Swallowing_6; 
  vector[N] Z_1_Handwriting_7; 
  vector[N] Z_1_Handwriting_8; 
  vector[N] Z_1_Cutting_9; 
  vector[N] Z_1_Cutting_10; 
  vector[N] Z_1_Dressing_11; 
  vector[N] Z_1_Dressing_12; 
  vector[N] Z_1_Turning_13; 
  vector[N] Z_1_Turning_14; 
  vector[N] Z_1_Walking_15; 
  vector[N] Z_1_Walking_16; 
  vector[N] Z_1_Climbing_17; 
  vector[N] Z_1_Climbing_18; 
  vector[N] Z_1_Respiratory_19; 
  vector[N] Z_1_Respiratory_20; 
  int<lower=1> NC_1; 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  int Kc_Speech = K_Speech - 1; 
  matrix[N, K_Speech - 1] Xc_Speech;  // centered version of X_Speech 
  vector[K_Speech - 1] means_X_Speech;  // column means of X_Speech before centering 
  int Kc_Salivation = K_Salivation - 1; 
  matrix[N, K_Salivation - 1] Xc_Salivation;  // centered version of X_Salivation 
  vector[K_Salivation - 1] means_X_Salivation;  // column means of X_Salivation before centering 
  int Kc_Swallowing = K_Swallowing - 1; 
  matrix[N, K_Swallowing - 1] Xc_Swallowing;  // centered version of X_Swallowing 
  vector[K_Swallowing - 1] means_X_Swallowing;  // column means of X_Swallowing before centering 
  int Kc_Handwriting = K_Handwriting - 1; 
  matrix[N, K_Handwriting - 1] Xc_Handwriting;  // centered version of X_Handwriting 
  vector[K_Handwriting - 1] means_X_Handwriting;  // column means of X_Handwriting before centering 
  int Kc_Cutting = K_Cutting - 1; 
  matrix[N, K_Cutting - 1] Xc_Cutting;  // centered version of X_Cutting 
  vector[K_Cutting - 1] means_X_Cutting;  // column means of X_Cutting before centering 
  int Kc_Dressing = K_Dressing - 1; 
  matrix[N, K_Dressing - 1] Xc_Dressing;  // centered version of X_Dressing 
  vector[K_Dressing - 1] means_X_Dressing;  // column means of X_Dressing before centering 
  int Kc_Turning = K_Turning - 1; 
  matrix[N, K_Turning - 1] Xc_Turning;  // centered version of X_Turning 
  vector[K_Turning - 1] means_X_Turning;  // column means of X_Turning before centering 
  int Kc_Walking = K_Walking - 1; 
  matrix[N, K_Walking - 1] Xc_Walking;  // centered version of X_Walking 
  vector[K_Walking - 1] means_X_Walking;  // column means of X_Walking before centering 
  int Kc_Climbing = K_Climbing - 1; 
  matrix[N, K_Climbing - 1] Xc_Climbing;  // centered version of X_Climbing 
  vector[K_Climbing - 1] means_X_Climbing;  // column means of X_Climbing before centering 
  int Kc_Respiratory = K_Respiratory - 1; 
  matrix[N, K_Respiratory - 1] Xc_Respiratory;  // centered version of X_Respiratory 
  vector[K_Respiratory - 1] means_X_Respiratory;  // column means of X_Respiratory before centering 
  for (i in 2:K_Speech) { 
    means_X_Speech[i - 1] = mean(X_Speech[, i]); 
    Xc_Speech[, i - 1] = X_Speech[, i] - means_X_Speech[i - 1]; 
  } 
  for (i in 2:K_Salivation) { 
    means_X_Salivation[i - 1] = mean(X_Salivation[, i]); 
    Xc_Salivation[, i - 1] = X_Salivation[, i] - means_X_Salivation[i - 1]; 
  } 
  for (i in 2:K_Swallowing) { 
    means_X_Swallowing[i - 1] = mean(X_Swallowing[, i]); 
    Xc_Swallowing[, i - 1] = X_Swallowing[, i] - means_X_Swallowing[i - 1]; 
  } 
  for (i in 2:K_Handwriting) { 
    means_X_Handwriting[i - 1] = mean(X_Handwriting[, i]); 
    Xc_Handwriting[, i - 1] = X_Handwriting[, i] - means_X_Handwriting[i - 1]; 
  } 
  for (i in 2:K_Cutting) { 
    means_X_Cutting[i - 1] = mean(X_Cutting[, i]); 
    Xc_Cutting[, i - 1] = X_Cutting[, i] - means_X_Cutting[i - 1]; 
  } 
  for (i in 2:K_Dressing) { 
    means_X_Dressing[i - 1] = mean(X_Dressing[, i]); 
    Xc_Dressing[, i - 1] = X_Dressing[, i] - means_X_Dressing[i - 1]; 
  } 
  for (i in 2:K_Turning) { 
    means_X_Turning[i - 1] = mean(X_Turning[, i]); 
    Xc_Turning[, i - 1] = X_Turning[, i] - means_X_Turning[i - 1]; 
  } 
  for (i in 2:K_Walking) { 
    means_X_Walking[i - 1] = mean(X_Walking[, i]); 
    Xc_Walking[, i - 1] = X_Walking[, i] - means_X_Walking[i - 1]; 
  } 
  for (i in 2:K_Climbing) { 
    means_X_Climbing[i - 1] = mean(X_Climbing[, i]); 
    Xc_Climbing[, i - 1] = X_Climbing[, i] - means_X_Climbing[i - 1]; 
  } 
  for (i in 2:K_Respiratory) { 
    means_X_Respiratory[i - 1] = mean(X_Respiratory[, i]); 
    Xc_Respiratory[, i - 1] = X_Respiratory[, i] - means_X_Respiratory[i - 1]; 
  } 
} 
parameters { 
  vector[Kc_Speech] b_Speech;  // population-level effects 
  ordered[ncat_Speech-1] temp_Speech_Intercept;  // temporary thresholds 
  vector[Kc_Salivation] b_Salivation;  // population-level effects 
  ordered[ncat_Salivation-1] temp_Salivation_Intercept;  // temporary thresholds 
  vector[Kc_Swallowing] b_Swallowing;  // population-level effects 
  ordered[ncat_Swallowing-1] temp_Swallowing_Intercept;  // temporary thresholds 
  vector[Kc_Handwriting] b_Handwriting;  // population-level effects 
  ordered[ncat_Handwriting-1] temp_Handwriting_Intercept;  // temporary thresholds 
  vector[Kc_Cutting] b_Cutting;  // population-level effects 
  ordered[ncat_Cutting-1] temp_Cutting_Intercept;  // temporary thresholds 
  vector[Kc_Dressing] b_Dressing;  // population-level effects 
  ordered[ncat_Dressing-1] temp_Dressing_Intercept;  // temporary thresholds 
  vector[Kc_Turning] b_Turning;  // population-level effects 
  ordered[ncat_Turning-1] temp_Turning_Intercept;  // temporary thresholds 
  vector[Kc_Walking] b_Walking;  // population-level effects 
  ordered[ncat_Walking-1] temp_Walking_Intercept;  // temporary thresholds 
  vector[Kc_Climbing] b_Climbing;  // population-level effects 
  ordered[ncat_Climbing-1] temp_Climbing_Intercept;  // temporary thresholds 
  vector[Kc_Respiratory] b_Respiratory;  // population-level effects 
  ordered[ncat_Respiratory-1] temp_Respiratory_Intercept;  // temporary thresholds 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  matrix[M_1, N_1] z_1;  // unscaled group-level effects 
  // cholesky factor of correlation matrix 
  cholesky_factor_corr[M_1] L_1; 
} 
transformed parameters { 
  // group-level effects 
  matrix[N_1, M_1] r_1 = (diag_pre_multiply(sd_1, L_1) * z_1)'; 
  vector[N_1] r_1_Speech_1 = r_1[, 1]; 
  vector[N_1] r_1_Speech_2 = r_1[, 2]; 
  vector[N_1] r_1_Salivation_3 = r_1[, 3]; 
  vector[N_1] r_1_Salivation_4 = r_1[, 4]; 
  vector[N_1] r_1_Swallowing_5 = r_1[, 5]; 
  vector[N_1] r_1_Swallowing_6 = r_1[, 6]; 
  vector[N_1] r_1_Handwriting_7 = r_1[, 7]; 
  vector[N_1] r_1_Handwriting_8 = r_1[, 8]; 
  vector[N_1] r_1_Cutting_9 = r_1[, 9]; 
  vector[N_1] r_1_Cutting_10 = r_1[, 10]; 
  vector[N_1] r_1_Dressing_11 = r_1[, 11]; 
  vector[N_1] r_1_Dressing_12 = r_1[, 12]; 
  vector[N_1] r_1_Turning_13 = r_1[, 13]; 
  vector[N_1] r_1_Turning_14 = r_1[, 14]; 
  vector[N_1] r_1_Walking_15 = r_1[, 15]; 
  vector[N_1] r_1_Walking_16 = r_1[, 16]; 
  vector[N_1] r_1_Climbing_17 = r_1[, 17]; 
  vector[N_1] r_1_Climbing_18 = r_1[, 18]; 
  vector[N_1] r_1_Respiratory_19 = r_1[, 19]; 
  vector[N_1] r_1_Respiratory_20 = r_1[, 20]; 
} 
model { 
  vector[N] mu_Speech = Xc_Speech * b_Speech; 
  vector[N] mu_Salivation = Xc_Salivation * b_Salivation; 
  vector[N] mu_Swallowing = Xc_Swallowing * b_Swallowing; 
  vector[N] mu_Handwriting = Xc_Handwriting * b_Handwriting; 
  vector[N] mu_Cutting = Xc_Cutting * b_Cutting; 
  vector[N] mu_Dressing = Xc_Dressing * b_Dressing; 
  vector[N] mu_Turning = Xc_Turning * b_Turning; 
  vector[N] mu_Walking = Xc_Walking * b_Walking; 
  vector[N] mu_Climbing = Xc_Climbing * b_Climbing; 
  vector[N] mu_Respiratory = Xc_Respiratory * b_Respiratory; 
  for (n in 1:N) { 
    mu_Speech[n] = mu_Speech[n] + (r_1_Speech_1[J_1[n]]) * Z_1_Speech_1[n] + (r_1_Speech_2[J_1[n]]) * Z_1_Speech_2[n]; 
    mu_Salivation[n] = mu_Salivation[n] + (r_1_Salivation_3[J_1[n]]) * Z_1_Salivation_3[n] + (r_1_Salivation_4[J_1[n]]) * Z_1_Salivation_4[n]; 
    mu_Swallowing[n] = mu_Swallowing[n] + (r_1_Swallowing_5[J_1[n]]) * Z_1_Swallowing_5[n] + (r_1_Swallowing_6[J_1[n]]) * Z_1_Swallowing_6[n]; 
    mu_Handwriting[n] = mu_Handwriting[n] + (r_1_Handwriting_7[J_1[n]]) * Z_1_Handwriting_7[n] + (r_1_Handwriting_8[J_1[n]]) * Z_1_Handwriting_8[n]; 
    mu_Cutting[n] = mu_Cutting[n] + (r_1_Cutting_9[J_1[n]]) * Z_1_Cutting_9[n] + (r_1_Cutting_10[J_1[n]]) * Z_1_Cutting_10[n]; 
    mu_Dressing[n] = mu_Dressing[n] + (r_1_Dressing_11[J_1[n]]) * Z_1_Dressing_11[n] + (r_1_Dressing_12[J_1[n]]) * Z_1_Dressing_12[n]; 
    mu_Turning[n] = mu_Turning[n] + (r_1_Turning_13[J_1[n]]) * Z_1_Turning_13[n] + (r_1_Turning_14[J_1[n]]) * Z_1_Turning_14[n]; 
    mu_Walking[n] = mu_Walking[n] + (r_1_Walking_15[J_1[n]]) * Z_1_Walking_15[n] + (r_1_Walking_16[J_1[n]]) * Z_1_Walking_16[n]; 
    mu_Climbing[n] = mu_Climbing[n] + (r_1_Climbing_17[J_1[n]]) * Z_1_Climbing_17[n] + (r_1_Climbing_18[J_1[n]]) * Z_1_Climbing_18[n]; 
    mu_Respiratory[n] = mu_Respiratory[n] + (r_1_Respiratory_19[J_1[n]]) * Z_1_Respiratory_19[n] + (r_1_Respiratory_20[J_1[n]]) * Z_1_Respiratory_20[n]; 
  } 
  // priors including all constants 
  target += student_t_lpdf(temp_Speech_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Salivation_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Swallowing_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Handwriting_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Cutting_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Dressing_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Turning_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Walking_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Climbing_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Respiratory_Intercept | 3, 0, 10); 
  target += student_t_lpdf(sd_1 | 3, 0, 10)
    - 20 * student_t_lccdf(0 | 3, 0, 10); 
  target += lkj_corr_cholesky_lpdf(L_1 | 1); 
  target += normal_lpdf(to_vector(z_1) | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Speech[n] | mu_Speech[n], temp_Speech_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Salivation[n] | mu_Salivation[n], temp_Salivation_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Swallowing[n] | mu_Swallowing[n], temp_Swallowing_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Handwriting[n] | mu_Handwriting[n], temp_Handwriting_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Cutting[n] | mu_Cutting[n], temp_Cutting_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Dressing[n] | mu_Dressing[n], temp_Dressing_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Turning[n] | mu_Turning[n], temp_Turning_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Walking[n] | mu_Walking[n], temp_Walking_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Climbing[n] | mu_Climbing[n], temp_Climbing_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Respiratory[n] | mu_Respiratory[n], temp_Respiratory_Intercept); 
    } 
  } 
} 
generated quantities { 
  // compute actual thresholds 
  vector[ncat_Speech - 1] b_Speech_Intercept = temp_Speech_Intercept + dot_product(means_X_Speech, b_Speech); 
  // compute actual thresholds 
  vector[ncat_Salivation - 1] b_Salivation_Intercept = temp_Salivation_Intercept + dot_product(means_X_Salivation, b_Salivation); 
  // compute actual thresholds 
  vector[ncat_Swallowing - 1] b_Swallowing_Intercept = temp_Swallowing_Intercept + dot_product(means_X_Swallowing, b_Swallowing); 
  // compute actual thresholds 
  vector[ncat_Handwriting - 1] b_Handwriting_Intercept = temp_Handwriting_Intercept + dot_product(means_X_Handwriting, b_Handwriting); 
  // compute actual thresholds 
  vector[ncat_Cutting - 1] b_Cutting_Intercept = temp_Cutting_Intercept + dot_product(means_X_Cutting, b_Cutting); 
  // compute actual thresholds 
  vector[ncat_Dressing - 1] b_Dressing_Intercept = temp_Dressing_Intercept + dot_product(means_X_Dressing, b_Dressing); 
  // compute actual thresholds 
  vector[ncat_Turning - 1] b_Turning_Intercept = temp_Turning_Intercept + dot_product(means_X_Turning, b_Turning); 
  // compute actual thresholds 
  vector[ncat_Walking - 1] b_Walking_Intercept = temp_Walking_Intercept + dot_product(means_X_Walking, b_Walking); 
  // compute actual thresholds 
  vector[ncat_Climbing - 1] b_Climbing_Intercept = temp_Climbing_Intercept + dot_product(means_X_Climbing, b_Climbing); 
  // compute actual thresholds 
  vector[ncat_Respiratory - 1] b_Respiratory_Intercept = temp_Respiratory_Intercept + dot_product(means_X_Respiratory, b_Respiratory); 
  corr_matrix[M_1] Cor_1 = multiply_lower_tri_self_transpose(L_1); 
  vector<lower=-1,upper=1>[NC_1] cor_1; 
  // take only relevant parts of correlation matrix 
  cor_1[1] = Cor_1[1,2]; 
  cor_1[2] = Cor_1[1,3]; 
  cor_1[3] = Cor_1[2,3]; 
  cor_1[4] = Cor_1[1,4]; 
  cor_1[5] = Cor_1[2,4]; 
  cor_1[6] = Cor_1[3,4]; 
  cor_1[7] = Cor_1[1,5]; 
  cor_1[8] = Cor_1[2,5]; 
  cor_1[9] = Cor_1[3,5]; 
  cor_1[10] = Cor_1[4,5]; 
  cor_1[11] = Cor_1[1,6]; 
  cor_1[12] = Cor_1[2,6]; 
  cor_1[13] = Cor_1[3,6]; 
  cor_1[14] = Cor_1[4,6]; 
  cor_1[15] = Cor_1[5,6]; 
  cor_1[16] = Cor_1[1,7]; 
  cor_1[17] = Cor_1[2,7]; 
  cor_1[18] = Cor_1[3,7]; 
  cor_1[19] = Cor_1[4,7]; 
  cor_1[20] = Cor_1[5,7]; 
  cor_1[21] = Cor_1[6,7]; 
  cor_1[22] = Cor_1[1,8]; 
  cor_1[23] = Cor_1[2,8]; 
  cor_1[24] = Cor_1[3,8]; 
  cor_1[25] = Cor_1[4,8]; 
  cor_1[26] = Cor_1[5,8]; 
  cor_1[27] = Cor_1[6,8]; 
  cor_1[28] = Cor_1[7,8]; 
  cor_1[29] = Cor_1[1,9]; 
  cor_1[30] = Cor_1[2,9]; 
  cor_1[31] = Cor_1[3,9]; 
  cor_1[32] = Cor_1[4,9]; 
  cor_1[33] = Cor_1[5,9]; 
  cor_1[34] = Cor_1[6,9]; 
  cor_1[35] = Cor_1[7,9]; 
  cor_1[36] = Cor_1[8,9]; 
  cor_1[37] = Cor_1[1,10]; 
  cor_1[38] = Cor_1[2,10]; 
  cor_1[39] = Cor_1[3,10]; 
  cor_1[40] = Cor_1[4,10]; 
  cor_1[41] = Cor_1[5,10]; 
  cor_1[42] = Cor_1[6,10]; 
  cor_1[43] = Cor_1[7,10]; 
  cor_1[44] = Cor_1[8,10]; 
  cor_1[45] = Cor_1[9,10]; 
  cor_1[46] = Cor_1[1,11]; 
  cor_1[47] = Cor_1[2,11]; 
  cor_1[48] = Cor_1[3,11]; 
  cor_1[49] = Cor_1[4,11]; 
  cor_1[50] = Cor_1[5,11]; 
  cor_1[51] = Cor_1[6,11]; 
  cor_1[52] = Cor_1[7,11]; 
  cor_1[53] = Cor_1[8,11]; 
  cor_1[54] = Cor_1[9,11]; 
  cor_1[55] = Cor_1[10,11]; 
  cor_1[56] = Cor_1[1,12]; 
  cor_1[57] = Cor_1[2,12]; 
  cor_1[58] = Cor_1[3,12]; 
  cor_1[59] = Cor_1[4,12]; 
  cor_1[60] = Cor_1[5,12]; 
  cor_1[61] = Cor_1[6,12]; 
  cor_1[62] = Cor_1[7,12]; 
  cor_1[63] = Cor_1[8,12]; 
  cor_1[64] = Cor_1[9,12]; 
  cor_1[65] = Cor_1[10,12]; 
  cor_1[66] = Cor_1[11,12]; 
  cor_1[67] = Cor_1[1,13]; 
  cor_1[68] = Cor_1[2,13]; 
  cor_1[69] = Cor_1[3,13]; 
  cor_1[70] = Cor_1[4,13]; 
  cor_1[71] = Cor_1[5,13]; 
  cor_1[72] = Cor_1[6,13]; 
  cor_1[73] = Cor_1[7,13]; 
  cor_1[74] = Cor_1[8,13]; 
  cor_1[75] = Cor_1[9,13]; 
  cor_1[76] = Cor_1[10,13]; 
  cor_1[77] = Cor_1[11,13]; 
  cor_1[78] = Cor_1[12,13]; 
  cor_1[79] = Cor_1[1,14]; 
  cor_1[80] = Cor_1[2,14]; 
  cor_1[81] = Cor_1[3,14]; 
  cor_1[82] = Cor_1[4,14]; 
  cor_1[83] = Cor_1[5,14]; 
  cor_1[84] = Cor_1[6,14]; 
  cor_1[85] = Cor_1[7,14]; 
  cor_1[86] = Cor_1[8,14]; 
  cor_1[87] = Cor_1[9,14]; 
  cor_1[88] = Cor_1[10,14]; 
  cor_1[89] = Cor_1[11,14]; 
  cor_1[90] = Cor_1[12,14]; 
  cor_1[91] = Cor_1[13,14]; 
  cor_1[92] = Cor_1[1,15]; 
  cor_1[93] = Cor_1[2,15]; 
  cor_1[94] = Cor_1[3,15]; 
  cor_1[95] = Cor_1[4,15]; 
  cor_1[96] = Cor_1[5,15]; 
  cor_1[97] = Cor_1[6,15]; 
  cor_1[98] = Cor_1[7,15]; 
  cor_1[99] = Cor_1[8,15]; 
  cor_1[100] = Cor_1[9,15]; 
  cor_1[101] = Cor_1[10,15]; 
  cor_1[102] = Cor_1[11,15]; 
  cor_1[103] = Cor_1[12,15]; 
  cor_1[104] = Cor_1[13,15]; 
  cor_1[105] = Cor_1[14,15]; 
  cor_1[106] = Cor_1[1,16]; 
  cor_1[107] = Cor_1[2,16]; 
  cor_1[108] = Cor_1[3,16]; 
  cor_1[109] = Cor_1[4,16]; 
  cor_1[110] = Cor_1[5,16]; 
  cor_1[111] = Cor_1[6,16]; 
  cor_1[112] = Cor_1[7,16]; 
  cor_1[113] = Cor_1[8,16]; 
  cor_1[114] = Cor_1[9,16]; 
  cor_1[115] = Cor_1[10,16]; 
  cor_1[116] = Cor_1[11,16]; 
  cor_1[117] = Cor_1[12,16]; 
  cor_1[118] = Cor_1[13,16]; 
  cor_1[119] = Cor_1[14,16]; 
  cor_1[120] = Cor_1[15,16]; 
  cor_1[121] = Cor_1[1,17]; 
  cor_1[122] = Cor_1[2,17]; 
  cor_1[123] = Cor_1[3,17]; 
  cor_1[124] = Cor_1[4,17]; 
  cor_1[125] = Cor_1[5,17]; 
  cor_1[126] = Cor_1[6,17]; 
  cor_1[127] = Cor_1[7,17]; 
  cor_1[128] = Cor_1[8,17]; 
  cor_1[129] = Cor_1[9,17]; 
  cor_1[130] = Cor_1[10,17]; 
  cor_1[131] = Cor_1[11,17]; 
  cor_1[132] = Cor_1[12,17]; 
  cor_1[133] = Cor_1[13,17]; 
  cor_1[134] = Cor_1[14,17]; 
  cor_1[135] = Cor_1[15,17]; 
  cor_1[136] = Cor_1[16,17]; 
  cor_1[137] = Cor_1[1,18]; 
  cor_1[138] = Cor_1[2,18]; 
  cor_1[139] = Cor_1[3,18]; 
  cor_1[140] = Cor_1[4,18]; 
  cor_1[141] = Cor_1[5,18]; 
  cor_1[142] = Cor_1[6,18]; 
  cor_1[143] = Cor_1[7,18]; 
  cor_1[144] = Cor_1[8,18]; 
  cor_1[145] = Cor_1[9,18]; 
  cor_1[146] = Cor_1[10,18]; 
  cor_1[147] = Cor_1[11,18]; 
  cor_1[148] = Cor_1[12,18]; 
  cor_1[149] = Cor_1[13,18]; 
  cor_1[150] = Cor_1[14,18]; 
  cor_1[151] = Cor_1[15,18]; 
  cor_1[152] = Cor_1[16,18]; 
  cor_1[153] = Cor_1[17,18]; 
  cor_1[154] = Cor_1[1,19]; 
  cor_1[155] = Cor_1[2,19]; 
  cor_1[156] = Cor_1[3,19]; 
  cor_1[157] = Cor_1[4,19]; 
  cor_1[158] = Cor_1[5,19]; 
  cor_1[159] = Cor_1[6,19]; 
  cor_1[160] = Cor_1[7,19]; 
  cor_1[161] = Cor_1[8,19]; 
  cor_1[162] = Cor_1[9,19]; 
  cor_1[163] = Cor_1[10,19]; 
  cor_1[164] = Cor_1[11,19]; 
  cor_1[165] = Cor_1[12,19]; 
  cor_1[166] = Cor_1[13,19]; 
  cor_1[167] = Cor_1[14,19]; 
  cor_1[168] = Cor_1[15,19]; 
  cor_1[169] = Cor_1[16,19]; 
  cor_1[170] = Cor_1[17,19]; 
  cor_1[171] = Cor_1[18,19]; 
  cor_1[172] = Cor_1[1,20]; 
  cor_1[173] = Cor_1[2,20]; 
  cor_1[174] = Cor_1[3,20]; 
  cor_1[175] = Cor_1[4,20]; 
  cor_1[176] = Cor_1[5,20]; 
  cor_1[177] = Cor_1[6,20]; 
  cor_1[178] = Cor_1[7,20]; 
  cor_1[179] = Cor_1[8,20]; 
  cor_1[180] = Cor_1[9,20]; 
  cor_1[181] = Cor_1[10,20]; 
  cor_1[182] = Cor_1[11,20]; 
  cor_1[183] = Cor_1[12,20]; 
  cor_1[184] = Cor_1[13,20]; 
  cor_1[185] = Cor_1[14,20]; 
  cor_1[186] = Cor_1[15,20]; 
  cor_1[187] = Cor_1[16,20]; 
  cor_1[188] = Cor_1[17,20]; 
  cor_1[189] = Cor_1[18,20]; 
  cor_1[190] = Cor_1[19,20]; 
} 