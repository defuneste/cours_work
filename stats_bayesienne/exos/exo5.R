                                        # Modele

model <-
"model
{
y ~ dbin(pi, n)
pi ~ dunif(1e-04, 1e-02)
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(pi = 1e-4),
              list(pi = 1e-3),
              list(pi = 1e-2))
# MCMC
m <- jags.model(textConnection(model),
                data = data,
                inits = inits,
                n.chains = 3)

update(m, 3000)

mcmc <- coda.samples(m, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc)
summary(mcmc)$statistics
summary(mcmc)$quantiles

#########

model_log <-
"model
{
y ~ dbin(pi, n)
log10_pi ~ dunif(-4, -2)
pi = 10^log10_pi
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(pi = -3.99),
              list(pi = -3),
              list(pi = -2.01))
# MCMC
m_log <- jags.model(textConnection(model_log),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_log, 3000)

mcmc_log <- coda.samples(m_log, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc)
summary(mcmc)$statistics
summary(mcmc)$quantiles


###############################3

#########

model_log <-
"model
{
y ~ dbin(pi, n)
log10_pi ~ dunif(-4, -1)
pi = 10^log10_pi
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(pi = -3.99),
              list(pi = -3),
              list(pi = -1.01))
# MCMC
m_log <- jags.model(textConnection(model_log),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_log, 3000)

mcmc_log <- coda.samples(m_log, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc)
summary(mcmc)$statistics
summary(mcmc)$quantiles

#########

#########

model_log <-
"model
{
y ~ dbin(pi, n)
log10_pi ~ dunif(-4, -2)
pi = 10^log10_pi
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(pi = -3.99),
              list(pi = -3),
              list(pi = -2.01))
# MCMC
m_log <- jags.model(textConnection(model_log),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_log, 3000)

mcmc_log <- coda.samples(m_log, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc)
summary(mcmc)$statistics
summary(mcmc)$quantiles

                                        # Modele

model <-
"model
{
y ~ dbin(pi, n)
pi ~ dunif(1e-4, 1)
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(pi = 1e-4),
              list(pi = 1e-3),
              list(pi = 1))
# MCMC
m <- jags.model(textConnection(model),
                data = data,
                inits = inits,
                n.chains = 3)

update(m, 3000)

mcmc <- coda.samples(m, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc)
summary(mcmc)$statistics
summary(mcmc)$quantiles

#########

model_log <-
"model
{
y ~ dbin(pi, n)
log10_pi ~ dunif(-4, 0)
pi = 10^log10_pi
}"

# Donnees
data <- list(y = 4, n = 10000)
# Valeurs initiales
inits <- list(list(log10_pi = -3.99),
              list(log10_pi = -3),
              list(log10_pi = -2.01))
# MCMC
m_log <- jags.model(textConnection(model_log),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_log, 3000)

mcmc_log <- coda.samples(m_log, c("pi"), n.iter = 3000)
                                        # Resultats

plot(mcmc)


gelman.diag(mcmc_log)


rbind(log10(summary(mcmc_log)$quantiles),
log10(summary(mcmc)$quantiles))

###############################3


#########

model_logit <-
"model
{
y ~ dbin(pi, n)
logit_pi ~ dnorm(-3 * log(10), preci)
preci = 4 / (log(10))^2
pi = 1 / (1 + exp(logit_pi))
log10_pi = log(pi)/log(10)
}"

# Donnees
data <- list(y = 1, n = 25e2)
# Valeurs initiales
inits <- list(list(logit_pi = log(1e-4)),
              list(logit_pi = log(1e-3)),
              list(logit_pi = log(1e-2)))
# MCMC
m_logit <- jags.model(textConnection(model_logit),
                data = data,
                inits = inits,
                n.chains = 3)

update(m_logit, 3000)

mcmc_logit <- coda.samples(m_log, c("pi", "log10_pi")
                         , n.iter = 3000)
                                        # Resultats

summary(mcmc_logit)$quantiles

exo_test <- rbind(log10(summary(mcmc_log)$quantiles),
      log10(summary(mcmc)$quantiles),
      summary(mcmc_logit)$quantiles[1,])

rownames(exo_test) <- c("log uniform", "uniform", "logit normal")
