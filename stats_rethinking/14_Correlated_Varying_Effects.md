# Correlated Varying effects

Ne pas perdre l'objectif de vue: faire de la science.

La stratégie des *Varying effects*: utiliser des features non mesurés dans des clusters pour laisser une empreinte de la donnée qui peut être mesuré par des observations répétées pour chaque cluster et par un partial pooling entre les clusters.

Pourquoi c'est bien : 

- D'un point de vue de la prédiction: les features non mesurées dans les données sont des sources importantes de variation d'au niveau des clusters. Cela permet de régulariser. 

- D'un point de vue la perspective de l'intervention: permet d'ajuster à des causes en compétition et observer d'éventuel facteur de confusion   

Si on utilise *Fixed effects*: pas de pooling, c'est comme si on mettait la variance au max entre les clusters (on apprend rien entre chaque cluster, par exemple dans le cas des cafés échantillonner dans un café en particulier ne nous apprends rien sur la population de café).

Cette vidéo se concentre sur ajouter plus de features.

### Adding features and learning correlations

On a une distribution à priori pour chaque cluster.

Un feature: une distribution à une dimension: 

$$ \alpha_{j} \sim  Normal(\bar{\alpha}, sigma) $$

si on échantillone dedans on a un nombre.

Dans le cas de deux features: on a 2D distribution. Ce qui nous donne deux résultats.

$$ [\alpha_{j}, \beta_{j}] \sim MVNormal([\bar{\alpha}, \bar{\beat}], \Sigma) $$

MVNormal : multivariate Normal

$\Sigma$ est une matrice de covariance.

La difficulté est d'apprendre les associations.  

Sur le premier départements on commence à voir une corrélation entre le nombre d'admission et la sélection de plus de femmes. Dans le département 2 on reste proche de la moyenne. Dans le département 3 on a moins d'admission et les hommes sont favorisés. Le modèle commence a être plus confident dans le fait qu'il y aurait une corrélation entre a (admission) et b.

Cela permet de passer de l'information. 

#### Cas avec les chimpanzés

$$ P_{i} \sim Bernouilli(p_{i}) $$

On a mean + actor-treatment + block-treatment 

$$ logit(P_{i} =  \bar{\alpha_{A[i]}} + \alpha_{A[i], T[i]} + \bar{\beta_{B[i]}} + \beta_{B[i],T[i]}) $$


$\bar{\alpha_{A[i]}$ : moyenne pour chaque acteur

$\alpha_{A[i], T[i]}$ : acteur en tenant compte de chaque traitement

$\bar{\beta_{B[i]}}$ : moyenne pour chaque block

$\beta_{B[i],T[i]}$ block en tenant compte de chaque traitement

$$ \alpha_{j} \sim MVNormal([0,0,0,0], R_{A}, S_{A}) for j \in 1..7   $$

(on a 4 traitement) Prior pour les effets de la covariance acteur-traitement un vecteur de 4 paramètres pour chaque acteur j

$$ \beta_{k} \sim MVNormal([0,0,0,0], R_{B}, S_{B} for k \in 1..6) $$

Prior pour les effets de la covariance block-traitement, un vecteur de 4 paramètres pour chaque block k

$$ \bar{\alpha_{j}} \sim Normal(0, \tau_{A})  $$

$$ \bar{\beta_{k}} \sim Normal(0, \tau_{B})  $$

Prior pour les acteus et les traitements 

$$ S_{A,j}, S_{B,J}, \tau_{A}, \tau_{B} \sim Exponential(1) for j \in 1..4  $$

chaque écart type prend le même prior, une écart type pour chaque traitement

$$R_{A}, R_{B} \sim LKJcorr(4) $$ 

Prior de la matrice de corrélation

LKJcorr est une distribution pour les matrice de corrélation (à regarder dans le livre).

``` R
library(rethinking)
data(chimpanzees)
d <- chimpanzees
dat <- list(
    P = d$pulled_left,
    A = as.integer(d$actor),
    B = as.integer(d$block),
    T = 1L + d$prosoc_left + 2L*d$condition)

m14.2 <- ulam(
alist(
    P ~ bernoulli(p),
    logit(p) <- abar[A] + a[A,T] + bbar[B] + b[B,T],
    
    # adaptive priors
    vector[4]:a[A] ~ multi_normal(0,Rho_A,sigma_A),
    vector[4]:b[B] ~ multi_normal(0,Rho_B,sigma_B),
    abar[A] ~ normal(0,tau_A),
    bbar[B] ~ normal(0,tau_B),

    # fixed priors
    c(tau_A,tau_B) ~ exponential(1),
    sigma_A ~ exponential(1),
    Rho_A ~ dlkjcorr(4),
    sigma_B ~ exponential(1),
    Rho_B ~ dlkjcorr(4)
) , data=dat , chains=4 , cores=4 )

dashboard(m14.2)
precis(m14.2,3)
```

A est un matrix mais ici c'est représenté comme une liste de vecteur. Pour chaque acteur A on a un vecteur de 4.

Pas mal de problème : pe on n'arrive pas à capter toute la distribution.


## Non-centered covariance

Comment peut-on refactoriser R et S?

on va utiliser une abréviation:

    $$ \alpha = (diag(S_{A})L_{A}Z_{T,A})^{T}  $$

$L_{A}$ : Cholesky factor

(TODO reprendre le code pour ne pas être manger par un grand ancien)

## Synthèse

Il faut dessiner... Richard dit que c'est normal... 

C'est important  d'utiliser des priors qui peuvent apprendre des corrélations dans les données. Cela marche entre cluster mais aussi entre features.  
