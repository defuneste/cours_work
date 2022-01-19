# Catégories, courbes & splines

Lien vers la [vidéo](https://www.youtube.com/watch?v=UtLb_YJcUcU)

## Catégories

Comment gérer des causes de phénomènes qui ne sont pas continus ?

Les catégories peuvent être discrètes et non ordonnées.

On peut vouloir stratifier par catégories: caler une ligne pour chaque catégories.

***Objectif**: modéliser l'influence de l'âge et sexe sur le poids.

La science d'abord: comment la taille (hauteur), le poids et le sexe sont reliés ? 

Puis comment la taille (hauteur), le poids et le sexe sont statistiquement reliés ?

Ils sont tout les trois associées. On va faire un DAG. Il faut se rappeler que les causes ne sont pas dans les donnée mais sont reflètes pas les données.

$$ (1) H \rightarrow W$$  

$$ (2) H \leftarrow W$$  

Ces deux DAG produisent les mêmes données. On sait cependant que changer le poids ne va pas changer la taille. Seul (1) est valide. 

Idem pour: 

$$ (3) H \rightarrow S$$  

$$ (4) H \leftarrow S  $$  

La taille n'influence pas le sexe (uhuh). Pareil pour le poids.

Le sexe influence la taille et le poids, la taille influence le poids.

$$ H = f_{H}(S) $$  

$$ W = f_{W}(H, S) $$  

Si on doit considérer l'effet directe  du sexe sur le poids il faut tenir compte de l'effet de la hauteur sur le poids. 

On peut distinguer l'effet de S sur W de l'effet direct de S sur W.

### Dessiner un hibou en catégories

1. on peut utiliser des variables "*dummy*" ou des variables indicatrices (0/1)

2. on peut utiliser des *index variables*: 1,2,3,4 ..

On va prendre la seconde option: plus simple pour augmenter le nombre de catégories, changer le code, spécifier des à priori, facilite la transition vers des modèle multi level.  

| Categorie   | Cyan | Magenta | Yellow | Black |
|:-----------:|:----:|:-------:|:------:|:-----:|
| Index value | 1    | 2       | 3      | 4     |

$$ \alpha = [\alpha_{1}, \alpha_{2}, \alpha_{3}, \alpha_{4}] $$

alpha est un vecteur de paramètres que l'on va chercher à estimer.

$$ y_{i} \sim Normal(\mu_{i}, \sigma) $$  

$$ \mu_{i} = \alpha_{color[i]} $$  

On repasse au poids/taille :

$$ W_{i} \sim Normal(\mu_{i}, \sigma) $$  

$$ \mu_{i} = \alpha_{S[i]} $$  

Alpha est toujours nommer l'intercept (ordonnée à l'origine). 

On a deux ordonnée à l'origine:

$$ \alpha = [\alpha_{1}, \alpha_{2}] $$  

Si on prend 1: femme et 2: homme 

$\alpha_{S[i]}$ devient $\alpha_{2}$ dans le cas d'un homme

On doit assigner des a priori: 

$$ \alpha_{j} \sim Normal(60, 10) $$

($j$ indique qu'il y en plus d'un)

``` R
library(rethinking)
data(Howell1)
d <- Howell1
d <- d[d$age >= 18 , ]

dat <- list(
  W = d$weight,
  S = d$male + 1)

m_SW <- quap(
  alist(
    W ~ dnorm(mu, sigma),
    mu <- a[S],
    a[S] ~ dnorm(60, 10),
    sigma ~dunif(0, 10)
  ), data = dat
)

post <- extract.samples(m_SW)

# extraction de la moyenne W à posteriori
dens( post$a[,1], xlim = c(39,50), lwd = 3, col = 2,
     xlab = "posterior mean weight (kg)")

dens( post$a[,2], lwd = 3, col = 4, add = TRUE)
# les hommes sont plus lourds en moyenne 

# Pour faire la distribution on a besoin de simuler la distribution
W1 <- rnorm( 1000, post$a[, 1], post$sigma )
W2 <- rnorm( 1000, post$a[, 2], post$sigma )

dens( W1, xlim = c(20,70), ylim = c(0, 0.085), lwd = 3,
     col = 2, xlab = "posterior predicted weight (kg)")

dens(W2, lwd = 3, col = 4, add = TRUE)


```

### Toujours contraster (contextualiser ?)

Si on veut travailler sur des catégories il faut toujours utiliser le contraste, la différence entre les catégories. On ne peut pas interpréter la superposition des distributions parce que les paramètres sont autocorreleés. Il y une incertitude sur un paramètre associée avec une incertitude sur un autre paramètre. 

Il faut calculer la distribution contrastée (?) (*contrast distribution*)

si il y a deux paramètres d'intérêt on ne peut pas prendre leurs interval de confiance et les comparer. Il faut regarder leur différence et faire l'interval de confiance de cette différence. 

``` R
str(post)

# causal contrast (in means)
mu_contrast <- post$a[, 2] - post$a[ ,1]

dens(mu_contrast, xlim = c(3,10), lwd = 3, col = 1 ,
     xlab = "posterior mean weight contrast (kg)")

```

Pour le moment on a travailler sur l'effet sur sexe sur le poids via les deux chemins (H -> W et S -> W). Qu'en est-il pour S -> W strict ?

