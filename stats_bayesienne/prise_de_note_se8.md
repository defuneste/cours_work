# séance 8 le nombre le plus probables

Pour compter des microbes on utilise le nombre le plus probable. On fait une estimation avec un défaut de seuil de détection. Les données sont dites censurées. 

C'est un contexte d'appréciation des risques. On a de la variabilité et de l'incertitude (sans essayer de trop résumer les données). 

Il faut essayer de modéliser les données brutes. On peut mentionner le pb des 0. 

On va prendre des bouts de steak et on va faire des dilutions différentes. 

On regarde si cela pousse ou pas. 

Résultats pour chacune des dilutions du nombre de tubes ou cela pousse. 

Ce que l'on cherche c'est la concentration dans le bouts de steak.


## question 1

``` R

d <- list(m = c(1, 0.1, 0.01), nplus = c(2, 1, 0), r = 3, k = 3)

library(rjags)

model1 <- "model
{
  for (i in 1:k) { 
      nplus[i] ~ dbin(pplus[i], r)
      pplus[i] <- 1 - exp(-m[i] * conc)
      }
  log_conc ~ dunif(-6, 3)
  conc <- 10 ** (log_conc) 
}"

inits <- list(list(log_conc = - 5),
              list(log_conc = 0),
              list(log_conc = 2))

model1jags <- jags.model(file=textConnection(model1),
                         data=d,
                         inits=inits,
                         n.chains=3)

update(model1jags,3000)

mcmc_1 <- coda.samples(model1jags, c("conc"), n.iter=50000)

summary(mcmc_1)

plot(mcmc_1)

gelman.plot(mcmc_1)

autocorr.plot(mcmc_1[[3]])

```

## question 2

modele 1

``` R

nplus <- read.table(file = "seance8/dataNPP2.txt")
dcomplet <- list(m = c(1, 0.1, 0.01), nplus = nplus, r = 3, N = 50, k = 3)

model_q2_1 <- "model
{
for (i in 1:N) {
    for (j in 1:k){
      nplus[j, i] ~ dbin(pplus[j, i], r)
      pplus[j, i] <- 1 - exp(-m[j] * conc[i])
      }
      log_conc[i] ~ dnorm(mlc, 1/(slc^2))
      conc[i] <- 10 ** log_conc[i]
}
mlc ~ dunif(-6, 3)
slc ~ dunif(0, 4)
}
"

inits <- list(list(mlc = - 5, slc = 1),
              list(mlc = 0, slc = 2),
              list(mlc = 1, slc = 3))


model_q2_1jags <- jags.model(file=textConnection(model_q2_1),
                         data=dcomplet,
                         inits=inits,
                         n.chains=3)

update(model_q2_1jags,10000)

mcmc_q2_1 <- coda.samples(model_q2_1jags, c("conc"), n.iter=50000, thin = 2)

summary(mcmc_q2_1)

quantilq2_1 <- summary(mcmc_q2_1)$quantiles

as.data.frame(quantilq2_1)


Map(mean, as.data.frame(quantilq2_1))

```

modèle 2

``` R

model_q2_2 <- "model
{
for (i in 1:N) {
    for (j in 1:k){
      nplus[j, i] ~ dbin(pplus[j, i], r)
      pplus[j, i] <- max(1 - exp(-m[j] * conc[i]), 0.000001)
      }
      log_conc[i] ~ dnorm(mlc, 1/(slc^2))
      conc[i] <- (10 ** log_conc[i]) * conta[i] 
      conta[i] ~ dbern(pv)
}
pv ~ dunif(0, 1)
mlc ~ dunif(-6, 3)
slc ~ dunif(0, 4)
}
"

inits <- list(list(mlc = - 5, slc = 1, pv = 0.1),
              list(mlc = 0, slc = 2, pv = 0.5),
              list(mlc = 1, slc = 3, pv = 0.9))


model_q2_2jags <- jags.model(file=textConnection(model_q2_2),
                         data=dcomplet,
                         inits=inits,
                         n.chains=3)

update(model_q2_2jags,10000) 

mcmc_q2_2 <- coda.samples(model_q2_2jags, c("conc", "pv"), n.iter=50000, thin = 2)

summary(mcmc_q2_2)

str(mcmc_q2_2)

quantilq2_2 <- summary(mcmc_q2_2)$quantiles

Map(mean, as.data.frame(quantilq2_2))

hist(as.data.frame(as.matrix(mcmc_q2_2))$pv)
# ici le modele tape toujours sur 1 donc il rajoute de l'incertitude
```

