# Missing data

Si on a un modèle avec des *joint probability* on peut l'utiliser dans les deux sens. 

La plus part du temps il y a des données manquantes. Il y a plusieurs type de données manquantes. Il y a les variables, comme les facteurs de confusion qui peuvent être non observé. Mais il y a aussi les cas plus courant les cas ou on des valeurs et des cas ou l'on pas de valeurs. 

(TODO faire le cas avec le DAG pour illustrer)

Il est parfois justifié de me pas garder les données manquantes. Ce qui le justifie dépends des causes sous-jacentes.

On va : 

1. Représenter les données manquantes dans un DAGs

2. Les imputations bayesiennes 

3. Censoring et imputation 

## Les données manquantes dans un DAGs

S (temps que les étudiants passent à travailler) ----> H (qualité du Homework)

Mais H n'est pas observable, ce que l'on observe est Hstar avec des valeurs manquantes.

H ---> Hstar

Si on imagine qu'il y a un chien (D) qui mange les devoirs aléatoirement.

D ----> Hstar

Il n'y a pas de porte dérobée vers S et donc il n'y a pas de biais entre S et Hstar (cela réduit notre efficience).

``` R

# Dog eats random homework
# aka missing completely at random
library(rethinking)

N <- 100
S <- rnorm(N)
H <- rnorm(N,0.5*S)
# dog eats 50% of homework at random
D <- rbern(N,0.5) 
Hstar <- H
Hstar[D==1] <- NA

plot( S , H , col=grau(0.8) , lwd=2 )
points( S , Hstar , col=2 , lwd=3 )

abline( lm(H~S) , lwd=3 , col=grau(0.8) )
abline( lm(Hstar~S) , lwd=3 , col=2 )

```

C'est le cas le plus bénin de données manquantes.

Si on modifie le DAG:

S ---> D 

Les étudiants travaillent beaucoup donc négligent leurs chiens et ceux ci mangent les devoirs. 

Dans ce cas il peut y avoir un biais. Le chien mange conditionnellement en fonction d'une cause les devoirs.

``` R

# Dog eats homework of students who study too much
# aka missing at random
N <- 100
S <- rnorm(N)
H <- rnorm(N,0.5*S)
# dog eats 80% of homework where S>0
D <- rbern(N, ifelse(S>0,0.8,0) ) 
Hstar <- H
Hstar[D==1] <- NA

plot( S , H , col=grau(0.8) , lwd=2 )
points( S , Hstar , col=2 , lwd=3 )

abline( lm(H~S) , lwd=3 , col=grau(0.8) )
abline( lm(Hstar~S) , lwd=3 , col=2 )

```

Dans ce cas on perds des renseignements mais cela ne va pas changer le type de relation car celle ci est linéaire.

Dans le cas suivant la relation n'est plus linéaire et cela pose problème:

``` R

# Dog eats homework of students who study too much
# BUT NOW NONLINEAR WITH CEILING EFFECT
N <- 100
S <- rnorm(N)
H <- rnorm(N,(1-exp(-0.7*S))) # ici <------ c'est une fonction de deceleration
# dog eats 100% of homework where S>0
D <- rbern(N, ifelse(S>0,1,0) ) 
Hstar <- H
Hstar[D==1] <- NA

plot( S , H , col=grau(0.8) , lwd=2 )
points( S , Hstar , col=2 , lwd=3 )

abline( lm(H~S) , lwd=3 , col=grau(0.8) )
abline( lm(Hstar~S) , lwd=3 , col=2 )

```

Un cas encore plus problématique est: 

H ----> D 

Cela crée un chemin de biais (sic) entre H et Hstar. Les chiens mangeraient des mauvais devoir. 

Le seul moyen de s'en sortir est de modéliser le chien (ou ce qui cause l'absence de données). 

``` R

# Dog eats bad homework
# aka missing not at random
N <- 100
S <- rnorm(N)
H <- rnorm(N,0.5*S)
# dog eats 90% of homework where H<0
D <- rbern(N, ifelse(H<0,0.9,0) ) 
Hstar <- H
Hstar[D==1] <- NA

plot( S , H , col=grau(0.8) , lwd=2 )
points( S , Hstar , col=2 , lwd=3 )

abline( lm(H~S) , lwd=3 , col=grau(0.8) )
abline( lm(Hstar~S) , lwd=3 , col=2 )

```

C'est le cas dans les "survival analysis". On se doute que la valeur est manquante car dans les cas où elle est manquante elle a une certaine valeur.

Voila 3 types: 

1. le chien mange les devoirs aléatoirement : ne pas garder les cas incomplet n'est pas un problème mais on perds en efficacité

2. le chien mange les devoir en fonction de la cause : on peut le corriger en conditionnant sur la cause

3.  le chien mange les devoir en fonction de leur caractéristiques: souvent pas grand chose à faire sauf si on peut modéliser le comportement du chien 

## Bayesian Imputation

Sur on prend le cas 1 et 2 on peut faire une  *imputation* ou *maginalize* sur les valeurs manquantes. 

*Bayesian Imputation* : on calcul la distribution posterieurs des valeurs manquantes

*Marginalizing unknows* : on va moyenner sur la distribution des valeurs manquantes sans en calculer la distribution à posteriori

On peut faire cela car on a un modèle de causalité. Ce n'est cependant pas simple et technique mais souvent nécessaire.

Le bon plan c'est que parfois l'une n'est pas nécessaire pour l'autre. L'imputation est souvent non nécessaire pour les paramètres discrets. 

On va créer un paramètres pour chaque valeurs manquantes (Bayesian Imputation). Des fois cela peut être pas si compliqué. 


On reprend le cas avec la phylogénie des primates. C'est un exemple compliqué. 

Une idée principale est que n'importe quel modèle causale à des hypothèses sur la valeur des données manquantes. 

Il faut expliciter le modèle pour chaque variable partiellement observé.

Rappel il y a beaucoup de facteur de confusion dans ce jeux de données que l'on essaie de prendre en compte par la phylogénie.

On va commencer par se dire que seulement G à des valeurs manquantes 

G ---> Gstar et Gstar ----> mG (ce qui explique les valeurs manquante) et cela serait u qui influencerais mg (donc h). Autre possibilité est que ce soit M ---> mG. Et enfin il y le cas ou Gstar ---> mG (la pire, cf. 1. 2. 3. plus haut).

## Bayesian Imputation code




