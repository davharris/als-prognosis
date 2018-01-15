data {
  int<lower=1> N; // Rows of data
  int<lower=2> K; // Number of possible responses, including zero
  int<lower=1,upper=K> y[N]; // ALSFRS symptoms are each on 0-4 scale
  real t[N];
}

parameters {
  real beta;
  ordered[K-1] c;
}

model {
  beta ~ normal(0, 0.1);
  c ~ normal(0, 10);
  
  for (i in 1:N){
    y[i] ~ ordered_logistic(beta * t[i], c);
  }
}
