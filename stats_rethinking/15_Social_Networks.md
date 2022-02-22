# Social Networks

## Motivation du partage

``` R
library(rethinking)
data(KosterLeckie)
```

On va étudier les échanges entre 25 familles (household) à Arang Dak.

Part du partage expliqué par la réciprocité ? Part par le don généralisé ?

Quel couple ? quelles famille ? 

H-A ---> G-AB <--- H-B A donne de B

Donner est influencé par household A et B

H-A ---> T-AB <--- H-B Social "tie" de A vers B

sont-ils amis, famille ?

H-A ---> T-BA <--- H-B Social "tie" de B vers A

Pb: T-BA et T-AB n'est pas observable. Le réseaux social n'est pas observable c'est une abstraction et pas des datas.  Il y a des incertitudes, "latent variables". 

Il faut résister et ne pas utiliser les méthodes ad'hoc (Adhockery). Elle passe par des approches dit neutres.   

A la place on va dessiner une chouette:

1. Estimand: réciprocité et ce qu'elle explique.

2. modèle génératif

3. Modèle statistique

4. Analyse l'échantillon

On va avoir une démarche d'aller retour entre 2 et 3.

On a pas mal de facteur de confusion avec des *Backdoor paths* (H-A et H-B). Ils nous faut stratifier avec eux. C'est cependant compliqué, on va donc incrementer la complexité petit à petit.   

### Première version du modèle géneratif 

``` R

N <- 25
dyads <- t(combn(N,2))
N_dyads <- nrow(dyads)

# simulate "friendships" in which ties are shared
f <- rbern(N_dyads,0.1) # 10% of dyads are friends

# now simulate directed ties for all individuals
# there can be ties that are not reciprocal
alpha <- (-3) # base rate of ties; -3 ~= 0.05
y <- matrix(NA,N,N) # matrix of ties
for ( i in 1:N ) for ( j in 1:N ) {
    if ( i != j ) {
        # directed tie from i to j
        ids <- sort( c(i,j) )
        the_dyad <- which( dyads[,1]==ids[1] & dyads[,2]==ids[2] )
        p_tie <- f[the_dyad] + (1-f[the_dyad])*inv_logit( alpha ) # proba de tie
        y[i,j] <- rbern( 1 , p_tie )
    }
                 }#ij

# now simulate gifts
giftsAB <- rep(NA,N_dyads)
giftsBA <- rep(NA,N_dyads)
lambda <- log(c(0.5,2)) # rates of giving for y=0,y=1
for ( i in 1:N_dyads ) {
    A <- dyads[i,1]
    B <- dyads[i,2]
    giftsAB[i] <- rpois( 1 , exp( lambda[1+y[A,B]] ) )
    giftsBA[i] <- rpois( 1 , exp( lambda[1+y[B,A]] ) )
}

if ( TRUE ) {
# draw network
library(igraph)
sng <- graph_from_adjacency_matrix(y)
lx <- layout_nicely(sng)
vcol <- "#DE536B"
  plot(sng , layout=lx , vertex.size=8 , edge.arrow.size=0.75 , edge.width=2 , edge.curved=0.35 , vertex.color=vcol , edge.color=grau() , asp=0.9 , margin = -0.05 , vertex.label=NA )
  
}

```

On peut 1 le modèle pour expérimenter un peu. 

### Modèle statistique

On va ici faire un modèle qui n'a pas la même structure que le modèle génératif. 

C'est un comptage donc on va utiliser Poisson.

$$ G_{AB} \sim Poisson(\lambda_{AB}) $$

$$ log(\lambda_{AB} = \alpha + T_{AB}) $$

$\alpha$ : moyenne 

$T_{AB}$ : Lien entre A vers B

on a la symétrique (lien de B vers A): 

$$ G_{BA} \sim Poisson(\lambda_{BA}) $$

$$ log(\lambda_{BA} = \alpha + T_{BA}) $$

Pour chaque Dyade on a deux paramètres à estimer $T_{AB}$ et $T_{BA}$. 

$$ \binon{T_{AB}}{T_{BA}} \sim MVNormal \begin{bmatrix} 0 & 0 \end{bmatrix} , \begin{bmatrix} \sigma^{2} & \rho\sigma^{2} \\ \rho\sigma^{2 & \sigma^{2}  \end{bmatrix}) $$

$ \rho \sigma^2 $ covariance entre les dyade

$ \sigma^2 $ variance entre les liens (ties), on veut savoir si il y a un lien entre $T_{AB}$ et $T_{BA}$.

