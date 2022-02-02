# Modeling Events


Un petit récapitulatif:

- La logique de base est de compter tout les chemins pour produire un résultats

- Régression linéaire dans n contexte bayesien 

- Connections des outils à nos compréhensions scientifiques

- Lier ces outils avec des statistiques plus compliqué

- Prédiction et approximation (overfit)

- Scientifique computing 

On va se focaliser sur les comptages! (yeah!!)

On va travailler sur un jeux de données d'admission à l'université de Californie (Berkeley).

Le jeux de données à été mis en place car l'administration se demandait si il y avait une discrimination contre les femmes. 

4526 candidatures, divisé par département et par genre.

## Dessiner le Hiboux

1. Estimand

2. Scientific models

3. Statistical models

4. analyze

G (gender) --> admission
 
Il y a le un autre facteur le département d'admission.
 
G --> département --> admission 
 
on a donc deux chemins.
 
C'est une structure classique de médiation. 

4526 candidatures, divisé par département et par genre.

## Dessiner le Hiboux

1. Estimand

2. Scientific models

3. Statistical models

4. analyze

 G (gender) --> admission
 
 Il y a le un autre facteur le département d'admission.
 
 G --> département --> admission 
 
 on a donc deux chemins.
 
 c'est une structure classique de médiation.
 
 Les causes ne sont pas dans les données il faut y mettre bcp de contexte et de causalité venant d'ailleurs.
 
G --> A Correspond à la discrimination directe. 

G --> D --> A Discrimination indirecte

## Modèle génératif

Il est important de pouvoir écrire une simulation de notre étude. Sinon on va avoir du mal à la coprendre.

Comment un choix de département peux provoquer de la discrimination ?

``` R
 library("Rlab")


N <- 1000
# even gender distribution
G  <- sample(1:2 , size = N, replace = TRUE)
# gender of acceptance rates [dpt,gender]
# il y a deux dpts
# gender 1 tend to apply to dpt 1
# gender 2 tend to apply to gender 2
D <- rbern(N, ifelse( G == 1, 0.3, 0.8))  + 1 
# matrix of acceptance rates [dpt, gender]
# rows = dpt
# colonne = gender
# pas d'effet du genre
# ex dpt 1 à 0.1 taux d'admission pour 1 et 2 egc
accept_rate <- matrix( c(0.1, 0.3, 0.1, 0.3), nrow = 2)
# simulate acceptance
A <- rbern(N, accept_rate[D, G])
```
 
 
``` R
N <- 1000
# even gender distribution
G  <- sample(1:2 , size = N, replace = TRUE)
# gender of acceptance rates [dpt,gender]
# il y a deux dpts
# gender 1 tend to apply to dpt 1
# gender 2 tend to apply to gender 2
D <- rbern(N, ifelse( G == 1, 0.3, 0.8))  + 1 
# matrix of acceptance rates [dpt, gender]
# rows = dpt
# colonne = gender
# pas d'effet du genre
# ex dpt 1 à 0.1 taux d'admission pour 1 et 2 egc
accept_rate <- matrix( c(0.05, 0.20, 0.1, 0.3), nrow = 2)
# simulate acceptance
A <- rbern(N, accept_rate[D, G])

table(G, D)
table(G, A)
```

Ici on montre que malgré une discrimination on observe pas via table(G, A)

Il manque beaucoup: la taille de la pool de candidats, la distribution des qualifications.

En principe on doit échantillonner dans la pool de candidat et ensuite ordonner par admissions. Les taux sont conditionnels à la structure des candidats. 

### une introduction au modèle linéaire généralisé (GLM)

Dans un modèle linaire, valeur cible est additive ("linéaire") combinaison de plusieurs paramètres. 

ex: mu est l'addition d'alpha + betax * x + betaZ * Z

Les modèles linéaires sont une famille simpliste de modèle linéaire généralisé (GLM)

