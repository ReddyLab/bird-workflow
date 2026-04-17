functions {
   // This function can be used via: p~betaModeConc(mode,concentration);
   real betaModeConc_lpdf(real parm,real m,real c) {
      return beta_lpdf(parm|m*(c-2)+1, (1-m)*(c-2)+1);
   }  
}

data {
   int<lower=0> N_DNA;               // number of DNA replicates
   array[N_DNA] int<lower=0> a;      // DNA alt read counts
   array[N_DNA] int<lower=0> b;      // DNA ref read counts
   int<lower=0> N_RNA;               // number of RNA replicates
   array[N_RNA] int<lower=0> k;      // RNA alt read counts
   array[N_RNA] int<lower=0> m;      // RNA ref read counts
}

parameters {
   real<lower=0,upper=1> p; // alt allele freq in DNA library
   array[N_RNA] real<lower=0,upper=1> qi; // alt allele freqs in RNA reps
   real<lower=0> theta; // effect size (odds ratio)
   real<lower=2> c; // concentration parameter of beta prior for qi
   real<lower=0> s; // variance parameter of lognormal prior for theta
}

transformed parameters {
   real<lower=0,upper=1> q; // alt allele freq in RNA
   q=theta*p/(1.0-p+theta*p);
}

model {
   // Parameters:
   c ~ gamma(1.1, 0.0005); // concentration parameter for prior on qi
   s ~ gamma(1.1,3);       // variance parameter for prior on theta
   log(theta)/s ~ normal(0,1); // prior on theta
   target+=-log(theta)-log(s); // Jacobian for lognormal theta prior
   for(i in 1:N_RNA)
      qi[i] ~ betaModeConc(q,c);

   // Likelihoods:
   for(i in 1:N_DNA)
      a[i] ~ binomial(a[i]+b[i],p);
   for(i in 1:N_RNA)
      k[i] ~ binomial(k[i]+m[i],qi[i]);
}



