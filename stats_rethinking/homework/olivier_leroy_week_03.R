# Date january 2022
# Olivier Leroy
# Homework week 3 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week03.pdf


# Loading data =================================================================


library(rethinking)
data(foxes)
str(foxes)

d <- foxes
d$A <- rethinking::standardize(d$area)
d$Food <- rethinking::standardize(d$avgfood)
d$G <- rethinking::standardize(d$group)
d$W <- rethinking::standardize(d$weight)
                                        # 1

# Influence of A on F
# step 1 identify all path from treatment A to outcome F
# A ---> F
# step 2 identify backdoor
# None
# step 3 closing backdoor
# not needed
# Effect of increasing area of a territory on the ammount of food ?
# I assume increasing the area will increase the amount of food available.
# The rate of increase will depend of the spatial distribution of foods,
# insight we do not have.
# we can atleast check the data

plot(foxes$area, foxes$avgfood,
     xlab = "Area", ylab = "Avg Food",
     col = 2)

sd(d$area)

m_hw_1 <- rethinking::quap(
                        alist(
                          Food ~ dnorm(mu, sigma),
                          mu <- alpha + betaA * A,
                          alpha ~ dnorm(0 , 0.2),
                          betaA ~ dnorm(0,0.5),
                          sigma ~ dexp(1)
                        ), data = d
                      )

rethinking::precis(m_hw_1)

A_seq <- seq(from = -3, to = 3, by = 0.5)
mu <- rethinking::link(m_hw_1, data = list(A = A_seq))
mu_mean <- apply(mu, 2, mean)
mu_PI <- apply(mu, 2, rethinking::PI)
plot( Food ~ A , data=d , col=rangi2 )
lines( A_seq , mu_mean , lwd= 2 )
shade( mu_PI , A_seq )
                                        # 2

plot(d$Food, d$W, col = as.factor(d$groupsize))

library("dagitty")
dag_fox <- dagitty( "dag {
F -> W
F -> G -> W
A -> F
}")
# testing a bit some options
adjustmentSets(dag_fox, exposure = "F", outcome = "W")
parents(dag_fox, "W")

m_hm_2 <-rethinking::quap(
                       alist(
                         # F -> W <- G
                         W ~ dnorm(mu, sigma),
                         mu <- alpha + betaF * Food + betaG * G,
                         alpha ~ dnorm(0, 0.2),
                         betaF ~ dnorm(0, 0.5),
                         betaG ~ dnorm(0, 0.5),
                         sigma ~ dexp(1),
                         # F -> G
                         G ~ dnorm(mu_G, sigma_G),
                         mu_G <- alphaG + betaFG * Food,
                         alphaG ~ dnorm(0, 0.2),
                         betaFG ~ dnorm(0, 05),
                         sigma_G ~ dexp(1)
                       ), data = d
                     )

plot(precis(m_hm_2))
# betaFG is postive while betaF and betaG are close to 0.
 # Avg food have an effect on group size and this confound the effect on Weight

                                        # 3
# step 1
# X-> y
# (1) X <- A -> Y
# (2) X <- S -> Y
# (3) X <- S <- U -> Y
# (4) X <- S <- A -> Y
# step 2
# (1,2,3,4) are bakdoor
# step 3
# We have to cut A all the times then either we cut U or S, we do not know U so I guess S
# let say we have mu = alpha + bX*X + bS*S + bA*A
# we need to do condition on A and S
# the three coef bX, bS and BA are causal