On a une matrice symétrique ce qui nous permet d'avoir moins de paramètres.


$$ \rho \sim LKJCorr(2) $$ 

$$ \sigma \sim Exponential(1) $$

(les trois derniers forment le partial pooling)

$$ \alpha \sim Normal(0, 1) $$

``` R

# dyad model
f_dyad <- alist(
    GAB ~ poisson( lambdaAB ),
    GBA ~ poisson( lambdaBA ),
    log(lambdaAB) <- a + T[D,1] ,
    log(lambdaBA) <- a + T[D,2] ,
    a ~ normal(0,1),

  ## dyad effects - non-centered
  # ici car on a peu de data et bcp de paramétre
    transpars> matrix[N_dyads,2]:T <-
            compose_noncentered( rep_vector(sigma_T,2) , L_Rho_T , Z ),
    matrix[2,N_dyads]:Z ~ normal( 0 , 1 ),
    cholesky_factor_corr[2]:L_Rho_T ~ lkj_corr_cholesky( 2 ),
    sigma_T ~ exponential(1),

    ## compute correlation matrix for dyads
    gq> matrix[2,2]:Rho_T <<- Chol_to_Corr( L_Rho_T )
)

mGD <- ulam( f_dyad , data=sim_data , chains=4 , cores=4 , iter=2000 )

precis( mGD , depth=3 , pars=c("a","Rho_T","sigma_T") )

post <- extract.samples(mGD)
T_est <- apply(post$T,2:3,mean)
# convert to adjacency matrix
y_est <- y
for ( i in 1:N_dyads ) {
    y_est[ dyads[i,1] , dyads[i,2] ] <- T_est[i,1]
    y_est[ dyads[i,2] , dyads[i,1] ] <- T_est[i,2]
}#i

# show discrimination as densities for each true tie state
dens( y_est[y==0] , xlim=c(-0.5,1.5) , lwd=4 , col=2 , xlab="posterior mean T" )
dens( y_est[y==1] , add=TRUE , lwd=4 , col=4 )

# show correlation by true friend state
plot( T_est[,1] , T_est[,2] , lwd=3 , col=ifelse(f==1,6,1) , xlab="Household A" , ylab="Household B" )

# show reciprocity
dens( post$Rho_T[,1,2] , lwd=4 , col=2 , xlab="correlation within dyads" , xlim=c(-1,1) )

```

Ici on va faire un petit test avec les données. 

``` R

# analyze sample
kl_data <- list(
    N_dyads = nrow(kl_dyads),
    N_households = max(kl_dyads$hidB),
    D = 1:nrow(kl_dyads),
    HA = kl_dyads$hidA,
    HB = kl_dyads$hidB,
    GAB = kl_dyads$giftsAB,
    GBA = kl_dyads$giftsBA )

mGDkl <- ulam( f_dyad , data=kl_data , chains=4 , cores=4 , iter=4000 )

precis( mGDkl , depth=3 , pars=c("a","Rho_T","sigma_T") )

post <- extract.samples(mGDkl)
dens( post$Rho_T[,1,2] , lwd=4 , col=2 , xlab="correlation within dyads" , xlim=c(-1,1) )

```

il y a bien un correlation, à voir comment cela va changer si on ferme les backdoor path.

### Generalized giving

#### On reprend la simulation 

``` R

# simulate wealth
W <- rnorm(N) # standardized relative wealth in community
bWG <- 0.5 # effect of wealth on giving - rich give more
bWR <- (-1) # effect of wealth on receiving - rich get less / poor get more

# now simulate gifts
giftsAB <- rep(NA,N_dyads)
giftsBA <- rep(NA,N_dyads)
lambda <- log(c(0.5,2)) # rates of giving for y=0,y=1
for ( i in 1:N_dyads ) {
    A <- dyads[i,1]
    B <- dyads[i,2]
    giftsAB[i] <- rpois( 1 , exp( lambda[1+y[A,B]] + bWG*W[A] + bWR*W[B] ) ) # wealth on Giving et wealth on Receving
    giftsBA[i] <- rpois( 1 , exp( lambda[1+y[B,A]] + bWG*W[B] + bWR*W[A] ) )
}

if ( FALSE ) {
library(igraph)
sng <- graph_from_adjacency_matrix(y)
lx <- layout_nicely(sng)
vcol <- "#DE536B"
plot( sng , layout=lx , vertex.size=8 , edge.arrow.size=0.75 , edge.width=2 , edge.curved=0.35 , vertex.color=vcol , edge.color=grau() , asp=0.9 , margin = -0.05 , vertex.label=NA  )
}

plot( jitter(giftsAB) , jitter(giftsBA) )

```

