# Date February 2022
# Olivier Leroy
# Homework week 4 444tistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week04.pdf



                                        # 1
## loading library and data
library(rethinking)

d <- sim_happiness( seed=1977 , N_years=1000 )
precis(d)
d2 <- d[ d$age>17 , ] # only adults
d2$A <- ( d2$age - 18 ) / ( 65 - 18 )
precis(d2)

d2$mid <- d2$married + 1

# the spurious association between age and happyness
m6.9 <- quap(
    alist(
        happiness ~ dnorm( mu , sigma ),
        mu <- a[mid] + bA*A,
        a[mid] ~ dnorm( 0 , 1 ),
        bA ~ dnorm( 0 , 2 ),
        sigma ~ dexp(1)
    ) , data=d2 )
precis(m6.9,depth=2)

# no association if we do not take collider M
m6.10 <- quap(
    alist(
        happiness ~ dnorm( mu , sigma ),
        mu <- a + bA*A,
        a ~ dnorm( 0 , 1 ),
        bA ~ dnorm( 0 , 2 ),
        sigma ~ dexp(1)
    ) , data=d2 )
precis(m6.10)

# compare

rethinking::compare(m6.9, m6.10, func = PSIS)
rethinking::compare(m6.9, m6.10, func = WAIC)

# Bad model (m6.9) wins the prediction (with both PSIS and WAIC)
# Based on the causal model we should keep the less accurate at prediction model.
# The parameters can only be interpreted as displaying association between Marriage and Age


                                        # 2
# data
data(foxes)
d <- foxes
d$W <- standardize(d$weight)
d$A <- standardize(d$area)
d$F <- standardize(d$avgfood)
d$G <- standardize(d$groupsize)

                                        # building model
# Total effect
m2 <- quap(
    alist(
        W ~ dnorm( mu , sigma ),
        mu <- a + bF*F,
        a ~ dnorm(0,0.2),
        bF ~ dnorm(0,0.5),
        sigma ~ dexp(1)
    ), data=d )

# direct effect of F
m2b <- quap(
    alist(
        W ~ dnorm( mu , sigma ),
        mu <- a + bF*F + bG*G,
        a ~ dnorm(0,0.2),
        c(bF,bG) ~ dnorm(0,0.5),
        sigma ~ dexp(1)
    ), data=d )


                                        # compare
rethinking::compare(m2, m2b, func = PSIS)
rethinking::compare(m2, m2b, func = WAIC)

d$k <- PSIS(m2b, pointwise = TRUE)$k
d[d$k > 0.3,]
d[d$k < -0.3,]
# According to PSIC and WAIC the best model would be m2b.
# the one that take both the Food and group size
# the interpretation does not change from last week


                                        # 3
                                        # loading data

data(cherry_blossoms)
d <- cherry_blossoms
precis(d)
plot(d$year, d$doy)
plot(d$temp, d$doy)
d2 <- d[complete.cases(d$doy), ]
d2 <- d2[complete.cases(d2$temp),]
precis(d2)

d2$T <- standardize(d2$temp)


# temp --> doy
# year --> temp
# year --> doy

#total effect
m3 <- quap(
  alist(
    doy ~ dnorm(mu, sigma),
    mu <- alpha + betaT * temp,
    alpha ~ dnorm(90,6), # in march
    betaT ~ dnorm(10, 4),     #  7-13 according internet
    sigma ~ dexp(1)
    ), data = d2
)

m3b <- quap(
  alist(
    doy ~ dnorm(mu, sigma),
    mu <- alpha + betaT * temp + betaY * year,
    alpha ~ dnorm(90,6), # in march
    betaT ~ dnorm(0, 10),#
    betaY ~ dnorm(0, 10), # I am probably wrong here
    sigma ~ dexp(1)
    ), data = d2
)


rethinking::compare(m3, m3b, func = PSIS)
rethinking::compare(m3, m3b, func = WAIC)

# m3 is a bit better but they are close, I should investigate temp and year.

                                        # Predict  with 9 degree

doy_sim <- sim(m3, data= list(temp = 9))
hypo_day <- round(mean(doy_sim))
range <- round(PI(doy_sim, prob = 0.89))

as.Date(hypo_day, origin = "2050-01-01") # maybe I get it wrong
as.Date(range, origin = "2050-01-01")
