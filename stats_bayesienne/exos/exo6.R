### exo 6

library("rjags")

data <- read.table("../seance6_hierarchique/men_size2.txt",
                   header = TRUE)
str(data)

stripchart(size~country, data=data, vertical=TRUE, pch=16,
           method = "jitter")

model_1 <- "model
{ for (i in 1:N) {
size[i] ~ dnorm(mu_k, tau_k)
}
mu_k ~ dunif(100,250)
sigma_k <- 5.3
tau_k <- 1/sigma_k^2
}"

choice <- "France"

data_k <- subset(data, country==choice)

data4jags <- with( data_k, list(size=size, N=length(size)))

init <- list(list(mu_k=150),
             list(mu_k=110),
             list(mu_k=190))

modeljags_1 <- jags.model(file=textConnection(model_1),
                          data=data4jags, inits=init, n.chains=3)

update(modeljags_1,3000)

mcmc_1 <- coda.samples(modeljags_1, "mu_k", n.iter=50000, thin=10)


summary(mcmc_1)


##########

                                        # Chosen country and subset of others

choice <- "France"
others <- subset(data, country != choice)

# empirical means and number of countries
mean_others <- tapply(others$size, factor(others$country), mean)
ncount <- length(mean_others)

# simple estimation of a normal distribution parameters
(M0 <- mean(mean_others))
(S0 <- sd(mean_others))

                                        # data to pass to JAGS (including prior parameters)

data_k <- subset(data, country == choice)
data4JAGS <- with(data_k, list(size =size,N=length(size)))

model_2 <- "model
{
    for (i in 1:N) {
        size[i] ~ dnorm(mu_k, tau_k)
        }
     mu_k ~ dnorm(178.14, 1/(3.73)**2 )
     sigma_k <- 5.3
     tau_k <- 1/sigma_k^2
}"

modeljags_2 <- jags.model(file=textConnection(model_2),
                          data=data4JAGS, inits=init, n.chains=3)

update(modeljags_2,3000)

mcmc_2 <- coda.samples(modeljags_2, "mu_k", n.iter=50000, thin=10)


summary(mcmc_2)
