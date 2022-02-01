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