La valeur cible est une fonction (*some fonction* on va l'aborder plus tard) de la combinaison additive des paramètres.

$$ Y_{i} \sim Bernoulli(p_{i})$$

$$ f(p_{i} = \alpha + \beta_{x}X_{i} + \beta_{Z}Z_{i})$$

(ce qui determine un coin flip est la proba de chaque coté ici $p_{i}$)

$Y_{i}$ 0/1 outcome 

$f()$ maps l'échelle de proba à l'échelle linaires (coté droit de l'équation)

$f$ est la *link function*

Elle relie les paramètres d'une distribution au modèle linéaire.

$f^{-1}$ est l'inverse de la fonction de lien.

$$p_{i} = f^{-1}(\alpha + \beta_{x}X_{i} + \beta_{Z}Z_{i}) $$

Son objectif est de défaire ce que la fonction de link fait.

Un exemple:

$$ f(a) = a^{2} = b $$

$$ f^{-1}(b) = \sqrt(b) = a $$

On utilise *logit*. Bernouilli/Binomial sont des modèles pour des comptages. Ils utilisant le *logit link*

$$ logit(p_{i} = log(\frac{p_{i}}{1 - p_{i}}))$$

$\frac{p_{i}}{1 - p_{i}}$ est nommé l'*odds*.


Il y a une inverse de cette fonction : *inverse logit* que l'on apelle parfois logistic.

$$logit(pi_{i} = log \frac{p_{i}}{1 - p_{i}}) =  $$

$$logi^{-1}(q_{i}) = ? = p_{i} $$

$$ pi = \frac{exp(q_{i})}{1 + exp(q_{i})} $$


logit(p) = 0; p = 0.5

logit(p) = 6; p = always

logit(p) = -6; p = never


Dans ce cas le paramètre (p) n'est pas à la même échelle que les données (0/1).

### comment définit on des priori dans ce cas ?

On fait des simulations.

On se rappelle que l'espace de logit est entre -6 et 6 (et que ces derniers sont très extrêmes) même entre -4 et 4 on reste très très large.

$$ logit(p_{i} = \alpha) $$

$$ \alpha \sim Normal(0,1) $$

Si on a $\alpha$ et $\beta$:

``` R
library(rethinking)
a <- rnorm(1e4, 0, 10) # produit des courbes très tranchées
b <- rnorm(1e4, 0, 10) # alpha (0, 1.5) et beta (0, 0.5) plus raisonnable

xseq <- seq(from = -3, to = 3, len = 100)
p <- sapply(xseq, function(x) rethinking::inv_logit(a+b*x))

plot(NULL, xlim = c(-2.5, 2.5), ylim = c(0,1),
     xlab = "x value", ylab = "probability")
for ( i in 1:10) lines(xseq, p[i, ], lwd = 3, col = 2)

```

### Modèle statistique

Si on veut le *total effect* on ne stratifie pas par D

$$ A_{i} \sim Bernouilli(p_{i}) $$ 

$$Pr(A_{i} = 1 = p_{i}) $$

$$ logit(p_{i} = \alpha[G_{i}]) $$

$$ p_{i} = \frac{exp(\alpha[G_{i}])}{1 + exp(\alpha[G_{i}])} $$

$$ \alpha = [\alpha_{1}, \alpha_{2}]$$ ici les genres

Si on pend l'effet direct de G --> A

$$ A_{i = \sim Bernouilli(p_{i})} $$

$$ logit(p_{i}) = \alpha[G_{i}, D_{i}] $$

$$ 
  \alpha =
   \left[ {\begin{array}{cc}
             \alpha_{1, 1}  & \alpha_{1,2} \\
             \alpha_{2, 1} & \alpha_{2,2} \\
             \end{array} } \right ] 
  $$

Avec D en colonnes et G en lignes.

``` R

data_sim <- list( A = A, D = D, G = G)

m1 <- ulam(
  alist(
    A ~ bernoulli(p),
    logit(p) <- a[G],
    a[G] ~ normal(0, 1)
  ), data = data_sim, chains = 4, cores = 4
)

m2 <- ulam(
  alist(
    A ~ bernoulli(p),
    logit(p) <- a[G, D],
    matrix[G,D]:a ~ normal(0, 1)
  ), data = data_sim, chains = 4, cores = 4 
)

precis(m1, depth = 2)
precis(m2, depth = 3)

```

### Analyses

Pour le moment on a travailler sur une regression logistique la sortie est binaire [0, 1] et on utilise *logit link* et une distribution de Bernouilli. 

Il est aussi la regréssion binomiale où on a un compte [0, N] et on utilise logit link et une distribution binomiale.

Il faut restructurer les données on a un format très long (une ligne un cas)

``` R
dat_sim2 <- aggregate(A ~ G + D, data_sim, sum)
dat_sim2$N <- aggregate(A ~ G + D, data_sim, length )$A
```

n a juste besoin de changer les ligne de codes précédentesen passant de bernoulli à binomial. 

``` R

data(UCBadmit)
d <- UCBadmit 

dat <- list(
  A = d$admit,
  N = d$applications,
  G = ifelse(d$applicant.gender == "female", 1, 2),
  D = as.integer(d$dept)
)

                                        #total effect gender

mG <- ulam(
  alist(
    A ~ binomial(N, p),
    logit(p) <- a[G],
    a[G] ~ normal(0, 1)
   ), data = dat, chains = 4, cores = 4
)

mGD <- ulam(
  alist(
    A ~ binomial(N, p),
    logit(p) <- a[G, D],
    matrix[G, D]:a ~ normal(0, 1)
 ), data = dat, chains = 4, cores = 4
)

precis(mG, depth = 3)
precis(mGD, depth = 3)

```


Les sorties via `precis` sont dures à lire. Ce qui est important c'est de regarder n_eff et Rhat4.

Ils faut regarder trace plots et trace je sais plus quoi.

Regardons l'effet total:

``` R

post1 <- extract.samples(mG)
PrA_G1 <- inv_logit(post1$a[,1])
PrA_G2 <- inv_logit(post1$a[,2])
diff_prob <- PrA_G1 - PrA_G2
dens(diff_prob, lwd = 4, col = 2, xlab = "gender contrats (probability)")

```

Les hommes sont avantagés.

``` R

post2 <- extract.samples(mGD)
PrA <- inv_logit( post2$a )
diff_prob_D_ <- sapply( 1:6 , function(i) PrA[,1 , i] - PrA[,2, i ])

plot(NULL, xlim = c(-0.2, 0.3), ylim = c(0,25), xlab = "Gender contrast (probability)")
for( i in 1:6)  dens (diff_prob_D_[,i], lwd = 4, col = i + 1, add = TRUE)

```

Qu'elle est l'effet direct moyen du genre pour chaque département.

Cela dépends de la distribution des candidatures et de la probabilités que chaque homme/femme candidate à chaque départements.

Une part de l'explication est que les femmes candidates à des départements spécifiques. 

On doit rajouter un médiateur le genre perçu (P) entre G --> P --> A

Pour calculer l'effet de P on doit moyenner (*maginalize*) sur les départements.

C'est simple à faire via simulations.

Ce que l'on vient de faire: *post stratification* *Re-weighting estimates for target population*

Sur une fac différentes, la distribution des candidatures seraient différentes et les conséquences de l'intervention aussi.

## Synthèse

Pas de discrimination "global" mais:

La distribution des candidatures peut être le résultats d'une discrimination.

Il peut y avoir des facteur de confusion. (next lecture)

Une introduction de Binomial GLM

Outcome is a count with a Max




