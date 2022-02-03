# Sensitivity and Poisson GLM

Il ne faut pas regarder chaque paramètres en détail mais l'ensemble ici le résultat de la fonction.   

Un changement uniforme dans le predicteur ne conduit pas à un changement uniforme dans la prédiction.

Tous les variables interagissent entre elles.

## facteur de confusion dans les candidatures

G --> D
G --> A
D --> A
U --> D
U --> A

U pourrait être l'habiliter. 

### On commence par une simulation 

``` R
library(rethinking)

set.seed(17)
N <- 2000 # number of applicants
# even gender distribution
G <- sample( 1:2 , size=N , replace=TRUE )
# sample ability, high (1) to average (0)
u <- rbern(N,0.1) # 10 % have better ability: 1
# gender 1 tends to apply to department 1, 2 to 2
# and G=1 with greater ability tend to apply to 2 as well
D <- rbern( N , ifelse( G==1 , u*0.5 , 0.8 ) ) + 1
# matrix of acceptance rates [dept,gender]
# matrice differente en fonction de l'abilité
accept_rate_u0 <- matrix( c(0.1,0.1,0.1,0.3) , nrow=2 )
accept_rate_u1 <- matrix( c(0.2,0.3,0.2,0.5) , nrow=2 )
# simulate acceptance
p <- sapply( 1:N , function(i) 
    ifelse( u[i]==0 , accept_rate_u0[D[i],G[i]] , accept_rate_u1[D[i],G[i]] ) )
A <- rbern( N , p )

table(G,D)
table(G,A)
```



``` R

dat_sim <- list( A=A , D=D , G=G )

# total effect gender
m1 <- ulam(
    alist(
        A ~ bernoulli(p),
        logit(p) <- a[G],
        a[G] ~ normal(0,1)
    ), data=dat_sim , chains=4 , cores=4 )

post1 <- extract.samples(m1)
post1$fm_contrast <- post1$a[,1] - post1$a[,2]
precis(post1)

# direct effects - now confounded!
m2 <- ulam(
    alist(
        A ~ bernoulli(p),
        logit(p) <- a[G,D],
        matrix[G,D]:a ~ normal(0,1)
    ), data=dat_sim , chains=4 , cores=4 )

precis(m2,3)
```

L'effet total montre un désavantage.

Il faut toujours regarder le résultats et le contraste

``` R

post2 <- extract.samples(m2)
post2$fm_contrast_D1 <- post2$a[,1,1] - post2$a[,2,1]
post2$fm_contrast_D2 <- post2$a[,1,2] - post2$a[,2,2]
precis(post2)

dens( post2$fm_contrast_D1 , lwd=4 , col=4 , xlab="F-M contrast in each department" )
dens( post2$fm_contrast_D2 , lwd=4 , col=2 , add=TRUE )
abline(v=0,lty=3)

dens( post2$a[,1,1] , lwd=4 , col=2 , xlim=c(-3,1) )
dens( post2$a[,2,1] , lwd=4 , col=4 , add=TRUE )
dens( post2$fm_contrast_D1 , lwd=4 , add=TRUE )

dens( post2$a[,1,2] , lwd=4 , col=2 , add=TRUE , lty=4 )
dens( post2$a[,2,2] , lwd=4 , col=4 , add=TRUE , lty=4)
dens( post2$fm_contrast_D2 , lwd=4 , add=TRUE , lty=4)

```

C'est un cas de collider bias. Si on stratifie par D on met en place un facteur de confusion car cela ouvre un chemin non causal avec u. 


Les individus G1, plus qualifiés, candidatent pour le département avec de la discrimination.  Le genre 1 dans ce département est plus qualifié en moyenne que le G2.

