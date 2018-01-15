parameters {
  real y[2]; 
} 
model {
  y[1] ~ normal(0, 1);
  y[2] ~ double_exponential(0, 2);
}
