library("rjags")
# il faut un model
# on peut soit aller chercher un fichier sur un ordi et/ou on utilise un object R

model1 <- "model
{
for(i in 1:n)
{
fille[i] ~ dbern(p)
}
p ~ dunif(0, 1)
}
"

# il faut des donnée en liste
data4jags <- list(n = length(ppraevia), fille = ppraevia)

# il faut des valeurs initiale
valeurs_initiales <- list(list(p = 0.1),
                          list(p = 0.5),
                          list(p = 0.7))

m1 <- jags.model(textConnection(model1),
                 data = data4jags,
                 inits = valeurs_initiales,
                 n.chains = 3
                 )
# phase de chauffe = burnin
update(m1 , 1000)


# phase d'enregistrement

mcm1 <- coda.samples(m1, variable.names = c("p"), n.iter = 1000)

plot(mcm1)

# pour evaluer la convergence

gelman.plot(mcm1)
gelman.diag(mcm1)


# cunul plot il se fait chaine par chaine


cumuplot(mcm1[[1]])


# puis si on veut exploiter les chaines

summary(mcm1)

mcmc1_tot = as.data.frame(as.matrix(mcm1))