Un haut niveau compense la discrimination (cache l'évidence).

### Policing confounds

X (ethnicity) --> Y(assaulted by police)
X ---> Z (stopped by police) ---> Y

Il y a aussi un facteur de confusion: "acting supicious" u

u --> Z 
u --> Y

Pb: les chiffres de la police ont des facteur de confusion par l'absence de stats sur qui n'est pas arrêté. Cela force un conditionnement sur Z (stopped by police). 

### si on pouvait mesurer u

``` R

dat_sim$u <- u
m3 <- ulam(
    alist(
        A ~ bernoulli(p),
        logit(p) <- a[G,D] + buA*u,
        matrix[G,D]:a ~ normal(0,1),
      buA ~ normal(0,1)
      # ici on force u d'etre positif car c'est un meilleur prior
    ), data=dat_sim , constraints=list(buA="lower=0") ,
    chains=4 , cores=4 )

post3 <- extract.samples(m3)
post3$fm_contrast_D1 <- post3$a[,1,1] - post3$a[,2,1]
post3$fm_contrast_D2 <- post3$a[,1,2] - post3$a[,2,2]

precis(post3)

dens( post2$fm_contrast_D1 , lwd=1 , col=4 , xlab="F-M contrast in each department" , xlim=c(-2,1) )
dens( post2$fm_contrast_D2 , lwd=1 , col=2 , add=TRUE )
abline(v=0,lty=3)
dens( post3$fm_contrast_D1 , lwd=4 , col=4 , add=TRUE )
dens( post3$fm_contrast_D2 , lwd=4 , col=2 , add=TRUE )

```

Pour stratifier pour enlever son effet. 

On obtient le bon résultat avec dpt2 étant discriminant. 

Comme on ne peut pas les observer dans la réalité que peux t on faire ?

Une solution est d'expérimenter et ainsi de randomizer le facteur de confusion on est bon. Si l'experimentation n'est pas possible il y a d'autres option on va en evoquer deux:
 - *Sensitivity analysis*
 
 - *Measure proxies of confounded* 
 
### Sensitivity analysis 
 
Quels sont les implications de ce que l'on ne connaît pas?
 
On assume l'effet d'un facteur de confusion. on modelise ses conséquences pour différentes forces/types d'influence.
 
Quelle force doit avoir le facteur de confusion pour changer nos conclusions.  
 
$$ A_{i \sim Bernoulli(p_{i})} $$
 
$$ logit(p_{i}) = \alpha[G_{i}, D_{i}] + B_{G[i]}\mu_{i} $$
 
$$ (D_{i} = 2) \sim Bernoulli(q_{i}) $$
 
$$ logit(q_{i} = \theta[G_{i}] + \sigma_{G[i]}\mu_{i})$$


``` R
# sensitivity

dat_sim$D2 <- ifelse( D==1 , 1 , 0 )
dat_sim$b <- c(1,1)
dat_sim$g <- c(1,0)
dat_sim$N <- length(dat_sim$D2)

m3s <- ulam(
    alist( 
        # A model
        A ~ bernoulli(p),
        logit(p) <- a[G,D] + b[G]*u[i],
        matrix[G,D]:a ~ normal(0,1),

        # D model
        D2 ~ bernoulli(q),
        logit(q) <- delta[G] + g[G]*u[i],
        delta[G] ~ normal(0,1),

        # declare unobserved u
        vector[N]:u ~ normal(0,1)
    ), data=dat_sim , chains=4 , cores=4 )

precis(m3s,3,pars=c("a","delta"))

post3s <- extract.samples(m3s)
post3s$fm_contrast_D1 <- post3s$a[,1,1] - post3s$a[,2,1]
post3s$fm_contrast_D2 <- post3s$a[,1,2] - post3s$a[,2,2]

dens( post2$fm_contrast_D1 , lwd=1 , col=4 , xlab="F-M contrast in each department" , xlim=c(-2,1) )
dens( post2$fm_contrast_D2 , lwd=1 , col=2 , add=TRUE )
abline(v=0,lty=3)
dens( post3s$fm_contrast_D1 , lwd=4 , col=4 , add=TRUE )
dens( post3s$fm_contrast_D2 , lwd=4 , col=2 , add=TRUE )

plot( jitter(u) , apply(post3s$u,2,mean) , col=ifelse(G==1,2,4) , lwd=3 )
```

On peut observer que les femmes acceptées étaient celle avec une compétences + importantes.

Sensitivity analysis est toujours entre une simulation pure et une analyse pure. 

Les facteurs de confusion sont tjrs présents. 


### Mesurer par des proxies le facteur de confusion

exemple: 

u ---> test score
u ---> test score 2

Si les tests sont informatifs. (cf simulation, le premier test est précis, le second un peu moins).

(a compléter)

## Technology and Poisson GLMs

On va utiliser un data set: oceanic tool complexity

Complexité lié à la taille de la population ?

Il y a deux influences sur l'innovation : la taille de la population et les contacts. 

L'innovation produit des outils mais on perds des outils au cours du temps. La perte est lié au nombre d'outils. 

il y a une porte dérobée via localisation. Il faut ajuster avec L et stratifier par C pour étudier l'interaction (mais ce n'est pas un facteur de confusion).

Le nombre d'outils n'est pas binomial: pas de max 

On va utiliser un distribution de Poisson: elle prend en compte de très hautes valeurs et de faible probabilité pour chaque succès. Ici pleins de technologies possibles mais peut de produire dans tous les endroits.

$\lambda$ expected count ou rate, c'est l'expected value 

On utilise un log link

$$ Y_{i} \sim Poisson(\lambda_{i}) $$

$$ log(\lambda_{i}) = \alpha + \betaX_{i} $$ 

$$  \lambda_{i} = exp(\alpha + \betaX_{i}) $$

Elle doit être positive. L'échelle exponentielle doit être surprenante. 

### Effet sur le prior

$$ log(\lambda_{i} = \alpha)

$$ \alpha \sim Normal(0,10) $$

autre choix:

$$ \alpha \sim Normal(., 0.5) $$
 
``` R

library(rethinking)
data(Kline)
d <- Kline
d$P <- scale( log(d$population) )
d$contact_id <- ifelse( d$contact=="high" , 2 , 1 )

dat <- list(
    T = d$total_tools ,
    P = d$P ,
    C = d$contact_id )

# intercept only
m11.9 <- ulam(
    alist(
        T ~ dpois( lambda ),
        log(lambda) <- a,
        a ~ dnorm( 3 , 0.5 )
    ), data=dat , chains=4 , log_lik=TRUE )

# interaction model
m11.10 <- ulam(
    alist(
        T ~ dpois( lambda ),
        log(lambda) <- a[C] + b[C]*P,
        a[C] ~ dnorm( 3 , 0.5 ),
        b[C] ~ dnorm( 0 , 0.2 )
    ), data=dat , chains=4 , log_lik=TRUE )

compare( m11.9 , m11.10 , func=PSIS )

```

bcp d'autres paramètres que la population ont des effets. Il y a des outliers.

option pour ameliorer :

1. utiliser un modèle plus robust: gamma-Poisson

2. utiliser un modèle scientifique plus specifique.




