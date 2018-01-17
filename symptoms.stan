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
  vector<lower=0>[N_subjects] beta;
  real<lower=0> beta_shape;
  real<lower=0> beta_rate;
  
  // Cutpoints
  ordered[K-1] c;
}
transformed parameters {
  vector[N_subjects] alpha = (alpha_raw - mean(alpha_raw)) * sigma_alpha;
  vector[N] progression = beta[subject_index] .* (alpha[subject_index] + t);
}

model {
  // Priors
  sigma_alpha ~ normal(0, 1000); // SD of intercepts, in days
  beta_shape ~ gamma(4, 1);
  beta_rate ~ exponential(.001);
  
  c ~ normal(mean(c), 20); // What are c's units? 1/beta, maybe?
  
  
  alpha_raw ~ normal(0, 1); // "Raw"" distributions are standard Gaussian
  beta ~ gamma(beta_shape, beta_rate); // random slopes
  
  // Conditional Likelihood
  for (i in 1:N){
    severity[i] ~ ordered_logistic(progression[i],  c);
  }
}
