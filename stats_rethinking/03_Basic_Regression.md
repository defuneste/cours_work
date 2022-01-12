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

$$ y_{i} \sim Normal(\mu_{i}, \sigma)$$  

$$\mu_{i} = \alpha + \beta x_{i}$$

$\mu_{i}$ : expectation   

$\theta$ écart type  

> Each x value has a different expectation, $E(y|x) = \mu$

$$ W_{i} Normal(\mu_{i}, \sigma) $$

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

3. modèle statistique

On ne connaît pas alpha, beta, sigma. On a besoin d'à priori. 

$$ \alpha \sim Normal(0,1) $$

$$ \beta \sim Normal(0,1) $$

$$ \theta \sim Uniform(0,1) $$

Sigma est uniforme car l'écart type est toujours positif. On des paramètres comme sigma qui sont dit *scale parameters*. Ils sont toujours positifs.    

Il est important de simuler à partir des distributions à priori pour comprendre ce qu'elles impliques. 

``` R
n_samples <- 10
 
alpha <- rnorm(n_samples, 0, 1)
beta <- rnorm(n_samples, 0, 1)


plot(NULL, xlim = c(-2,2), ylim = c(-2,2), xkab = "x", ylab = "y")
for ( i in 1:n_samples )
{
abline(alpha[i], beta[i], lwd = 3, col = 2) #abline prend une pente et un intercept
}

```

La structure du modèle statistique est similaire au modèle génératif mais il est important de : 

1. remettre à échelle les variables

2. bien penser les à priori

#### Remettre à échelle : re-scaling


On va recentrer la hauteur pour que le valeur d'alpha est l'espérance du poids d'un individus quand il est de taille moyenne. 

$$ \mu_{i} = \alpha + \beta(H_{i} - \hat{H}  ) $$

Dans ce cas alpha prend la valeur de mu quand $H_{i} - \hat{H} = 0$ 

#### Prior plus vraisemblable

un rapide tour sur wiki pour connaître le poids moyen d'adulte en Afrique.

-> $ \alpha \sim Normal(60, 10)$

Pour Beta, la pente, elle a du sens en fonction de sa fonction. Ici ce sont des kgs/cm  : 

$$ \beta \sim Normal(0, 10) $$

10 sur l écart type donne 100 de variance (cela fait des gens très grand et très petit).

``` R
n <- 10
alpha <- rnorm(n , 60, 10)
beta <- rnorm(n, 0, 10)

Hbar <- 150
Hseq <- seq(from = 130, to = 170, len = 30)
plot(NULL, xlim = c(130, 170), ylim = c(10,100),
     xlab = "Height (cm)", ylab = "weight (kg)")
for ( i in 1:n)
{
  lines( Hseq, alpha[i] + beta[i] * (Hseq -Hbar),
         lwd = 3, col = 2
         )
  }
```

Pas fou. On ne devrait pas avoir de pente négative. Pour cela on va prendre une distribution log normales. C'est une distribution si on en prend le log la distribution devrait être normale. 

``` R
n <- 10
alpha <- rnorm(n , 60, 10)
beta <- rlnorm(n, 0, 1) # chgt ici 

Hbar <- 150
Hseq <- seq(from = 130, to = 170, len = 30)
plot(NULL, xlim = c(130, 170), ylim = c(10,100),
     xlab = "Height (cm)", ylab = "weight (kg)")
for ( i in 1:n)
{
  lines( Hseq, alpha[i] + beta[i] * (Hseq -Hbar),
         lwd = 3, col = 2
         )
  }
```

Faire des priors est compliqué, il faut les justifier en prenant une info en dehors des données.  

Il faut justifier la structure du modèle avec des infos autre que celle contenu dans l'échantillon. Sinon on va avoir un tas de faux positifs. 

##### Ajuster le modèle 

$$ Pr(W_{i}|\mu_{i}, \sigma) $$

$$ Pr(\alpha) $$

$$ Pr(\beta) $$

$$ Pr(\sigma) $$

Posterior : $$ Pr(\alpha, \beta, \sigma | W, H) $$

Ce que le modèle apprend est la combinaison des trois. 

Rien que si l'on prend 100 valeurs pour chaque paramètres cela fait 1 millions (produit de 4 $Pr$).

On peut le faire avec une approximation par grille mais c'est lourd.

On va utiliser une **approximation Gaussienne** ou **quadratic** ou **laplace**.

C'est une méthode qui impose une un espace continu mais suivant une forme gaussienne.

4. Validation du modèle / Analyse des données

``` R
library(rethinking)
data(Howell1)
d <- Howell1[Howell1$age >= 18,]
```

C'est toujours bon de tester et de simuler. 

Il faut regarder *Simulation-Based Calibration*. 

``` R
# on commence par simuler de données 
alpha <- 70
beta <- 0.5
sigma <- 5
n_individuals <- 100
H <- runif(n_individuals, 130, 170)
mu <- alpha + beta*(H-mean(H))
W <- rnorm(n_individuals, mu, sigma)

dat <- list(H = H, W = W, Hbar = mean(H)) # une list des données dont on a besoin 

m_validate <- quap(

  alist(
    W ~ dnorm(mu, sigma),
    mu <- a + b*(H-Hbar),
    a ~ dnorm(60, 10),
    b ~ dlnorm(0, 1),
    sigma ~ dunif(0,10)
), data = dat)

precis(m_validate)

```

Pour tester plus en détail il est bon de faire tourner ce test sur plusieurs jeux de données simulées.

Avec les données réelles: 

``` R
dat <- list(
  W = d$weight,
  H = d$height,
  Hbar = mean(d$height)
) 

m_adults <- quap(

  alist(
    W ~ dnorm(mu, sigma),
    mu <- a + b*(H-Hbar),
    a ~ dnorm(60, 10),
    b ~ dlnorm(0, 1),
    sigma ~ dunif(0,10)
), data = dat)

precis(m_adults)

```

**Première Loi de l'interprétation statistique** :

Les paramètres ne sont pas independants entre eux et ne peuvent pas toujours être interpréter indépendamment. 

Pour l'interprétation il est sage de tirer des échantillons de la distribution posterieurs.

##### Utilisation de la distribution posterieur

1. Plot l'échantillon !

2. Plot la moyenne du posterieur 

3. Plot l'incertitude de la moyenne 

4. Plot l'incertitude des prédictions (intégrer sigma)

(cf. code 4.4.3 p98)

Les statistiques sont un peu comme des thermomètres, on part d'une question simple et on doit mettre en place beaucoup de calculs pour y répondre. 


