# Seance 6

On repart sur la définition de prior.

Comment demande t on un avis d'expert afin d'avoir une distribution ? 

"elicitation"


Dans certains cas c'est plus difficile d'exprimer la moyenne et c'est plus souvent la median qui est données. Eliciter des moment c'est difficile. On sait mieux exprimer des quantités. 

C'est mieux de positionner les quantiles extrêmes et après c'est plus facile une fois que l'on a défini les bornes. Souvent on peut aussi demander min et max.

il y a une bibliothèque de R : SHELF. Celui ci teste une batterie de loi de probabilité.  

Il y a Match Tool, on demande de positionner des jetons qui va dessiner des histogramme.  


## Question 5 

### a l'oeil: 

$ beta(0.5,0.5) $  

- Moyenne : 0.5
- sd : 0.4

$ beta(2, 2) $

- Moyenne : 0.5
- sd : 0,2

$ beta(2, 5) $

- Moyenne : 0.28
- sd : 0,15


$ beta(1, 10) $

-Moyenne : 0,10
-sd : 0,10


``` R 
## une fonction
moyenne_sd <- function(alpha, beta) {
   reponse = vector()
   reponse[1] = (alpha)/(alpha + beta)
   reponse[2] = (alpha * beta)/(((alpha + beta) ** 2) * (alpha + beta + 1 ))
   return(reponse)
}

moyenne_sd(0.5, 0.5)
moyenne_sd(2, 2)
moyenne_sd(2, 5)
moyenne_sd(1, 10)

```

Question 5

``` R

library("SHELF")

q <- c(0.0001, 0.001, 0.01) # quantiles donnees

Fq <- c(0.025, 0.5, 0.975) # Frequences cumulees associees a ces quantiles

inita <- 1; initb <- 1 # valeurs initiales pour les parametres de la loi beta

diffCvM <- function(vecab)
{
Fqtheo <- pbeta(q, shape1 = vecab[1], shape2 = vecab[2], lower.tail = T)
f <- sum((Fq - Fqtheo)^2) # cramer von misses
}

resCvM <- optim(c(inita, initb), diffCvM) # minimisation de la distance
                                        # exemple simple avec optim
# technique de descente ou de monter de gradient 
(beta = resCvM$par[2])

(alpha = resCvM$par[1]) # premier parametre estime de la loi beta

fit <- fitdist(vals = q, probs = Fq, lower = 0, upper = 1)
fit$Beta


```



Question 6


``` R
library("rjags")

model_logit <-
"model
{
y ~ dbin(pi, n)
pi ~ dbeta(1.578272, 1259.374)
}"

# Donnees
data <- list(y = 1, n = 25e2)
# Valeurs initiales
inits <- list(list(pi = log(1e-4)),
              list(pi = log(1e-3)),
              list(pi = log(1e-2)))
# MCMC
m_logit <- jags.model(textConnection(model_logit),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_logit, 3000)

mcmc_logit <- coda.samples(m_logit, c("pi")
                         , n.iter = 3000)

                                        # Resultats

summary(mcmc_logit)$quantiles

```


Question 7

``` R

pr = 0.1

q <- c(0.05, 0.1, 0.2)
fq <- c(0.025, 0.5, 0.975)

distrib_au_pif <- fitdist(vals = q
                        , probs = fq
                        , lower = 0
                        , upper = 1 )

distrib_au_pif$Beta


data4jags <- list(
  n = 245,
  pos = 29
)

model_fix <- "model{
pr = 0.1
se ~ dunif(0,1)
pos ~ dbinom(se * pr, n)
vpn = (1 - pr) / ((1 - pr) + pr * (1 - se))
}"

inits <- list(list(se = 0.05),
               list(se = 0.5),
               list(se =0.99))

m_fixe <- jags.model(textConnection(model_fix),
                     data = data4jags,
                     inits = inits,
                     n.chains = 3
                     )

update(m_fixe, 3000)


mcmc_fixe <- coda.samples(m_fixe, c("se", "vpn"), n.iter = 3000)

summary(mcmc_fixe)

#### la version bayesienne

model_meta <- "model{
pr ~ dbeta(1.578, 1259.374)
se ~ dunif(0,1)
pos ~ dbinom(se * pr, n)
vpn = (1 - pr) / ((1 - pr) + pr * (1 - se))
}"

inits <- list(list(se = 0.05),
               list(se = 0.5),
               list(se =0.99))

m_meta <- jags.model(textConnection(model_meta),
                     data = data4jags,
                     inits = inits,
                     n.chains = 3
                     )

update(m_meta, 3000)


mcmc_fixe <- coda.samples(m_fixe, c("se", "vpn"), n.iter = 3000)

summary(mcmc_fixe)

```


