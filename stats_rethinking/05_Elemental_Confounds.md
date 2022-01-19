# Elemental confounds

Lien vers la [vidéo](https://www.youtube.com/watch?v=UpP-_mBvECI)

Il y a tout pleins de corrélations. On doit aller plus loin.   

On va passer du temps sur les modèles scientifiques et comment ils nous aident à aller plus loin que la corrélation. 

Introduction au 4 éléments de facteurs de confusion:

- The Fork  
- The pipe  
- The Collider  
- The descendant  

## The fork

Z est le facteur de confusion:

X <- Z -> Y

X et Y sont associés 

$$ Y \not\!\perp\!\!\!\perp X $$

Il partage une explication commune Z

Une fois que l'on stratifie avec Z ils n'ont plus d'association.

$$ Y \perp\!\!\!\!\perp  X|Z $$

X et Y ne sont pas des copies identiques elles sont influencés par d'autres facteurs. 

Comme on stratifie avec Z on annule son "bruit".

### avec un exemple de code:

 ``` R
library("Rlab")
n <- 1000
Z <- rbern( n , 0.5)
X <- rbern( n , (1 - Z) * 0.1 + Z * 0.9)
Y <- rbern( n , (1 - Z) * 0.1 + Z * 0.9  )
table(X,Y)

cor(X,Y)
 ```

### un exemple de Fork

Les régions des US qui ont des taux de mariage plus élevées sont celles avec des taux de divorce plus élevées.

estimand: Effet du taux de mariage sur le taux de divorce

M -> D

On va prendre en compte l'âge du mariage: état ou les gens se marient tardivement divorce moins.

L'âge peut influencer le taux de divorce et le taux de mariage.  

Est il un facteur de confusion ? 

M -> D (?)
A -> D (?)
A -> M 

Casser la fork nécessite de stratifier par A.

Dans un regression linéaire: 
On ajoute le facteur de confusion.

$$ D \sim Normal(\mu_{i}, \sigma) $$  

$$ \mu_{i} = \alpha + \beta_{M}M_{i} + \beta_{A}A_{i} $$  

Chaque valeur de A doit produire différentes relation entre D et M:

$$ \u_{i} = (\alpha + \beta_{A}A_{i}) + \beta_{M}M_{i} $$

l'intercept est conditional on Age of mariage.

### Statistical Fork

On a la structure il faut des a priori.

Dans ce cas on va standardiser les variables. C'est une bonne pratique.

On retire la moyenne et on divise par son écart type. 

0 est donc la moyenne et 1 un écart type, 2 deux écart type

Raison de le faire: 

1. cela facilite le calcul informatique  
2. c'est plus simple de choisir de bon a priori à partir de données standardisées

#### On va commencer avec des prior predictive simulation 

``` R
n <- 20
a <- rnorm(n , 0, 0.2) # on a commencer avec 10
bM <- rnorm(n , 0, 0.5) # on a commencer avec 10
bA <- rnorm(n, 0, 0.5) # on a commencer avec 10
plot(NULL, xlim = c(-2,2), ylim =c(-2,2) ,
xlab = "Median age of marriage (standardized)",
ylab = "Divorce rate (standardized)")
Aseq <- seq(from = -3, to = 3, len = 30)
for ( i in 1:n) {
  mu <- a[i] + bA[i] * Aseq
  lines( Aseq , mu , lwd = 2, col = 2 )
}
```

Le prior pour la pente est immense. On peut les corriger.

#### Analyze data

``` R

library(rethinking)
data(WaffleDivorce)
d <- WaffleDivorce
dat <- list(
  D = rethinking::standardize(d$Divorce),
  M = rethinking::standardize(d$Marriage),
  A = rethinking::standardize(d$MedianAgeMarriage)
)

m_DMA <- quap(
  alist(
    D ~ dnorm(mu, sigma),
    mu <- a + bM * M + bA * A,
    a ~ dnorm(0, 0.2),
    bM ~ dnorm(0, 0.5),
    bA ~ dnorm(0, 0.5),
    sigma ~ dexp(1) # signifie qu'un déplacement de 1 correspond à un sd
  ), data = dat
)

plot(rethinking::precis(m_DMA))

```


## The Pipe


