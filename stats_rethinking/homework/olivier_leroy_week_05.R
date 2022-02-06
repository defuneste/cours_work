# Date Februray 2022
# Olivier Leroy
# Homework week 5 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week05.pdf

library(rethinking)

data(NWOGrants)
d <- NWOGrants
str(d)

dat <- list(
  A = d$awards,
  N = d$applications,
  G = ifelse(d$gender == "f", 1 ,2),
  D = as.integer(d$discipline)
)


                                        # 1
library("dagitty")

dag_NWOgrant <-dagitty("dag{
Gender -> Awards
Gender -> Discipline
Discipline -> Awards
}")

plot(dag_NWOgrant)


mG <- ulam(
  alist(
    A ~ binomial(N, p),
    logit(p) <- a[G],
    a[G] ~ normal(0,1)
  ), data = dat, chains = 4, cores = 4
)
precis(mG, depth = 2)

traceplot(mG)

post1 <- extract.samples(mG)
PrA_G1 <- inv_logit(post1$a[,1])
PrA_G2 <- inv_logit(post1$a[, 2])
diff_prob <- PrA_G1  - PrA_G2
dens(diff_prob, lwd = 4, col = 2, xlab = "Gender contrast (probability)")
abline(v = 0, lty = 2)

                                        # 2
                                        # I need to take into account Applications and Discipline



mG_D <- ulam(
  alist(
    A ~ binomial(N, p),
    logit(p) <- a[G, D],
    matrix[G, D]:a ~ normal(0, 1)
    ), data = dat, chains = 4, cores = 4
  )

precis(mG_D, depth = 3)

traceplot(mG_D)

post2 <- extract.samples(mG_D)
PrA <- inv_logit( post2$a )
diff_prob_D <- sapply( 1:9, function(i) PrA[ ,1 , i] - PrA[ ,2 , i])

plot(NULL, xlim = c(-0.3,0.3), ylim = c(0, 25), xlab = "Gender contrast (probability)",
     ylab = "Density")
for( i in 1:9 ) dens( diff_prob_D[,i], lwd = 4, col = 1 + i, add = TRUE)
abline(v = 0, lty = 2)
legend("topleft",
       legend = levels(d$discipline),
       col = 2:10,
       lty = 1,
       lwd = 3)

                                        # Marginalize

total_apps <- sum(dat$N)
nb_discipline <- length(levels(d$discipline))
apps_per_disc <- sapply ( 1:nb_discipline,
                         function(i) sum(dat$N[dat$D == i]))

p_G1 <- link(mG_D, data = list(
                      D = rep(1:nb_discipline, times = apps_per_disc),
                      N = rep(1, total_apps),
                      G = rep(1, total_apps)
                    ))
p_G2 <- link(mG_D, data = list(
                      D = rep(1:nb_discipline, times = apps_per_disc),
                      N = rep(1, total_apps),
                      G = rep(2, total_apps)
                   ))

dens( p_G1 - p_G2, lwd = 4, col = 2, xlab = "effect of gender perception")

w <- xtabs( dat$N ~ dat$D) /sum(dat$N)

plot(NULL, xlim = c(-0.3, 0.3), ylim = c(0, 20),
     xlab = "Gender contrast (probability)", ylab = "Density")
for (i in 1:nb_discipline) dens( diff_prob_D[, i],
                                lwd= 2 + 20 * w[i], col= 1 + i, add = TRUE)
abline(v = 0, lty =  3)
