// The Stan file specifies the model and eventually the prior distributions
// Please refer to the link below for general documentation about specifying linear models with Stan
// https://mc-stan.org/docs/2_22/stan-users-guide/linear-regression.html

// Input data
data {
  int<lower = 1> N; //Number of datapoints
  int<lower = 1> J; //Number of individuals

  int<lower = 1, upper = J> id[N]; //ID vector
  vector[N] y; //Dependent variable (Naming must match with specification in the R file.)
  vector[N] x_cwi; //Independent variable (Naming must match with specification in the R file.)
  
}

// Model parameters
parameters {
  
  vector[2] beta; //Fixed effects
                  //beta[1]: intercept, beta[2]: slope (parameter of interest!)
  vector[J] alpha; //Intercept random effects
  vector[J] omega; //Slope random effects

  real<lower=0> sigma_alpha; //Standard deviation of intercept random effects
  real<lower=0> sigma_omega; //Standard deviation of slope random effects
  real<lower=0> sigma; //Standard deviation of the dependent variable
}

// Model specification (Cp. above for naming of parameters)
transformed parameters {
  
  vector[N] lin_pred; //Conditional expectation
  for(i in 1:N){
    lin_pred[i] = beta[1] + alpha[id[i]] + beta[2] * x_cwi[i] + omega[id[i]] * x_cwi[i]; 
   // For clarity: Individual[i]'s slope is Beta[2] + omega[i] 
  }
}

//Prior 
// If prior settings are inactivated with "//" sampling will be done with improper priors
// Replace informative prior for beta[2] with (0, 1000) for flat prior
model {
  
beta[1] ~ normal(0, 100); // Flat prior for intercept fixed effect
beta[2] ~ normal(-0.208, 0.104); // Informative prior for difference between groups, 30 m sprint 
sigma ~ uniform(0, 1000); // Flat prior for standard deviation of the dependent variable
  
sigma_alpha ~ uniform(0, 1000); // Flat prior for standard deviation of intercept random effect
sigma_omega ~ uniform(0, 1000); // Flat prior for standard deviation of slopes random effect 
  
  for(j in 1:J){
  
    alpha[j] ~ normal(0, sigma_alpha);
    omega[j] ~ normal(0, sigma_omega);
  
  }
  
  y ~ normal(lin_pred, sigma);

}

generated quantities {
  
  vector[J] inter;
  vector[J] slope;
  
    for(j in 1:J){
    
    inter[j] = beta[1] + alpha[j];
    slope[j] = beta[2] + omega[j];
    
  }
  
}


