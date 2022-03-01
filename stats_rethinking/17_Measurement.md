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
    D_sd = d$Divorce.SE / sd(d$Divorce),
    M_sd = d$Marriage.SE / sd(d$Marriage),
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

    # D model (unobserved)
    vector[N]:D_true ~ dnorm( mu , sigma ),
    mu <- a + bA*A + bM*M_true[i],
    a ~ dnorm(0,0.2),
    bA ~ dnorm(0,0.5),
    bM ~ dnorm(0,0.5),
    sigma ~ dexp( 1 ),

    # Mstar model observed 
    M_obs ~ dnorm( M_true , M_sd ),

   # M model (unobserved)
    vector[N]:M_true ~ dnorm( nu , tau ),
    nu <- aM + bAM * A,
    aM ~ dnorm(0, 0.2),
    bAM ~ dnorm(0, 0.5),
    tau ~ dexp(1)
    
  ) , data=dlist , chains=4 , cores=4 )

```


On améliore de beaucoup ici car on a un outcome (y) et un income (x). On a un partial pooling sur les deux axes.

bM en ajoutant l'erreur devient plus large et supérieur à 0 (au lieu de rester autour de 0).

Inclure l'erreur revient à diminuer le poids de certains états avec des estimation de mauvaises qualité. Inclure les erreurs est la seule option honnête. 

## Misclassification


Bilineal descent: généalogie du coté de la mère et du père.

Leur héritage passe par la mère mais les status par le père. Le femmes bougent chez leurs maris une fois marié. La polygynie est courante. 

Il est aussi acceptés qu'hommes et femmes puissent avoir des relations sexuels en dehors du mariage. 

On cherche à estimer la proportion d'enfant d'on le pére n'est pas le mari.

Des tests génétiques ont été fait mais il y autour de 5% de faux positive.

La *misclassification*: la version en catégorie d'erreur de mesure.

On fait un DAG. Puis un modèle génératif: il prend en compte la mère et la dyade. 

$$ X_{i} \sim Bernoulli(p_{i}) $$   

$$ logit() = \alpha + \mu_{M[i]} + \delta_{D[i]} $$

$$ Pr(Xstar_{i} = 1 | p_{i}) = p_{i} + (1 - p_{i})f $$

$$ Pr(Xstar_{i} = 0 | p_{i}) = (1 - p_{i})(1 - f) $$

c'est pas intuitive donc il faut faire un arbre des probabilités: 

Il y a $p_{i}$ de faire $X_{i} = 1$ et donc ici de faire $1 - p_{i}$ de faire $X_{i} = 0$

Si on a 0 on a 5% de faire un faux positif et donc on a une proba $f$ que Xstar soit = 1 et le reste ($1 - f$) que Xstar reste 0.

Ainsi pour produire Xstar = 1 on a deux chemins, le premier qui dépend de $p_{i}$ et le second qui depend de $(1 -p)f$ (d'abord 0 puis f pour arriver à 1).

Pour Xstar = 0 c'est (1-p)(1-f)

``` R 
dat$f <- 0.05

mx <- ulam(
  alist(
    X|X==1 ~ custom(log(p+ (1-p)*F)), # ici le log car stan fait les stats sur le log scale
    X|X==0 ~ custom(log((1-p)*(1-f))),# c est plus precis
    logit(p) <- a + z[mom_id]*sigma * [dyad_id]*tau
    a ~ normal(0, 1.5),
    z[mom_id] ~ normal(0,1),
    sigma ~ normal(0,1),
    x[dyad_id] ~ normal(0,1),
    tau ~ normal(0, 1)
  ), data = dat, chains=4, cores = 4, iter = 4000,
  constraints = list(sigma = "lower=0", tau = "lower=0")
)

```

C'est une mauvais façon de compter et de le faire!

Les ordinateurs utilisent un système: **Floating point arithmetic** pour les calculs. C'est important quand l'on fait des proba. Si il y a une probabilité très faible, elle se rapproche de 0 elle sera arrondie à 0. De l'autre coté si on se rapproche trop de 1.

Une des solutions est de tout faire sur l'échelle logarithmique car ces problèmes deviennent alors plus rares. 

Il y a toute une serie de fonctions pour cela.

``` R 
mx <- ulam(
  alist(

    X|X==1 ~ custom(log_sum_exp( log(p), log1m(p) + log(f) ),
                    
    X|X==0 ~ custom(log1m(p) + log1m(f)), 
                    
                    
    logit(p) <- a + z[mom_id]*sigma * [dyad_id]*tau
    a ~ normal(0, 1.5),
    z[mom_id] ~ normal(0,1),
    sigma ~ normal(0,1),
    x[dyad_id] ~ normal(0,1),
    tau ~ normal(0, 1)
  ), data = dat, chains=4, cores = 4, iter = 4000,
  constraints = list(sigma = "lower=0", tau = "lower=0")
)

```

`log1m` est une fonction qui retourne le log( 1 - son premier argument). Ainsi `log1m(p)` correspond à log(1-p)

C'est une fonction qui réduit under et overflow. 

On ajoute car sur une échelle log le + correspond à une multiplication. 

`log_sum_exp` va retourne le log des exposant de chaque arguments. (on passe en exposant, pour enlever le log, on somme le tout, et on log : log_sum_exp)  

On peut aller encore plus loin (je reprendrais le code plus tard).

Il y a bcp de problèmes lier à des erreurs de mesures. C'est le cas de ce qui utilise des juges et des testes. Pour cela il existe des "item response theory" ce qui est une sous famille de "factor analysis". 

Il y a aussi "hurdlle models". C'est les cas ou on est trop bas pour détceter. 

Occupancy models: not detecing something doesn't mean it isn't here. 



