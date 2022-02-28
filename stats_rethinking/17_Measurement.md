# Measurement  

## Bertrand's pancake (box) paradox

3 pancakes : 

- un brûler des deux cotés

- un brûler d'un seul coté 

- un pas brûlé

Si on a un pancake avec un coté brûlé, qu'elle est la probabilité d'avoir l'autre coté brûlé ? 

$$ Pr(burnt down | burnt up) = \frac{Pr(burnt up, burnt down)}{Pr(burnt up)} $$

Le principe de l'inférence probabiliste est de conditionner sur ce que l'on soit pour en déduire les effets sur ce que l'on ne sait pas.   

$Pr(burnt up, burnt down)$ est juste 1/3 (il n'y a qu'un pancake brûler des deux cotés)

$$ Pr(burn up) = \frac{1}{3}(1) + \frac{1}{3}(0.5) + \frac{1}{3}(0) = \frac{1}{2} $$

$$ Pr(burnt down | burn up ) = \frac{\frac{1}{3}}{\frac{1}{2}} = \frac{2}{3} $$

C'est important de ne pas trop faire confiance à son intuition. C'est aussi opaque. 

## Erreurs de mesure

C'est présent dans beaucoup de domaines et il est important d'en discuter. On va revisiter le descendant (cf lecture sur les DAG).  

Richard n'aime pas les méthodes ad'hoc car elles ne se généraliseraient pas ou peu.

## Income and recall error

Revenue des parents (P) ----> revenue des enfants (C)

Mais les revenues des parents n'est pas observé c'est ce que les enfants se rappellent du salaire de leur parent. 

On a donc revenue des parent non observé P ---> revenue des parents selon les enfant P*  <--- ep (une erreur). Bien sûr le revenue des enfants est lié à ep (C ---> ep).

``` R
# une simulation
library(rethinking)
 
N <- 500
P <- rnorm(N)
C <- rnorm(N, 0 * P) # pas de corélation cf le 0
Pstar <- rnorm(N, 0.8 * P + 0.2 * C) # ep est juste la diffŕence entre P et Pstar

mCP <- ulam(
  alist(
    C ~ normal(mu, sigma),
    mu <- a + b*P,
    a ~ normal(0,1),
    b ~ normal(0,1),
    sigma ~ exponential(1) 
  ), data = list(P=Pstar, C = C), chains = 4
)
    
precis(mCP)
```

On est a coté de la valeur de P. 

Une des solution est de le modéliser. 

### Exemple avec le jeux de données sur mariage/divorce

D, M et A sont mesurés avec des erreurs. Il peut  y avoir des problèmes quand il y a un déséquilibre dans les erreurs de mesures (ex: ici certains états ont de bien meilleures mesures).  

L'erreur sur le divorce est associé avec le nombre d'habitants dans l'état : plus d'habitant moins d'erreur. 

M ---> D (divorce non observé) ---> D* (Divorce observé) <--- eD (processus de mesures)
A ---> M
A ---> D

(c'est le cas pour A et M qui ont de Mstar, Astar influencé par eM et eA)

C'est possible que eA, eM et eD soient influencées par un même facteur de confusion comme P (population). 

Il faut essayer de penser comme un graph. Le défaut des régressions est qu'elles nous font penser les relations comme des équations avec un coté droit et un gauche.

Penser comme un graph mous permet d'adapter notre modèle.

On repart d'un graph simplifié. On peut le décomposer en un modèle pour D et un autre modèle pour Dstar. Il y un autre modèle que l'on va mettre de coté celui pour M. 

Ce sont des modèles joint car il partage des paramètres et des données.   

**Il faut toujours décomposer et faire par nombres petites étapes**

Le modèle pour D:

$$ D_{i} \sim Normal(\mu_{i}, \sigma)$$

$$ \mu_{i} = \alpha + \beta_{A} A_{i} + \beta_{M} M_{i} $$

Le modèle pour dstar:

$$D^{*} = D_{i} +e_{D,i} $$

$$e_{D,i} \sim Normal(0, S_{i}) $$ 

$ S_{i} $ est fournie par le bureau des stats.

``` R
data(WaffleDivorce)
d <- WaffleDivorce
dlist <- list(
    D_obs = standardize( d$Divorce ),
    D_sd = d$Divorce.SE / sd( d$Divorce ),
    M = standardize( d$Marriage ),
    A = standardize( d$MedianAgeMarriage ),
    N = nrow(d)
)

m15.1 <- ulam(
    alist(
     # model for Dstar (observed)
      D_obs ~ dnorm( D_true , D_sd ),
      
     # model fpr D (unobserved)      
        vector[N]:D_true ~ dnorm( mu , sigma ),
        mu <- a + bA*A + bM*M,
        a ~ dnorm(0,0.2),
        bA ~ dnorm(0,0.5),
        bM ~ dnorm(0,0.5),
        sigma ~ dexp(1)
    ) , data=dlist , chains=4 , cores=4 )

## R code 15.4
precis( m15.1 , depth=2 )
```

Cela marche car data et paramètres ne sont pas nécessairement des choses différentes dans un cadre bayesien.

On a fait un partial pooling. 

## Error on predictor

On va ajouter un modèle pour M et Mstar maintenant. Tous vont aller dans la meme MCMC.

``` R
m15.2 <- ulam(
  alist(
    # Dstar model (observed)
    D_obs ~ dnorm( D_true , D_sd ),
    
        vector[N]:D_true ~ dnorm( mu , sigma ),
        mu <- a + bA*A + bM*M_true[i],
        M_obs ~ dnorm( M_true , M_sd ),
        vector[N]:M_true ~ dnorm( 0 , 1 ),
        a ~ dnorm(0,0.2),
        bA ~ dnorm(0,0.5),
        bM ~ dnorm(0,0.5),
        sigma ~ dexp( 1 )
    ) , data=dlist , chains=4 , cores=4 )
```

