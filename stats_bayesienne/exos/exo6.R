### exo 6

library("rjags")

data <- read.table("seance6_hierarchique/men_size2.txt",
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


######################### semaine 7 continuité exo modele hiérarchique

# Vector of (unique) country names and length of this vector
countries <- unique(data$country)
ncountries <- length(countries)

# Vector of individual measures and countries for these individuals,
# length of these vectors (number of individuals)
size <- data$size
numcountry <- match(data$country, countries)
nindiv <- nrow(data)



fonction_cght_prior <- function(prior = "dgamma(0.01, 0.01)") {
# Data passed to JAGS
data4JAGS <- list(size=size,
                  numcountry=numcountry,
                  ncountries=ncountries,
                  nindiv=nindiv)
##
inits = list(list(M = 100),
             list(M = 175),
             list(M = 249))
##
model_3 <- paste0("model
{
M ~ dunif(100, 250)
tau_intra ~" , prior,"
tau_inter ~", prior,"
sigma_intra <- 1/sqrt(tau_intra)
sigma_inter <- 1/sqrt(tau_inter)
for(j in 1:ncountries){
mu[j] ~ dnorm(M, tau_inter)
}
for (i in 1:nindiv) {
size[i] ~ dnorm(mu[numcountry[i]], tau_intra)
}
}
")
##
modeljags_3  <- jags.model(file=textConnection(model_3),
                          data=data4JAGS, inits=inits, n.chains=3)
##
update(modeljags_3,3000)
##
mcmc_3 <- coda.samples(modeljags_3, c("M", "mu", "sigma_inter", "sigma_intra"), n.iter=50000)
print(paste0("le prior est :", prior))
return(mcmc_3)
##
}

mcmc_3 <- fonction_cght_prior()
summary(mcmc_3)

mcmc_4 <- fonction_cght_prior("dgamma(0.001, 0.001)")
summary(mcmc_4)

bob <- as.data.frame(as.matrix(mcmc_4))
head(bob[,2:10])
dim(bob)

str(mcmc_4)
boxplot(bob[,2:10])

str(mcmc_4[[1]])
