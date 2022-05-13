<!-- Formation stats bayesienne organisée par le LBBE 
 https://lbbe.univ-lyon1.fr/fr/formation-statistique-bayesienne
 Mai 2022
 Prise de Note Olivier Leroy
 -->

# seance 2

Nicolas Lartillot 05-04-2021

Semaine dernière simulation probabiliste, permet de comparer les sorties du modèle aux données observées. 


Il existe d'autre facon d'ameliorer les paramètres du modèle. Pour cela dans ce cours on va utiliser l'inférence bayesienne.

## Cas discret

On prend le cas de diagnostique de la séance 1. 

sensibilité: 0,8
spécificité: 0,97 (faux positif de 3%)

prévalence de la maladie: 0.01 

probabilité que je sois malade sachant que le test est negative. C'est le théoreme d'inversion et ou de Bayes. 


On va passer par la simulation pour le démontrer. 

On commence par tirer la maladie puis dessus on tire le résultats du test.

Jcourbe suis positif qu'elle est la probabilité que je sois malade.

$$ P(+) = P(s)P(+|s) + P(h)P(+|h) $$

$$ P(+) = 0.008 + 0. 0297 = 0.0377 $$

La contribution de ceux qui ne sont pas malade au résultat total est plus faible que ceux qui ne sont pas malade. 

Donc: 

$$ $P(s|+) = \frac{P(s)P(+|S)}{P(+)} $$


on a 80% de chance que je sois pas malade si le test est positif.

On peut donc "tester" les effets de ses priors.

## Cas continua

2 allèles locus 0 |  1 

on obtient sur 5 tirages trois 1. 

On va utiliser une binomiale.

likelihood = fonction de vraisemblance

On va simuler avec une prior. Le premier cas on a 0 idée. 

On va tirer x dans une distribution uniforme (0, 1)


Les courbes en rouge sont l'histogrammee renormalisé.

l'aire de la courbe de 3 = c'est la fraction de toute les simulations ou k = 3. 

C'est un échantillonnage par rejet.

L'aire relatif entre la cloche et la courbe plate est la denominateur de Bayes. 

On est pas obligé de normaliser.

$\alpha$ = proportionelle

On a un prior : $p(x) \alpha 1$ (on peut avoir un plus informatif cf slide choice of prior) 

likelihood <- a reprendre du cours.

On a une connaissance qui vient de la génétique. 


On peut tirer dans les distribution garder pour avoir par exemple un interval de crédibilité.

# TP

``` R

# observed data
nobs <- 10
kobs <- 6
# number of samples we want to generate
M <- 10000
# initialize counter for total number of draws
count_draw <- 0
# initiale counter for number of accepted draws
count_accept <- 0
# we will store the accepted draws in a vector (of size M)
post <- numeric(length = M)

un_run <- runif(M)

ce_que_l_on_garde <- un_run[un_run > kobs / nobs]

hist(ce_que_l_on_garde)


k <- rbinom(
  prob = ce_que_l_on_garde,
  n = 10000,
  size = nobs
)


                                        # do a while loop
while (count_accept < M)
{
  count_draw <- count_draw + 1
un_runif <- runif(1)
  k <- rbinom(prob = un_runif,
              size = 10,
              n = 1)
  if(k == kobs) {
    count_accept <- count_accept + 1
    post[count_accept] <- un_runif  
  }         
}

```


question 3

``` R

M / count_draw

```

question autre

``` R

count_accept <- 0
count_draw <- 0

while (count_accept < M)
{
  count_draw <- count_draw + 1
un_runif <- runif(1)
  k <- rbinom(prob = un_runif,
              size = 20,
              n = 1)
  if(k == 12) {
    count_accept <- count_accept + 1
    post[count_accept] <- un_runif  
  }         
}


dbinom(x = 6,
       size = 10,
       prob = 0.6)

```


ici on a modifié c'est le nombre d'allèle mais pas la frequence et du coup la probabilité d'avoir un tirage uniforme qui correspond est plus faible.


question 4 a verifier



``` R

count_accept <- 0
count_draw <- 0

while (count_accept < M)
{
  count_draw <- count_draw + 1
un_runif <- rbeta(0.01, 0,01)
  k <- rbinom(prob = un_runif,
              size = 20,
              n = 1)
  if(k == 12) {
    count_accept <- count_accept + 1
    post[count_accept] <- un_runif  
  }         
}


dbinom(x = 6,
       size = 10,
       prob = 0.6)

```

Le taux d'acceptation dans le "generatif model" est celui du dénominateur de Bayes.  


TODO suite tester l'interval de crédibilité. 

Autre approche du bayesien : ABC (TODO regarder ce que c'est). On va se donner une marge dans l'acceptation du paramètre.  


# Peut on ameliorer le nombre de rejet que l'on avec le rejection sampling

cas des MCMC, on ne va pas faire le tirage aveuglement. 

A chaque étape on va tirer une valeur pas trop loin de celle ou on est (dans un distribution gaussienne). Il faut faire attention sur les bords à ne pas sortir.

Il nous manque une facon de les rejeter / accepter. 

xt_star est un petit mouvement 

TODO verifier a=min(1,r)

On va tirer un bernouilli avec proba de a 

Avoir un taux d'acceptation autour de 30% c'est pas mal

beta
binomiale


faire un fonction qui va cibler le post 

``` R
 
# parameter of the beta prior
theta <- 0.1
# observed data
n <- 1000
kobs <- 600
# function returning the log of the posterior density for x
logpost <- function(x)
{
(kobs + theta - 1) * log(x) + (n - kobs + theta - 1) * log( 1- x)
}
# tunning parameter of the Metropolis Hastings move
delta <- 0.1
# length of the MCMC sample
M <- 10000
# mcmc will be stored in a vector of size M
mcmc <- numeric(length = M)
# initialize counter for total number of accepted moves
count_accept <- 0
# draw initial value for x
x <- runif(n = 1, min = 0, max = 1)
for (i in 1:M) {
# propose new value xstar close to x (normally distributed around x, of standard deviation delta)
  xstar <- rnorm(1, mean = x, sd = 0.1)
  if(xstar < 0 | xstar > 1 ){
    r = exp(logpost(xstar) - logpost(x))
    
  } else {

  }
                                        
  
# check whether xstar is in the (0,1) interval
# if yes:
# compute log of the ratio of posterior probabilities before and after the move
# WRITE SOME CODE HERE
}


```


