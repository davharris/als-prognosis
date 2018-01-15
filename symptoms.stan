data {
  int<lower=1> N; // Rows of data
  int<lower=1> N_subjects; 
  int<lower=2> K; // Number of possible responses, including zero (i.e. 5)
  int<lower=1,upper=K> severity[N]; // 5 minus FRS score: high values are more severe!
  int<lower=1> subject_index[N];
  vector[N] t;
}

parameters {
  // Observation error for onset date
  vector[N_subjects] alpha_raw;
  real<lower=0> sigma_alpha;
  
  // Log-progression rates
  vector[N_subjects] logbeta_raw;
  real<lower=0> sigma_logbeta;
  real mu_logbeta;
  
  // Cutpoints
  ordered[K-1] c;
}
transformed parameters {
  vector[N_subjects] alpha = (alpha_raw - mean(alpha_raw)) * sigma_alpha;
  vector[N_subjects] beta = exp(mu_logbeta + logbeta_raw * sigma_logbeta);
  vector[N] progression = beta[subject_index] .* (alpha[subject_index] + t);
}

model {
  // Priors
  sigma_alpha ~ normal(0, 1000); // SD of intercepts, in days
  sigma_logbeta ~ normal(0, 1); // SD of slopes, in 1/days
  
  mu_logbeta ~ normal(-4, 2);
  // Mean intercept is zero to maintain identifiability with cutpoints
  
  // What are c's units? 1/beta, maybe?
  c ~ normal(mean(c), 20);
  
  
  // "Raw"" distributions are standard Gaussian
  alpha_raw ~ normal(0, 1);
  logbeta_raw ~ normal(0, 1);
  
  // Conditional Likelihood
  for (i in 1:N){
    severity[i] ~ ordered_logistic(progression[i],  c);
  }
}
