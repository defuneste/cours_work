# Date Februray 2022
# Olivier Leroy
# Homework week 6 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week06.pdf

# Keep them alive !


                                        # 1

# a_j ~ Normal(a_bar, sigma)
# a_bar ~ Normal(0, 1)
#  sigma ~ Exponential(1)
#  not sure I understand the advice to stransform a_j

library(rethinking)
curve( dnorm(x,0,1) , from=-6 , to=6 , lwd=4 , col=2 , xlab="a_bar" , ylab="Density" )

rates <- c(0.1,1,5,10)
set.seed(42)

curve( dexp(x, rates[1]) , from=0 , to=5 , lwd=4 , col=2 , xlab="sigma" , ylab="Density" )

abar <- rnorm(1e5,0,1)

plot(NULL, xlim = c(-6,6), ylim = c(0,0.5), ylab = "Density")

for (i in rates) {
  s <- rexp(1e5, i)
  a <- rnorm(1e5,abar,s)
dens( a , xlim=c(-6,6) , lwd=4 , col=2   , adj=1 ,add = TRUE) }

                                        # 2

                                        # G --> P # bigger easier ?
                                        # T --> S
                                        # D --> S
                                        # G --> S
                                        # p --> S
data(reedfrogs)
d <- reedfrogs
dat <- list(
  S = d$surv,
  n = d$density,
  tank = 1:nrow(d),
  # no ou pred
  pred = ifelse( d$pred=="no" , 0L , 1L ), # on veut vraiement scpeifier un entier ?
  size_ = ifelse( d$size=="small" , 1L , 2L ), # big ou small
  class_dens = ifelse(d$density == 10, 1L, # for exo 3
               ifelse(d$density == 25, 2L, 3L))
  )

m1.1 <- ulam(
  alist(
    S ~ binomial( n , p ),
    logit(p) <- a[tank],
    a[tank] ~ normal( a_bar , sigma ),
    a_bar ~ normal( 0 , 1.5 ),
    sigma ~ exponential( 1 )
  ), data=dat , chains=4 , cores=4 , log_lik=TRUE )

# pred
m1.2 <- ulam(
  alist(
    S ~ binomial( n , p ),
    logit(p) <- a[tank] + bp*pred,
    a[tank] ~ normal( a_bar , sigma ),
    bp ~ normal( -0.5 , 1 ),
    a_bar ~ normal( 0 , 1.5 ),
    sigma ~ exponential( 1 )
  ), data=dat , chains=4 , cores=4 , log_lik=TRUE )

# size
m1.3 <- ulam(
  alist(
    S ~ binomial( n , p ),
    logit(p) <- a[tank] + s[size_],
    a[tank] ~ normal( a_bar , sigma ),
    s[size_] ~ normal( 0 , 0.5 ),
    a_bar ~ normal( 0 , 1.5 ),
    sigma ~ exponential( 1 )
  ), data=dat , chains=4 , cores=4 , log_lik=TRUE )

# pred + size
m1.4 <- ulam(
  alist(
    S ~ binomial( n , p ),
    logit(p) <- a[tank] + bp*pred + s[size_],
    a[tank] ~ normal( a_bar , sigma ),
    bp ~ normal( -0.5 , 1 ),
    s[size_] ~ normal( 0 , 0.5 ),
    a_bar ~ normal( 0 , 1.5 ),
    sigma ~ exponential( 1 )
  ), data=dat , chains=4 , cores=4 , log_lik=TRUE )

# pred + size + interaction
m1.5 <- ulam(
  alist(
    S ~ binomial( n , p ),
    logit(p) <- a_bar + z[tank]*sigma + bp[size_]*pred + s[size_],
    z[tank] ~ normal( 0 , 1 ),
    bp[size_] ~ normal( -0.5 , 1 ),
    s[size_] ~ normal( 0 , 0.5 ),
    a_bar ~ normal( 0 , 1.5 ),
    sigma ~ exponential( 1 )
  ), data=dat , chains=4 , cores=4 , log_lik=TRUE )

post <- extract.samples( m1.5 )
quantile( post$bp[,2] - post$bp[,1] , c(0.055,0.5,0.945) )

# I do not have too much time but I would like to compare but anwsers are in the solution


                                        # 3

dat$class_dens

#out of time !
