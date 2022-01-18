# Date january 2022
# Olivier Leroy
# Homework week 2 Statistical Rethinking
#
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week02.pdf


# Loading library & data prep

library(rethinking)
data(Howell1)
d <- Howell1[Howell1$age >= 18,]

                                        # 1 ====================

                                        # step 1 prepare data

dat <- list(
  W = d$weight,
  H = d$height,
  Hbar = mean(d$height)
)

                                        # step 2 define model

m_homework_1 <- rethinking::quap(
                              alist(
                                W ~ dnorm(mu, sigma),
                                mu <- a + b*(H - Hbar),
                                a ~ dnorm(60, 10),
                                b ~ dlnorm(0, 1),
                                sigma ~ dunif(0, 10)
                              ), data = dat)

precis(m_homework_1)

                                        # step 3 extract sample

post <- rethinking::extract.samples(m_homework_1, n = 1e4)

                                        # step 4 simulate from post

expected_value <- function( height ) {
  y <- rnorm(1e4,
             mean = post$a + post$b * (height - dat$Hbar),
             sd = post$sigma)
  return(c(expected_weight = mean(y) ,
           rethinking::PI(y, prob = 0.89)))
}

expected_value(140)

individual_list <- c(140, 160, 175)
result_1 <-  as.data.frame(t(sapply(individual_list, expected_value)))
result_1$height <- individual_list
result_1$individual <- 1:3

                                        # step 5 display as table
result_1[,c(5,4,1:3)]

                                        # 2 ================================

                                        # step 1 data prep'

d_2 <- Howell1[Howell1$age < 13,]

                                        # step 1b checking data

plot(d_2$height, d_2$weight)
plot(d_2$age, d_2$height)
plot(d_2$age, d_2$weight)
# it seems we have strong correlations

dat = list(
  W = d_2$weight,
  A = d_2$age,
  BarA = mean(d_2$age)

)


                                        # step 2 defining the model
set.seed(42)
n_samples <- 20
alpha <- rnorm(n_samples, 20, 4)
beta <- rlnorm(n_samples, 0, 1)
BarA <- 6
Aseq <- seq(from = 0, to = 13, by = 1)

plot(NULL, xlim = c(0, 13), ylim = c(0, 35),
     xlab = "Age (years)", ylab = "Weight (kg)")
for ( i in 1:n_samples)
{
  lines( Aseq, alpha[i] + beta[i] * (Aseq - BarA),
         lwd = 3, col = 2
         )
}
# it seems I should enforce age 0 to weight 0 somehow

m_2_list <-  alist(
  W ~ dnorm(mu, sigma),
  mu <- alpha + beta * (A - BarA),
  alpha ~ dnorm(20, 4), # 20kg for 6 years old +/- 16 seems good after a quick online check
  beta ~ dlnorm(0, 1),  # here always a bit unsure but 1 seems a strong slope
  sigma ~ dunif(0, 10)  # I went with the same prior than adulte
)

                                        # step 3 training the model

m_2_youngs <- rethinking::quap(
                            m_2_list,
                            data = dat, debug = T
                          )

rethinking::precis(m_2_youngs)

                                        # step 4 explore the posterior
                                        # I used solution from 4H2
BarA <- mean(d_2$age)

post_m_2_youngs <- rethinking::extract.samples(m_2_youngs, 1e5)

mu <- sapply(Aseq, function(z) mean(post_m_2_youngs$alpha + post_m_2_youngs$beta * (z- BarA)))
mu_ci <- sapply(Aseq, function(z) rethinking::PI(post_m_2_youngs$alpha +
                                                 post_m_2_youngs$beta * (z - BarA),
                                                 prob = 0.89))
pred_ci <- sapply(Aseq, function(z) rethinking::PI(
                                                 rnorm(
                                                   1e5,
                                                   post_m_2_youngs$alpha + post_m_2_youngs$beta * (z - BarA),
                                                   post_m_2_youngs$sigma),
                                               prob = 0.89))
plot(d_2$age, d_2$weight, col = col.alpha("darkred", 0.5))
lines(Aseq, mu)
lines(Aseq, mu_ci[1, ], lty = 2)
lines(Aseq, mu_ci[2, ], lty = 2)
lines(Aseq, pred_ci[1, ], lty = 2)
lines(Aseq, pred_ci[2, ], lty = 2)

# I am still surprise by those numbers, a new born can be 7kg ?
# To summarize at the end, we have a mean of growth rate around 1.34kg/year (en moyenne).


                                        # 3 ============================================

str(d_2)
# I will keep the same key
# girls : 1, boys : 2

# step 1 data prep

dat <- list(
  W = d_2$weight,
  A = d_2$age,
  BarA = mean(d_2$age),
  S = d_2$male + 1
)

# step 2 model

m_2_Syoungs <- quap(
  alist(
    W ~ dnorm(mu, sigma),
    mu <- a[S],
    a[S] ~ dnorm(20, 4),
    sigma ~dunif(0, 10)
  ), data = dat
)

post_m2_SY <- rethinking::extract.samples(m_2_Syoungs, 1e5)

# checking where the mean is
summary(post_m2_SY$a) # 10-20 seems good

rethinking::dens( post_m2_SY$a[,1], xlim = c(10,20), lwd = 3, col = 2,
     xlab = "posterior mean weight (kg)") # Girls

rethinking::dens( post_m2_SY$a[,2], lwd = 3, col = 4, add = TRUE) # boys

# Boys tends to be heavier
set.seed(42)
W1 <- rnorm( 1000, post_m2_SY$a[, 1], post_m2_SY$sigma )
W2 <- rnorm( 1000, post_m2_SY$a[, 2], post_m2_SY$sigma )

dens( W1, xlim = c(0,35), ylim = c(0, 0.085), lwd = 3,
     col = 2, xlab = "posterior predicted weight (kg)")

dens(W2, lwd = 3, col = 4, add = TRUE)

mu_contrast <- post_m2_SY$a[, 2] - post_m2_SY$a[ ,1]

dens(mu_contrast, xlim = c(-2,6), lwd = 3, col = 1 ,
     xlab = "posterior mean weight contrast (kg)")
