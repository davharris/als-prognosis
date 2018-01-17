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
  int Y_Swallowing[N];  // response variable 
  int<lower=2> ncat_Swallowing;  // number of categories 
  int<lower=1> K_Swallowing;  // number of population-level effects 
  matrix[N, K_Swallowing] X_Swallowing;  // population-level design matrix 
  real<lower=0> disc_Swallowing;  // discrimination parameters 
  int Y_Respiratory[N];  // response variable 
  int<lower=2> ncat_Respiratory;  // number of categories 
  int<lower=1> K_Respiratory;  // number of population-level effects 
  matrix[N, K_Respiratory] X_Respiratory;  // population-level design matrix 
  real<lower=0> disc_Respiratory;  // discrimination parameters 
  int Y_Walking[N];  // response variable 
  int<lower=2> ncat_Walking;  // number of categories 
  int<lower=1> K_Walking;  // number of population-level effects 
  matrix[N, K_Walking] X_Walking;  // population-level design matrix 
  real<lower=0> disc_Walking;  // discrimination parameters 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_Swallowing_1; 
  vector[N] Z_1_Swallowing_2; 
  vector[N] Z_1_Respiratory_3; 
  vector[N] Z_1_Respiratory_4; 
  vector[N] Z_1_Walking_5; 
  vector[N] Z_1_Walking_6; 
  int<lower=1> NC_1; 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  int Kc_Swallowing = K_Swallowing - 1; 
  matrix[N, K_Swallowing - 1] Xc_Swallowing;  // centered version of X_Swallowing 
  vector[K_Swallowing - 1] means_X_Swallowing;  // column means of X_Swallowing before centering 
  int Kc_Respiratory = K_Respiratory - 1; 
  matrix[N, K_Respiratory - 1] Xc_Respiratory;  // centered version of X_Respiratory 
  vector[K_Respiratory - 1] means_X_Respiratory;  // column means of X_Respiratory before centering 
  int Kc_Walking = K_Walking - 1; 
  matrix[N, K_Walking - 1] Xc_Walking;  // centered version of X_Walking 
  vector[K_Walking - 1] means_X_Walking;  // column means of X_Walking before centering 
  for (i in 2:K_Swallowing) { 
    means_X_Swallowing[i - 1] = mean(X_Swallowing[, i]); 
    Xc_Swallowing[, i - 1] = X_Swallowing[, i] - means_X_Swallowing[i - 1]; 
  } 
  for (i in 2:K_Respiratory) { 
    means_X_Respiratory[i - 1] = mean(X_Respiratory[, i]); 
    Xc_Respiratory[, i - 1] = X_Respiratory[, i] - means_X_Respiratory[i - 1]; 
  } 
  for (i in 2:K_Walking) { 
    means_X_Walking[i - 1] = mean(X_Walking[, i]); 
    Xc_Walking[, i - 1] = X_Walking[, i] - means_X_Walking[i - 1]; 
  } 
} 
parameters { 
  vector[Kc_Swallowing] b_Swallowing;  // population-level effects 
  ordered[ncat_Swallowing-1] temp_Swallowing_Intercept;  // temporary thresholds 
  vector[Kc_Respiratory] b_Respiratory;  // population-level effects 
  ordered[ncat_Respiratory-1] temp_Respiratory_Intercept;  // temporary thresholds 
  vector[Kc_Walking] b_Walking;  // population-level effects 
  ordered[ncat_Walking-1] temp_Walking_Intercept;  // temporary thresholds 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  matrix[M_1, N_1] z_1;  // unscaled group-level effects 
  // cholesky factor of correlation matrix 
  cholesky_factor_corr[M_1] L_1; 
} 
transformed parameters { 
  // group-level effects 
  matrix[N_1, M_1] r_1 = (diag_pre_multiply(sd_1, L_1) * z_1)'; 
  vector[N_1] r_1_Swallowing_1 = r_1[, 1]; 
  vector[N_1] r_1_Swallowing_2 = r_1[, 2]; 
  vector[N_1] r_1_Respiratory_3 = r_1[, 3]; 
  vector[N_1] r_1_Respiratory_4 = r_1[, 4]; 
  vector[N_1] r_1_Walking_5 = r_1[, 5]; 
  vector[N_1] r_1_Walking_6 = r_1[, 6]; 
} 
model { 
  vector[N] mu_Swallowing = Xc_Swallowing * b_Swallowing; 
  vector[N] mu_Respiratory = Xc_Respiratory * b_Respiratory; 
  vector[N] mu_Walking = Xc_Walking * b_Walking; 
  for (n in 1:N) { 
    mu_Swallowing[n] = mu_Swallowing[n] + (r_1_Swallowing_1[J_1[n]]) * Z_1_Swallowing_1[n] + (r_1_Swallowing_2[J_1[n]]) * Z_1_Swallowing_2[n]; 
    mu_Respiratory[n] = mu_Respiratory[n] + (r_1_Respiratory_3[J_1[n]]) * Z_1_Respiratory_3[n] + (r_1_Respiratory_4[J_1[n]]) * Z_1_Respiratory_4[n]; 
    mu_Walking[n] = mu_Walking[n] + (r_1_Walking_5[J_1[n]]) * Z_1_Walking_5[n] + (r_1_Walking_6[J_1[n]]) * Z_1_Walking_6[n]; 
  } 
  // priors including all constants 
  target += student_t_lpdf(temp_Swallowing_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Respiratory_Intercept | 3, 0, 10); 
  target += student_t_lpdf(temp_Walking_Intercept | 3, 0, 10); 
  target += student_t_lpdf(sd_1 | 3, 0, 10)
    - 6 * student_t_lccdf(0 | 3, 0, 10); 
  target += lkj_corr_cholesky_lpdf(L_1 | 1); 
  target += normal_lpdf(to_vector(z_1) | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Swallowing[n] | mu_Swallowing[n], temp_Swallowing_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Respiratory[n] | mu_Respiratory[n], temp_Respiratory_Intercept); 
    } 
    for (n in 1:N) { 
      target += ordered_logistic_lpmf(Y_Walking[n] | mu_Walking[n], temp_Walking_Intercept); 
    } 
  } 
} 
generated quantities { 
  // compute actual thresholds 
  vector[ncat_Swallowing - 1] b_Swallowing_Intercept = temp_Swallowing_Intercept + dot_product(means_X_Swallowing, b_Swallowing); 
  // compute actual thresholds 
  vector[ncat_Respiratory - 1] b_Respiratory_Intercept = temp_Respiratory_Intercept + dot_product(means_X_Respiratory, b_Respiratory); 
  // compute actual thresholds 
  vector[ncat_Walking - 1] b_Walking_Intercept = temp_Walking_Intercept + dot_product(means_X_Walking, b_Walking); 
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
} 