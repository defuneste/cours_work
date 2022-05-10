# s1

## processus de Bernoulli

un seul tirage bernoulli plusieurs tirage binomial. Plus le nombre est grand elle tend vers Poisson. Puis Poisson tends vers Normal. 

Loi géométrique ? sa généralisation est la négative binomiale. 

succes pour un tirages (reprendre diapo!!)

La binomiale on a un dénominateur. 

## processus de Poisson

ici pour des mesures sur volumes. 

reprendre la definition de la diapo. 

La loi exponentielle est associé à celle de Poisson. Unité de temps/surface necessaire pour avoir une evt.

Loi gamma le second paramètre est pas toujours implementé de la meme manière entre R et Jags. 

si sur dispersion on passe en negative binomiale (cas ou variance > moyenne). 

C'est un melange de loi de poisson et de gamma.


La loi norma; est de - inf à + inf. CE qui veut dire que l'on va tronquer des loi pour des raisons logiques.  

Lognomarl: moyenne et ecart type en log neperien. 

Distribution de student

Plus souple que la loi normal, plus de poids au queue de distribution, definit par des degrés de liberté. Si degré = 1 loi de Cauchy. Elle est utilisé pour avoir des valeurs extrèmes loin du centre de la distribution

Loi Beta definit sur 0 / 1 => utile pour des probabilité ou des taux. La loi de Beta(1,1) est une uniforme. (il y a deux paramètres $\alpha$ et $\beta$).

support de la loi ? (domaine de definition) 

# Exo

``` R

ne <- 100
probal = 0.717

# question 1
dbinom(0:100, # cas ou on a de 0 malade à 100 
       prob = probal,
       size = ne)
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

```

### Question 3:

Elle s'affine, puis se resert.

### Question 4

Sensibilité (positif sachant que malade): 0.8
Spécificité (négatif sachant que pas malade): 0.97

M: malade Mbar: pas malade
T: test postifif Tbar: T negatif 

P(T|M) = sensibilité 

ce que l'on cherche P(T)


``` R
PdeT <- 


```

# Partie 2

50 steack, 0.1g  

``` R 

d <- read.table("seance1/datacoli.txt", header = TRUE)
(N <- d$Ncol)

hist(N, breaks = seq(0,max(N), 1), xlab = "nombre de colonies bactériennes",
main = "Distribution observée sur les 50 échantillons")
```

Question 7 

Loi de Poisson. 

On peut l'approcher par une Normale

``` R
theta <- mean(d$Ncol)

v <- var(d$Ncol)

hist(rpois(0:50,
      lambda = theta))

```

Question 8 

Le modèle est très loin des données

Question 9

cf les reponses.


Question 10

``` R

alpha <- (theta*theta)/(v - theta)
  
vi <- rgamma(50,
             shape = alpha,
             rate = alpha) 

Ni <- rpois(50, vi*theta)
hist(Ni)

```

il faudrait faire des tas de simulations et produire les statitiques utiles de comparaisons. On peut utiliser `replicate`. 

