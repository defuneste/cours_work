<!-- Formation stats bayesienne organisée par le LBBE 
 https://lbbe.univ-lyon1.fr/fr/formation-statistique-bayesienne
 Mai 2022
 Prise de Note Olivier Leroy
 -->

# Séance 4

un des avantages des MCMC est la capacité à créer n'importe qu'elle type de modèle. Il faut donc s'assurer de la bonne formalisation du modèle. 

On va utiliser des DAG. 

C'est un graphe dirigé: les liens ont un sens 

C'est sans cycle on ne peut pas revenir. 

Si c'est fixé on met dans un carré. 

On peut matérialiser les liens de façon différentes en fonction de stochastique ou déterministe.

On peut aussi utiliser des cadres pour savoir ou interviennent les paramètres/données. 

``` R 
library("rjags")

data <- read.csv("seance4/schisto.txt")
str(data)


modele1 <- "model
{

lambda ~ dgamma(12, 2)

for (i in 1:N) {
nb_oeuf[i] ~ dpois(lambda)
}


}
"

# replicate(50, rgamma(1, 12, 2))


data4jags <- list(nb_oeuf = data$y,
                  N = length(data$y))

inits1 <- list(list(lambda = 0.1),
               list(lambda = 7),
               list(lambda = 2))

m1 <- jags.model(textConnection(modele1),
                 data = data4jags,
                 inits = inits1,
                 n.chains = 3)

# phase de chauffe = burnin
update(m1 , 1000)


# phase d'enregistrement

mcmc1 <- coda.samples(m1, variable.names = c("lambda"), n.iter = 2000)

plot(mcmc1)

# pour evaluer la convergence

gelman.plot(mcmc1)
gelman.diag(mcmc1)

autocorr.plot(mcmc1)

cumuplot(mcmc1)

summary(mcmc1)

mcmc1_tot <- as.data.frame(as.matrix(mcmc1))

modele0 <- "model
{

lambda ~ dgamma(12, 2)

for (i in 1:N) {
egg_theory[i] ~ dpois(lambda)
}


}
"

m0 <- jags.model(textConnection(modele0),
                 data = data4jags,
                 inits = inits1,
                 n.chains = 3)
update(m0 , 1000)


# phase d'enregistrement

mcmc0 <- coda.samples(m0, variable.names = c("lambda"), n.iter = 2000)

mcmc0_tot <- as.data.frame(as.matrix(mcmc0))

hist(mcmc1_tot[, "lambda"], main = "", xlab = "lambda", prob = TRUE, xlim = c(0,12))
lines(density(mcmc0_tot[, "lambda"]), lwd=3, col = "steelblue3")

bob <- vector(mode = "double", length = 6000)

for( i in 1:6000) {
bob[i] <- sd(rpois(916,  mcmc1_tot[i,1]))
}

str(mcmc1_tot)

sd(data$y)
```

## partie 3 Modèle binomial négatif