Ce sont des effets des household. 

#### On modifie le modèle statistique

On a besoin de modifier le modèle linéaire. 

$$ log(\lambda_{AB}) = \alpha + T_{AB} + G_{A} + R_{B} $$

On rajoute A qui donne ($G_{A}$) et B qui reçoit ($R_{B}$).

C'est dit "generalized" car le fait de donner de A ne dépend pas de B.

On fait pareil pour $\lambda_{BA}$.

On va aussi rajouter des *varying effect*.

Un peu trop hardu pour moi en latex!
 
C'est la matrice de covariance des household giving et receiving.
 
On a besoin de la definition de ses paramètres.
 
Le modèle est pour :

- 25 households

- 300 dyades

- 600 observations de dons


Il contient 602 paramètres pour les reseaux sociaux et 53 paramètres pour les households.

``` R

sim_data <- list(
    N_dyads = N_dyads,
    N_households = N,
    D = 1:N_dyads,
    HA = dyads[,1],
    HB = dyads[,2],
    GAB = giftsAB,
    GBA = giftsBA )

# general model
f_general <- alist(
    GAB ~ poisson( lambdaAB ),
    GBA ~ poisson( lambdaBA ),
    log(lambdaAB) <- a + T[D,1] + gr[HA,1] + gr[HB,2],
    log(lambdaBA) <- a + T[D,2] + gr[HB,1] + gr[HA,2],
    a ~ normal(0,1),

    ## dyad effects - non-centered
    transpars> matrix[N_dyads,2]:T <-
            compose_noncentered( rep_vector(sigma_T,2) , L_Rho_T , Z ),
    matrix[2,N_dyads]:Z ~ normal( 0 , 1 ),
    cholesky_factor_corr[2]:L_Rho_T ~ lkj_corr_cholesky( 2 ),
    sigma_T ~ exponential(1),

   ## gr matrix of varying effects
    transpars> matrix[N_households,2]:gr <-
            compose_noncentered( sigma_gr , L_Rho_gr , Zgr ),
    matrix[2,N_households]:Zgr ~ normal( 0 , 1 ),
    cholesky_factor_corr[2]:L_Rho_gr ~ lkj_corr_cholesky( 2 ),
    vector[2]:sigma_gr ~ exponential(1),

   ## compute correlation matrixes
    gq> matrix[2,2]:Rho_T <<- Chol_to_Corr( L_Rho_T ),
    gq> matrix[2,2]:Rho_gr <<- Chol_to_Corr( L_Rho_gr )
)

mGDGR <- ulam( f_general , data=sim_data , chains=4 , cores=4 , iter=2000 )

precis( mGDGR, depth=3 , pars=c("a","Rho_gr","sigma_gr","Rho_T","sigma_T") )


```

On a une association négative entre recevoir et donner (c'est codé comme cela dans la simulation, presque: les riches donnent plus et les pauvres reçoivent plus). 

#### Sur les données

Il y a toujours une corrélation négative entre recevoir/donner mais c'est moins extrême que dans la simulations. 

Le modèle pense qu'une fois on a pris en compte la don/recevoir le reste serait du à la réciprocité. 

Ce que l'on montre c'est le network dessiné à posteriori. 

Le network est incertain donc ses statistiques le sont aussi (ici j'ai un doutes et des question pour la session).

Les social networks sont une compression de la données. Ce sont des placeholders pour des causes. 

On peut modéliser les liens du réseaux par des caractéristiques des dyades. 

Qu'est ce qui explique le modelé don/recevoir ? (on va utiliser des caractéristiques des households).

Mais des relations peuvent être des causes de relation (un ami d'un ami peut devenir un ami). 


## Caractéristiques des household et des dyades.


On transforme chaque partie (sauf alpha) du modèle linéaire en modèle linéaire avec varying effet.

A tenter de faire..

## ce que l'on a pas fait:

Les relations. Les tryades (triangle closure). 

Il y a la possibilité d'utiliser des "block models" (c'est des choses comme communuty detection).  

Le défaut de la donnée brute et qu'elle n'est pas "régularisée"

## Varying effects as technology

Les réseaux sociaux sont des abstractions. On essaie de trouver des régularités dans les observations. 

Il y a des nombreux effet similaires dont l'espace. (spatial confounding)

Que se passe t il quand les cluster sont continus et non discrets? 

