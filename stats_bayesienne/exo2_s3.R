# 10/05/2022 seance 3 stats bayesiennes
# poids moyen des garcons et poids moyen des filles


library("rjags")

data_poids <- read.table("seance3/pnais48.txt", h = T, sep = ",")
sexe <- data_poids$SEXE + 1
poids <- data_poids$POIDNAIS
table(sexe)


model2 <- "model
{
for (i in 1:n) {
         poids[i] ~ dnorm(moyenne[sexe[i]], tau)

}
 tau <- 1/(sigma^2)
 sigma ~ dunif(200, 800)
 moyenne[1] ~ dunif(2500, 5000)
 moyenne[2] ~ dunif(2500, 5000)

for(i in 1:n)
{
w[i] ~ dnorm(moyenne[sexe[i]], tau)
}

}"

                                        # donnée

data4jags <- list( n = length(poids),
                  poids = poids,
                  sexe = sexe)

                                        # valeurs initials

valeurs_initiales <- list(list(moyenne = c(2500, 2500),
                               sigma = 200),
                          list(moyenne = c(3759, 3750),
                               sigma = 500),
                          list(moyenne = c(5000, 5000),
                               sigma = 800 ))


m2 <- jags.model(textConnection(model2),
data = data4jags,
inits = valeurs_initiales,
n.chains = 3)


# phase de chauffe = burnin
update(m2 , 1000)


# phase d'enregistrement

mcm2 <- coda.samples(m2, variable.names = c("moyenne", "sigma"), n.iter = 1000)

plot(mcm2)

# pour evaluer la convergence

gelman.plot(mcm2)
gelman.diag(mcm2)


# cunul plot il se fait chaine par chaine


cumuplot(mcm2[[1]])


# puis si on veut exploiter les chaines

summary(mcm2)

mcmc2_tot = as.data.frame(as.matrix(mcm2))

head(mcmc2_tot)


### question 4

nb <- 48

gen_poids <- vector(mode = "numeric",
                    length = nb)

for (i in 1:nb) {
  sigma <- runif(1, 200, 800)
  moyenne <- runif(1, 2500, 5000)
  gen_poids[i] <-  rnorm(1, moyenne, sigma)
}
