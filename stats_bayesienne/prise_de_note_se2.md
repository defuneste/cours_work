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