### Index variables et lignes

$$ W_{i} \sim Normal(\mu_{i}, \sigma) $$  

$$ \mu_{i} = \alpha + \beta(H_{i} - \hat(H)) $$

mais maintenant on a:

$$ \mu_{i} = \alpha_{S[i]} +\beta_{S[i](H_{i} - \hat(H))} $$

et on rajoute: 

$$ \beta = [\beta_{1}, \beta_{2}] $$  

``` R
data(Howell1)
d <- Howell1
d <- d[d$age >= 18 , ]

dat <- list(
  W = d$weight,
  H = d$height,
  Hbar = mean(d$height),
  S = d$male + 1)

m_SHW <- quap(
  alist(
    W ~ dnorm(mu, sigma),
    mu <- a[S] + b[S]*(H - Hbar),
    a[S] ~ dnorm(60, 10),
    b[S] ~ dlnorm(0, 1),
    sigma ~ dunif(0, 10)
  ), data = dat
)
```

Ce que l'on veut faire ensuite: 

1. Calculer la prédiction pour les femmes

2. Calculer la prédiction pour le hommes

3. Retirer 2 de 1

4. Représenter chaque distribution

``` R
xseq <- seq( from = 130, to = 190, len = 50 )
plot( NULL, xlim = c(130, 180), ylim = c(30, 60),
     xlab = "height (cm)", ylab = "weight (kg)")

# when do we defined m_adults2
muF <- link(m_SHW,
            data = list(S = rep(1, 50),
                        H = xseq,
                        Hbar = mean(d$height)))
lines( xseq, apply(muF, 2, mean), lwd = 3, col = 2)

muM <- link(m_SHW,
            data = list(S = rep (2, 50),
                        H = xseq,
                        Hbar = mean(d$height)))
lines( xseq, apply( muM, 2, mean), lwd = 3, col = 4)

mu_contrast <- muF - muM

plot( NULL, xlim = range(xseq), ylim = c(-6, 8),
     xlab = "height (cm)", ylab = "weight contrast (F-M)")
for ( p in c(0.5, 0.6, 0.7, 0.8, 0.9, 0.99) )
  shade( apply(mu_contrast, 2, PI, prob = p ), xseq)
abline(h = 0, lty = 2)

```

### Full Bayes

On a utilisé deux modèles pour les *estimands* mais il est possible de le faire avec un seul modèle puis d'utiliser la *joint posterior* pour obtenir chacun des deux.

``` R
m_SHW_full <- quap(
  alist(
   # Weight
    W ~ dnorm(mu, sigma),
    mu <- a[S] + b[S]*(H - Hbar),
    a[S] ~ dnorm(60, 10),
    b[S] ~ dlnorm(0, 1),
    sigma ~ dunif(0, 10),

    # Height
    H ~ dnorm(nu, tau),
    nu <- h[S],
    h[S] ~ dnorm(160, 10),
    tau ~ dunif(0, 10)
    
  ), data = dat
)

precis(m_SHW_full, depth = 2)
```

#### Simulaion des interventions

``` R
post <- extract.samples(m_SHW_full)
Hbar <- dat$Hbar
n <- 1e4

with( post, {
# simulation W pour S = 1
  H_S1 <- rnorm(n, h[, 1], tau )
  W_S1 <- rnorm(n, a[, 1] + b[, 1]*(H_S1 - Hbar ), sigma)

# W pour S = 2
  H_S2 <- rnorm(n, h[,2], tau)
  W_S2 <- rnorm(n, a[, 2] + b[ , 2]*(H_S2-Hbar), sigma )

# compute contrast
  W_do_s <<- W_S2 - W_S1
} )

# une autre option automatisée
HWsim <- sim(m_SHW_full,
             data = list(S = c(1,2)),
             vars = c("H", "W"))

w_do_s_auto <- HWsim$W[ , 2] - HWsim$W[ ,1]

```

### synthèse: inférence avec les modèles linéaires

Avec plus d'une variable, un modèle scientifique et statistique ne seront pas toujours les mêmes.

1. On explicite chaque *estimand*  
2. On design un modèle statistique pour chacun 
3. On calcule chaque *estimand*

Ou:

1. idem
2. On produit la distribution posterieur jointe du système
3. On simule chaque estimand comme une intervention 

Toujours utiliser un agrégat (moyenne, interval) à la fin, car ce sont surtout des outils de communication.

Ce que l'on veut: différence moyenne et pas la différence des moyennes.

## Des courbes via des lignes

H -> W n'est pas linéaire. 

Les modèles linéaire peuvent facilement devenir des courbes. 

Mais ce n'est mécaniques (ie c'est un peu géocentrique). 

il y a deux stratégies: 

1. polynomiales

2. Splines: considères meilleures


### polynomial

$$ \mu_{i} = \alpha + \beta_{1}x_{i} + \beta_{2}x_{i}^{2} $$

Pb: contient des symétrie non désirables, compliqué d'aller au delà de la range du sample.

### Splines

ce sont plusieurs fonctions locales qui forment la spline.

tjrs intéressant de regarder ce que donne un prior de splines

ce sont des régressions sur des variables synthétiques (B)

B activent différents poids à différentes regions. 

ces fonctions segmentent l'axe x en fonction de leur poids (un set de vecteurs)




