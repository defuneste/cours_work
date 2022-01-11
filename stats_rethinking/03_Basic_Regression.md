# Basic regression

Lien vers la vidéo [ici](https://www.youtube.com/watch?v=zYYBtxHWE0A)

Les premiers astronomes devaient non seulement expliquer le phénomène mais aussi le prédire. 


Le modèle géocentrique est un très bon prédicateur sans comprendre le processus derrière. 

Geocentrisme:

- Bonne description  
- Faux mécaniquement  
- Méthode générique d'approximation  
- Connu pour être faux  

Analogie avec la régression linéaire:

- Bonne description  
- Faux mécaniquement  
- Méthode générique d'approximation  
- Pris trop au sérieux  

## Régression linéaire

Modèle à partir de la moyenne et la variance comme variable.

La moyenne comme somme pondérée des autres variables.

De nombreux cas particuliers: ANOVA, ANCOVA, t-test, MANOVA

Peux aussi être utilisé comme un modèle génératif. 

En fonction de supposés sur la moyenne et la variance la distribution normale peut nous aider à compter toutes les possibilités de chemins.

### Pourquoi Normal?

Deux idées:

1. Génératif: la somme de fluctuation tends vers une distribut

2. Statistique: Pour estimer la moyenne et la variance est la distribution la moins informative (ie on a juste besoin de ces deux paramètres)  


Pas besoin d'avoir des variables distribuées normalement pour que le modèle soit utile.
Pas besoin d'avoir des variables distribuées normalement pour que le modèle soit utile.

### Mise en place de modèles Gaussiens

besoin d'avoir des variables distribuées normalement pour que le modèle soit utile.

Objectif:

1. Langage pour représenter des modèles

2. Comment calculer des distributions à posteriori plus volumineuse

3. Construire et comprendre les modèle linéaires.

### Mise en place de modèles Gaussiens

besoin d'avoir des variables distribuées normalement pour que le modèle soit utile.

Objectif:

1. Langage pour représenter des modèles

2. Comment calculer des distributions à posteriori plus volumineuse

3. Construire et comprendre les modèle linéaires.

> c'est normal de faire des statistiques avant de les comprendre 

### Langage pour la modélisation 

#### Pour le lancer de globe:

$$ W \sim binomial(N, p) $$

$$ p \sim Uniforn(0, 1) $$

$W$ est le produit  
$\sim$ "est distribué"  
$Binomial$ est la distribution de la donnée  
$N$ : taille de l'échantillonnage  
$p$ : proportion de l'eau  

$p$ : paramètre à estimer  
$Uniform$ : distribution à priori (uniforme )

Il faut les organiser comme des probabilités

$$ Pr(W|N, p) = Binomial(W|N, p)$$  

$$ Pr(p) = Uniform(p | 0, 1) $$  

| conditional   

$$ Pr(p|W, N) = \alpha Binomial(W|N, p) * Uniform(p|0,1) $$  

#### Data: Life histories of the Dobe !Kung

``` R
library(rethinking)
data(Howell1)
```

1. Description entre le poids et la taille

On va juste prendre les adultes. 

2. modèle scientifique

H -> W 

Si on intervient sur la taille cela change le poids. Si on intervient sur le poids cela ne change pas la taille. 

$$ W = f(H) $$

Le poids est en fonction de la hauteur.

Ici on va utiliser un modèle statique de modèle génératif mais il en existe des dynamique. 

$$ y_{i} = \alpha + \beta x_{i} $$ 

$y_{i}$ : index, il y a plusieurs cas/instances de $y$

$\alpha$ : intercept

$\beta$ : la pente

Dans une régression linéaire, c'est n'est pas ou est la valeur exacte mais ou est sa moyenne.  

La régression linéaire nous indique ou est l'espérance de la valeur.   

$$ y_{i} \sim Normal(\mu_{i}, \theta)$$  

$$\mu_{i} = \alpha + \beta x_{i}$$

$\mu_{i}$ : expectation   

$\theta$ écart type  

> Each x value has a different expectation, $E(y|x) = \mu$

$$ W_{i} Normal(\mu_{i}, \theta) $$

$$ \mu_{i} = \alpha + \beta H_{i} $$

``` R
alpha <- 0 # un individu quit fait 0cm fait 0kg
beta <- 0.5
n_individuals <- 100

H <- runif(n_individuals, 130, 170)

mu <- alpha + beta * H

W <- rnorm(n_individuals, mu, sigma)

plot(H, W) # un graph de nos individus generés 

```




