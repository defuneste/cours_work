# Multilevel models

Il y a une variation forte entre stories et participants. 

On peut reprendre la technique précédente. Le défaut de cette approche est que le modèle n'apprend pas du passé. 

## Models with memory

Les modèles multi niveaux sont des modèles dans les modèles:

1. un modèle pour les groupes/individus observés

2. un modèle pour la population des groupes/individus

Cela permet de créer une sorte de mémoire. On des attentes et avoir des attentes permet d'apprendre plus vite. 

Des modèles avec mémoires apprennent mieux et plus vite. Ils résistent mieux à l'overfitting.

## Coffee Golem

On construit un golem qui va chercher des cafés dans différents coin de Pragues. Il va compter combien de temps pour avoir un café.

On a une distribution sur le temps d'avoir un café et une distribution sur le temps d'avoir un café dans le café alpha.

Le golem commande un café et cela update les deux distributions. 

Il va ensuite dans café beta. Il utilise sa mémoire de café alpha. Cela prend du temps. On va updater la distribution des café de beta mais aussi d'alpha (il révise son idée d'alpha). Il utilise la distribution de café comme un prior avant d'entrer dans un nouveau café. 

### Regularization

L'autre raison est que ce type de modèle *adaptively regularize*.

*complete pooling* : tous les clusters sont identiques -> underfitting

*No pooling* : c'est comme si les groupes n était pas lier. Une visite dans beta ne prend pas en compte les visite passé dans ce meme café.

*partial pooling* : adaptive compromise

On va utiliser "Reedfrogs in peril".

48 groups of tapoles.(tank)

Traitements: densité, taille, prédation (on les protégeait ou pas)

outcome : survival

Tank peut aussi jouer. (TODO refaire le DAG)

On va commencer par un modèle sans mémoire. 

$$ S_{i} \sim Binomial(D_{i}, P_{i}) $$ 

$$ logit(p_{i}) = \alpha_{T[i]} $$

(T est pour tanks)

$$ alpha_{j} \sim Normal(\bar{\alpha}, \sigma ) $$

on peut utiliser CV pour savoir quel sigma utiliser (PSIS par exemple).

(TODO: reprendre cela)

Peut on automatiser la recherche de sigma ?

La réponse à cette question on peut: on va modifier un peu l'expression plus haut pour apprendre sigma.

$$ S_{i} \sim Binomial(D_{i}, P_{i}) $$ 

$$ logit(p_{i}) = \alpha_{T[i]} $$

$$ \alpha_{j} \sim Normal(\bar(\alpha), sigma) $$

$$ \bar(\alpha) \sim Normal(0, 1.5) $$

$$ \sigma Exponential(1) $$

On a un paramètre $\alpha_{j}$ qui depend de l'apprentissage de deux autres paramètres ($\bar(\alpha)$ et $\sigma$). Ce sont des **hyper paramètres**.

``` R
library(rethinking) 
data(reedfrogs)
d <- reedfrogs 
d$tank <- 1:nrow(d)
dat <- list(
    S = d$surv,
    D = d$density,
    T = d$tank )

mST <- ulam( 
    alist(
        S ~ dbinom( D , p ) ,
        logit(p) <- a[T] ,
        a[T] ~ dnorm( a_bar , sigma ) , 
        a_bar ~ dnorm( 0 , 1.5 ) ,
        sigma ~ dexp( 1 )
    ), data=dat , chains=4 , log_lik=TRUE )

```

a_bar et sigma décrivent la population. On peut observer que le modèle multilevel identifie le même interval pour sigma que notre exercice de CV. 

Pour l'exercice on va aussi utiliser un modèle sans mémoire:

``` R
mSTnomem <- ulam( 
    alist(
        S ~ dbinom( D , p ) ,
        logit(p) <- a[T] ,
        a[T] ~ dnorm( a_bar , 1 ) , 
        a_bar ~ dnorm( 0 , 1.5 )
    ), data=dat , chains=4 , log_lik=TRUE ) # log_lik est utile pour la comparaison de modèle 

compare( mST , mSTnomem , func=WAIC )

```


Même si mST à plus de paramètre (un de plus), il a moins de paramètre effectif. Parfois ajouter des paramètres peut réduire le risque d'overfitting. Ce qui est important est la structure pas le nombre. 

On a plus d'info dans les tanks avec bcp de têtards donc le modèle apprend plus dessus et "biaisé" vis à vis de ceux où ils sont moins nombreux. 

### stratification par prédateurs

$$ S_{i} \sim Binomial(D_{i}, P_{i}) $$ 

$$ logit(p_{i}) = \alpha_{T[i]} + \beta_{p}P_{i} $$

$$ \beta_{p} \sim Normal(0, 0.5) $$

$$ \alpha_{j} \sim Normal(\bar(\alpha), sigma) $$

$$ \bar(\alpha) \sim Normal(0, 1.5) $$

$$ \sigma Exponential(1) $$

``` R
dat$P <- ifelse(d$pred=="pred",1,0)
mSTP <- ulam( 
    alist(
        S ~ dbinom( D , p ) ,
        logit(p) <- a[T] + bP*P ,
        bP ~ dnorm( 0 , 0.5 ),
        a[T] ~ dnorm( a_bar , sigma ) , 
        a_bar ~ dnorm( 0 , 1.5 ) ,
        sigma ~ dexp( 1 )
    ), data=dat , chains=4 , log_lik=TRUE )

post <- extract.samples(mSTP)
dens( post$bP , lwd=4 , col=2 , xlab="bP (effect of predators)" )
```

On a des sigma très différent entre avec ou sans prédateurs.

C'est une bonne pratique de commencer un modèle multiniveaux sans les effets qui nous intéressent juste pour tester les effets de ce qu'apportent les différents niveaux.

Les modèles multiniveaux utilisent les données plus efficacement en indiquant par exemple qu'il y a une différence entre les cafés et non pas que les cafés soient tous les mêmes. 

On peut les appelées les *varying effect* : les unités dans le partial pooling

(size est la taille des tétards)


### Superstitions dans les Varying effect

1. *Units must be sampled at random* : faux 

On apprends toujours mieux même si c'est pas random. 

2. *number of units must be large* : faux, pe as on non bayesien. On peut faire un partial pooling avec un seul cas (cf café golem)

3. *Assumes Gaussina variation* : faux, c'est le prior que l'on assigne des résidus gaussien (cf revoir lecture 10 sur UCLA), le prior est juste un prior le posterieur peut prendre une autre forme.



