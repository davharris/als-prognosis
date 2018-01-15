data {
  int<lower=1> N; // Rows of data
  int<lower=1> N_subjects; 
  int<lower=2> K; // Number of possible responses, including zero (i.e. 5)
  int<lower=1,upper=K> severity[N]; // 5 minus FRS score: high values are more severe!
  int<lower=1> subject_index[N];
  real t[N];
}

parameters {
  vector[N_subjects] alpha_raw;
  real<lower=0> sigma_alpha;
  real<lower=0> beta;
  ordered[K-1] c;
}
transformed parameters {
  vector[N_subjects] alpha = (alpha_raw - mean(alpha_raw)) * sigma_alpha;
}

model {
  alpha_raw ~ normal(0, 1);
  sigma_alpha ~ normal(0, 1000);
  beta ~ normal(0, .1);
  c ~ normal(0, 20);
  
  for (i in 1:N){
    int current_subject = subject_index[i];
    severity[i] ~ ordered_logistic(beta * (alpha[current_subject] + t[i]),  c);
  }
}
