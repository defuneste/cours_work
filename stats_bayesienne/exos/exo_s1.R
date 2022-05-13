# penser à commencer le plot à 0
# il faut utiliser curve


# question 2
hist(rbinom(10000,
            prob = probal,
            size = 100))

# pnorm/pbinom pour 0.55
# question 3

ne <- c(10,50,100,300)

hist(rbinom(10000,
       prob = probal,
       size = ne[4]))


### Question 3:

# Elle s'affine, puis se resert.

### Question 4

# Sensibilité (positif sachant que malade): 0.8
# Spécificité (négatif sachant que pas malade): 0.97

# M: malade Mbar: pas malade
# T: test postifif Tbar: T negatif

# P(T|M) = sensibilité

# ce que l'on cherche P(T)


#
# PdeT <-



# Partie 2

# 50 steack, 0.1g

#  R

d <- read.table("seance1/datacoli.txt", header = TRUE)
(N <- d$Ncol)

hist(N, breaks = seq(0,max(N), 1), xlab = "nombre de colonies bactériennes",
main = "Distribution observée sur les 50 échantillons")


# Question 7

# Loi de Poisson.

# On peut l'approcher par une Normale


theta <- mean(d$Ncol)

v <- var(d$Ncol)

hist(rpois(0:50,
      lambda = theta))

# Question 8

# Le modèle est très loin des données

# Question 9

# cf les reponses.


# Question 10

alpha <- (theta*theta)/(v - theta)

vi <- rgamma(50,
             shape = alpha,
             rate = alpha)

Ni <- rpois(50, vi*theta)
hist(Ni)



# il faudrait faire des tas de simulations et produire les statitiques utiles de comparaisons. On peut utiliser `replicate`.
