# Multi-Multilevel models

Il faut pratiquer pour apprendre et pratiquer en se protégeant. 

Si on prend un modèle, on peut choisir le prior et sa taille. Quand on prenait un petit sigma cela signifiait que l'on était dans un cas de *complete pooling*, on assumait que tous les tanks était les mêmes. A chaque update on les mettait tous à jour de la même manière. si on va dans le "milieu" on est dans le partial pooling.    

Ce sont des super outils mais il y a des difficultés.

Comment utilise-t-on plus d'un cluster à la fois ? (exemple dans le cas des trolleys "stories" et participants)

Comment calcule t on des prédictions ? (on a un modèle pour l'ensemble et un modèle pour le groupe : comment choisit-on?)

Comment échantillone t on des chaînes dedans ? 

## Un peu de terminologie: cluster et features

*Clusters*, parfois aussi nommées *units*: groupes de données

*Features*: aspect du modèle (souvent des paramètres mais pas toujours) qui varient en fonction des clusters.

| Cluster     | Features             |
|:-----------:|:--------------------:|
| tanks       | survival             |
| stories     | treatment effect     |
| individuals | average response     |
| departments | admission rate, bias |

Dans cette vidéo on se concentre sur les clusters.

Ajouter des clusters: on ajoute plus d'index de variable et plus de priors sur la population.   

Le jeux de données comprends 504 essaies, 7 acteurs, 6 blocks et 4 traitements. 

(1) right, no partner  
(2) left, no partner  
(3) right, partner  
(4) left partner  

(condition side) T--> P (pulled left)
Block (B) ---> P
A actor ---> P

$$ P_{i} \sim Bernoulli(P_{i}) $$

Probabilité d'utiliser le levier à gauche

$$ logit(p_{i} = \beta_{T[i],\beta[i]} + \alpha_{A[i]}) $$

log-odds du levier de gauche

Ici on utilise une interaction entre block et traitement. On aurait pu ajouter block avec un effet propre ( + \BetaB etc) mais ici l'idée est que les blocks modère l effet de traitements d'ou le choix d'une interaction.

$$ \alpha_{j} \sim Normal(\bar{\alpha}, \sigma_{A}) $$

Ici c'est le prior pour l'effet "acteur"

$$ \beta_{j,k} \sim Normal(0, \sigma_{B})$$

Le prior du traitement/ effet de block. Pourquoi 0 pour la moyenne ? On aurait pu mettre $\bar{\beta}$ mais comme il ne peut y avoir qu'une moyenne dans le modèle logit, en mettant 0 on assume juste que le traitements est relative à l'effet d'actor.

$$ \sigma_{A}, \sigma_{B} \sim exponential(1) $$

Les priors pour *variance components*

Ici on fait du partial pooling sur un traitement et d'habitude on passe plutôt cela dans des effets fixes (un terme dans le modèle, un prior fixe sans paramètre ). 

Richard justifie cela en indiquant que ce n'est pas parce que l'on fixe un certains nombre de traitements que ce nombre est la population de traitements mais bien un échantillon de ces derniers. Dans la même logique le traitement même expérimental peut cacher bien des choses. Enfin ce choix produit de bon résultat.

On peut se référer au cas développer dans la lecture 12 ou on utilise PSIC pour détecter le prior optimum et que l'on a un résultat similaire avec du partial pooling (TODO mettre la ref dynamique).

Apprendre le prior sur l'échantillon donne une meilleur régularisation (TODO link to regularisation).  

``` R
data(chimpanzees)
d <- chimpanzees
d$treatment <- 1 + d$prosoc_left + 2*d$condition
dat <- list(
    P = d$pulled_left,
    A = d$actor,
    B = d$block,
    T = d$treatment ) 

# block interactions
mBT <- ulam(
    alist(
        P ~ bernoulli( p ) ,
        logit(p) <- b[T,B] + a[A],
      ## adaptive priors
        matrix[T,B]:b ~ dnorm( 0 , sigma_B ),
        a[A] ~ dnorm( a_bar , sigma_A ),
      ## hyper-priors
        a_bar ~ dnorm( 0 , 1.5 ),
        sigma_A ~ dexp(1),
        sigma_B ~ dexp(1)
    ) , data=dat , chains=4 , cores=4 )
```

Il semble que les chimpanzés auraient une mains dominante et que l'expérience ne les fait pas changer cette préférence. 

Dans ce type de modèle (idem pour les GLM) on ne peut pas juste ajouter les sigma pour avoir l'ensemble de variations. Cela ne marche que pour les modèles linaires.

Une modification dans un des composant va modifier la variation dans les autres. 

La fonction link casse l'additivité. 

## Multilevel predictions

Comme il y a deux modèles à l'intérieur du modèle on va devoir faire des choix sur comment on structure notre simulations d'échantillons. 

En général on veut généraliser à la population (et pas au block) donc on va regarder bcp plus les sigmas.

Cependant quand l'on va faire ses simulations il va falloir reconsidérer la distribution. Pour le prior on avait pris un modèle gaussien mais ce n'était pas nécessairement le cas des effets dans la nature (c'était juste un artifice de modélisation). Il faut donc revoir nos hypothèse sur la distribution.  

### Exemple avec Reedfrog

rapel: P la presence de prédateur et G la taille des tétard

TODO refaire

``` R
#recup dans 12
# reprendre le code des sides
```

Il faut comprendre et utiliser le générative modèle. On a besoin des techniques de simulation pour comprendre les effets des modèles complexes. 

## Divergent transitions

$$ v \sim Normal(0,3) $$

$$ x \sim Normal(0, exp(v))$$

C'est le devil tunnel: un des challenges à échantillonner dans les distributions postérieurs des varying effects. Comme ce type de modèle utilise un paramètre d'échelle pour en definir un autre. (cf. chapitre 13 13.7 et 13.7nc)

Cela génère bcp de rejected posposal : bcp de temps de computation 

On peut :

1. utiliser une plus petite *step size*. Stan va le faire (normalement) mais c'est plus long pour explorer la distribution

2. revoir les paramètres: la meilleure option 

Notre cas est dis "centered" on peut faire un cas "non centered":

$$ v \sim Normal(0,3) $$

$$ z \sim Normal(0,1 $$

$$ x = Z exp(v) $$
1
X definit dans la version centrée est la meme que celle dans la version non centrée

(c'est possible vu les caractéristiques d'un distribution normale).

cela marche mieux car nous allons tirer les échantillons dans v et z plutôt que v et x.

On appelle cela "non centering trick"

### Sur les tadpoles

On a un modèle "centered". On a des "paramètres pour déterminer ou il est".

Version non centrée:

$$ S_{i} \sim Binomial(D_{i}, p_{i}) $$

$$ logit(p_{i}) = \bar{\alpha} + Z_{T[i]*\sigma } $$

on reprend comme cela $apha_{j}$

$$ z_{j} \sim Normal(0,1) $$

$$ \bar{alpha} \sim(0, 1.5) $$

$$ \sigma \sim Exponential $$

### Non-centered chimpanzees

$$ logit(p_{i}) = \Beta_{T[i],B[i] + \alpha_{A[i]}} $$

devient:

$$ logit(P_{i}) = \bar{alpha} + (Z_{\alpha, A[i]})\sigma_{A} + (Z_{\beta,T[i],B[i]}) * \sigma_{b} $$

(avec les termes $Z_{\alpha, j}$ et $ Z_{\beta, J} $ à définir)

gq <- generate quantity

Pour bien comprendre cela il faut pratiquer !   


