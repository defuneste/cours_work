# Date: February 2022
# Olivier
# Homework week 4 Statictical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week07.pdf

library(rethinking)
data(bangladesh)
str(bangladesh)

d <- bangladesh
table(d$use.contraception, d$district)

                                        # 1

dat <- list(
    Contr = d$use.contraception,
    Dis = as.integer(as.factor(d$district)) )




m1 <- ulam(
    alist(
        Contr ~ bernoulli(p) ,
        logit(p) <- a[Dis] ,
        a[Dis] ~ dnorm( a_bar , sigma ) ,
        a_bar ~ dnorm( 0 , 1.5 ) ,
        sigma ~ dexp(1)
    ), data = dat , chains = 4 , log_lik = TRUE )

precis(m1, depth = 2)

m1s <- ulam(
  alist(
    Contr ~ bernoulli(p),
    logit(p) <- a[Dis],
    vector[61]:a ~ normal(a_bar, sigma),
    a_bar ~ normal(0, 1),
    sigma ~ exponential(1)
  ), data = dat, chains = 4, cores = 4
)

precis(m1s, depth = 2)

# plot estimates

post <- extract.samples(m1s)
str(post)

p <- inv_logit(post$a)
plot( apply(p,2,mean), xlab = "district", lwd = 3 , col = 2,
     ylim = c(0,1), ylab = "prop use contraception")
for (i in 1:61) {lines ( c(i,i), PI(p[,i]), lwd = 8,
                        col = col.alpha(2, 0.5))}

# les proportions des donnees

n <- table(dat$Dis)

# tableau de contingence
Cn <- xtabs(dat$Contr ~ dat$D)
# proportions
pC <- as.numeric(Cn/n)
# rajout de la valeur manquante
pC <- c(pC[1:53], NA, pC[54:60])
points(pC, lwd = 2)

                                        # add sample size labesl

y <- rep(c(0.8, 0.85, 0.9), len = 61) # jitter to see all sample
n <- as.numeric(n)
n <- c(n[1:53], 0, n[54:60]) # adding missing district
text(1:61, y , n , cex = 0.8)

# Raw sample that are outside of CI tends to be with low sample number, but not always
# 54 it seems it use the mean and CI from all the other districts

                                        # 2
# A ---> C # age should influence contraception probably not linear
# A ---> K # age influence number of children, it take time to have one and other tike to get an other one
# the you have menopause
# K ---> C # unlcear but should be chceked, at one point do you want to stop having children, probably
# U and D ---> C # both are possible hiding socio economic factor that should have effect on C
# U and D ---> K # same than the one with C, but It is quite possible that you have additionnal effect that the one that go throught C
# U and D ---> A # I do not know if Bangladesh have some kind of zoning but it is an option with some district with more young and other with more families
# D ---> U # where you are will effect U
#
#For estimmating effect of U on C we need to close D and take into account A
# I need to stratify by all of the above (D, A) + K. If I do not stratify on A it opens a backdoor with K

                                        # 3
# more data
dat <- list(
  C = d$use.contraception,
  D = as.integer(d$district),
  U = d$urban,
  A = standardize(d$age.centered),
  K = d$living.children
)

#Richard started with total effect

m3total <- ulam(
  alist(
    C ~ bernoulli(p),
    logit(p) <- a[D] + bU*U, # adding the effect of U
    bU ~ normal(0 , 0.5), # quite a large effect around 0
    vector[61]:a ~ normal(abar, sigma),
    abar ~ normal(0,1),
    sigma ~ exponential(1)
  ), data = dat, chains = 4, cores = 4
)

precis(m3total)

# I am surpise about this strong total effect.

table(dat$K) # 4 possibles values, we do not have 0 child ?

# I guess I am lost at this points
# direct

dat$Kprior <- rep(2 ,3) # here I understand the why we 3 (4 values but on fixed) but not why we pick 2
m3direct <- ulam(
  alist(
    C ~ bernoulli(p),
    logit(p) <- a[D] + bU*U + bA*A + bK * sum(delta_j[1:K]), # 4 parameters for K
    c(bU, bA, bK) ~ normal(0, 0.5), # they all take the same prior
    vector[4]:delta_j <<- append_row(0, delta), # this part lost me: <<- means in global env ?
    simplex[3]:delta ~ dirichlet(Kprior), # this is some distributions for delta
    vector[61]:a ~ normal(abar, sigma),
    abar ~ normal(0,1),
    sigma ~ exponential(1)
  ), data = dat , chains = 4, cores = 4,  iter = 4000 # we increase here why ?
)

precis(m3direct, depth = 2)

# not much change on bU, delta 1 is important (I still do not get why we do not get the first).
# I will not be able to go further.
