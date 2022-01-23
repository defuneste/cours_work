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

``` R
library("dagitty")

fork <- dagitty("dag{ X <- Z ;
                      Z -> Y}")
dagitty::coordinates(fork) <- list(x = c(X = 0, Z = 1, Y =2),
                                   y = c(X = 0, Z = 0, Y =0))

jpeg("fork.jpeg", width = 240, height = 60)
plot(fork)
dev.off()

```



X et Y sont associés 

$$ Y \not\!\perp\!\!\!\perp X $$

Il partage une explication commune Z

Une fois que l'on stratifie avec Z ils n'ont plus d'association.

$$ Y \perp\!\!\!\!\perp  X|Z $$

X et Y ne sont pas des copies identiques elles sont influencés par d'autres facteurs. 

Comme on stratifie avec Z on annule son "bruit".

### Avec un exemple de code:

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

X et Y sont associés 

$$ Y \not\!\perp\!\!\!\perp X $$

Influence de X est transmisse à Y en passant par Z 

Une fois stratifié par Z il n'y a plus d'association 

$$ Y \perp\!\!\!\!\perp  X|Z $$

Il est statistiquement proche de Fork mais conceptuellement très différent.

``` R

library("Rlab")
n <- 1000
X <- rbern(n , 0.5)
Z <- rbern(n , (1 - X) * 0.1 + X * 0.9 )
Y <- rbern(n , (1 - Z) * 0.1 + Z * 0.9 )

table(X, Y)
cor(X, Y)


```

### Un exemple de Pipe

Il y a 100 plantes qui sont attaqués par un champignon. Une partie est traité par un antifongique et pas l'autre. 

On mesure la croissance et les champignons 

On cherche à estimer l'effet du traitement sur la croissance des plantes.

Fungus -> hauteur t 1 <- hauteur t 0

Le traitement a un effet sur fungus et sur la hauteur (en + ou -)

Le chemin de T est à deux niveau.

Ici si on stratifie avec F on bloque un chemin.  

(besoin de lire page 170-175)

Cela s'appelle *post-treatment bias*


## The Collider

X -> Z <- Y

Un peu l'opposé du fork

X et Y ne sont pas associés 

$$ Y \perp\!\!\!\!\perp  X|Z $$

X et Y ont une influence sur Z

Une fois stratifié Z, X et Y sont associés

$$ X \not\!\perp\!\!\!\perp X|Z $$

Quand on apprend sur Z on apprend forcément sur X et Y.

``` R

n <-1000
X <- rbern(n , 0.5)
Y <- rbern(n , 0.5)
Z <- rbern(n, ifelse(X+Y > 0, 0.9, 0.2) )

table(X, Y)
cor(X, Y)

```

Apprendre sur le collider aide à apprendre sur les combinaissons de correlation entre X et Y existantes.

Si on ajoute un collider dans un modèle on ajoute un facteur de confusion (en pensant tenir compte d'un facteur de confusion).

#### Un exemple de Collider 

Suppose 200 demandes de financement (exemple dans chapitre 6)

Il y a deux notations une sur la nouveauté (N) et une sur leur crédibilité (T). 

Ensuite l'agence de financement sélectionne celle qui ont le plus haut scores (en fonction de l'addition des deux). Il y alors une corrélation négative entre les deux notations.

C'est un biais (collider) lié  à la sélection des données.

A: financement est accordé ou pas 

N -> A <- T

Comme peux de demandes sont hautes dans N et T cela donne une corrélation négative. 

Un autre exemple : les restaurants ils peuvent se maintenir car ils ont un bon emplacement et/ou faire de la bonne nourriture. -> mauvaise nourriture dans les bons emplacements 

cf. p 176.177

Il y a deux moyens d'être marié dams le modèle soit on vie assez longtemps et on finit par se marier soit on est heureux et donc on se marrie plus jeunes.

## The descendant

Un descendant agit en fonction de quoi il est attaché.

Ici on prend un Pipe avec un descendant 

X -> Z -> Y
     | 
     A
     
X et Y sont associés à travers Z

A détient de l'info de Z

Une fois stratifié par Z, X et Y sont moins associés.

``` R

n <- 1000
X <- rbern(n , 0.5)
Z <- rbern(n , (1 - X) * 0.1 + X * 0.9)
Y <- rbern(n , (1 - Z) * 0.1 + Z * 0.9)
A <- rbern(n , (1 - Z) * 0.1 + Z * 0.9)

table(X, Y)
cor(X, Y)

```

Les descendants sont partouts car beaucoup de mesure que l'on prend sont des proxies de ce que l'on cherche a mesurer. 

Les solutions: *factor analysis*, *measurement error*, social networks

un exemple 

B <- U -> A

U -> X
     |
U -> Y


## Facteur de confusion non observé

Il y a un effet non mesuré (U) entre les parents et enfants. (ex. le quartier)

un exemple les parents sur les enfants et les grands parents sur les parents et les enfants.

G -> P <- U
|     |
|___> C <- U

On est intéressé par l effet G -> C que se passe t il quand on conditionne sur P.

Que se passe t il ? 

