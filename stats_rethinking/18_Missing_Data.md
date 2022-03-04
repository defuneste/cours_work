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

On repart du modèle utilisé dans la leçon précédente. On a besoin de rien de plus pour obtenir les données manquantes. 

Dans un cadre bayesien, la structure du modèle vient d'un contexte scientifique et une fois que l'on a l'échantillon on peut décider ce qui est un paramètre et de la données. Les valeurs observées sont des données celles non-observées sont des paramètres. 

Le modèle comporte 3 sous modèles. On continue a faire des petites étapes.

1. Ignorer les cas ou B à des valeurs manquantes 

2. Impute (calculer la distribution à posteriori des valeurs manquantes) G et M en ignorant leurs modèles (plus pour le coté pédagogique pour voir à coté de quoi on passe). 

3. Impute G utilisant le modèle

4. Impute B, G, M utilisant le modèle.

### Premières étapes

``` R

## R code 14.49
data(Primates301)
d <- Primates301
d$name <- as.character(d$name)
dstan <- d[ complete.cases( d$group_size , d$body , d$brain ) , ]
spp_cc <- dstan$name

# complete case analysis
dstan <- d[complete.cases(d$group_size,d$body,d$brain),]
dat_cc <- list(
    N_spp = nrow(dstan),
    M = standardize(log(dstan$body)),
    B = standardize(log(dstan$brain)),
    G = standardize(log(dstan$group_size)),
    Imat = diag(nrow(dstan)) )

# drop just missing brain cases
dd <- d[complete.cases(d$brain),]
dat_all <- list(
    N_spp = nrow(dd),
    M = standardize(log(dd$body)),
    B = standardize(log(dd$brain)),
    G = standardize(log(dd$group_size)),
    Imat = diag(nrow(dd)) )

dd <- d[complete.cases(d$brain),]
table( M=!is.na(dd$body) , G=!is.na(dd$group_size) )

```

Il y en a peut où on ne connaît pas M (masse corporelle) mais un peu plus où l'on ne connaît pas G (taille du groupe).

Si $G_{i}$ est manquant on prend le modèle existant, sinon on remplace cette valeur par un paramètre. Idem pour G.

``` R

library(ape)
spp <- as.character(dd$name)
tree_trimmed <- keep.tip( Primates301_nex, spp )
Rbm <- corBrownian( phy=tree_trimmed )
V <- vcv(Rbm)
Dmat <- cophenetic( tree_trimmed )

# distance matrix
dat_all$Dmat <- Dmat[ spp , spp ] / max(Dmat)
dat_cc$Dmat <- Dmat[ spp_obs , spp_obs ] / max(Dmat)

# imputation ignoring models of M and G
fMBG_OU <- alist(
    B ~ multi_normal( mu , K ),
    mu <- a + bM*M + bG*G,
    M ~ normal(0,1),
    G ~ normal(0,1),
    matrix[N_spp,N_spp]:K <- cov_GPL1(Dmat,etasq,rho,0.01),
    a ~ normal( 0 , 1 ),
    c(bM,bG) ~ normal( 0 , 0.5 ),
    etasq ~ half_normal(1,0.25),
    rho ~ half_normal(3,0.25)
)
mBMG_OU <- ulam( fMBG_OU , data=dat_all , chains=4 , cores=4 , sample=TRUE )


```

On récupère des distributions pour chaque distribution. Pour G on est pas bon, il passe à coté de la structure de la relation entre B et G.

### Étape 3

Deux modeles : 

``` R
# no phylogeny on G but have submodel M -> G
mBMG_OU_G <- ulam(
    alist(
        B ~ multi_normal( mu , K ),
        mu <- a + bM*M + bG*G,
        G ~ normal(nu,sigma),
        nu <- aG + bMG*M,
        M ~ normal(0,1),
        matrix[N_spp,N_spp]:K <- cov_GPL1(Dmat,etasq,rho,0.01),
        c(a,aG) ~ normal( 0 , 1 ),
        c(bM,bG,bMG) ~ normal( 0 , 0.5 ),
        c(etasq) ~ half_normal(1,0.25),
        c(rho) ~ half_normal(3,0.25),
        sigma ~ exponential(1)
    ), data=dat_all , chains=4 , cores=4 , sample=TRUE )

# phylogeny information for G imputation (but no M -> G model)
mBMG_OU2 <- ulam(
    alist(
        B ~ multi_normal( mu , K ),
        mu <- a + bM*M + bG*G,
        M ~ normal(0,1),
        G ~ multi_normal( 'rep_vector(0,N_spp)' ,KG),
        matrix[N_spp,N_spp]:K <- cov_GPL1(Dmat,etasq,rho,0.01),
        matrix[N_spp,N_spp]:KG <- cov_GPL1(Dmat,etasqG,rhoG,0.01),
        a ~ normal( 0 , 1 ),
        c(bM,bG) ~ normal( 0 , 0.5 ),
        c(etasq,etasqG) ~ half_normal(1,0.25),
        c(rho,rhoG) ~ half_normal(3,0.25)
    ), data=dat_all , chains=4 , cores=4 , sample=TRUE )

```

On peut ajouter la phylogénie et M + G

Ici cela va être fait avec Stan :

Il y a différents blocs. Il y en a un pour `data` un pour `parameters` et un pour le `model`.

Stan marche un peu à l'envers que le modèle mathématique. En bas on trouve les premières équations. 

### Synthèse

Idée principale: les valeurs manquantes sont déjà dans les distributions.

Penser comme un graph et pas comme un régression: faire des sous-modèle

On peut perdre pas mal d'efficience si on ne le fait pas. 


Il y a une partie dans le ivre sur *censored observations*.

