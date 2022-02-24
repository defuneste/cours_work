# Gaussian processes

## Spatial confounding 

On reprend l'exemple des technologies en Oceanie.  

``` R
library(rethinking)
data(Kline2)
```

Ce que l'on cherche a estimer est l'effet de la population sur l'évolution de la technologie. 

Les Îles qui sont proches partage des facteurs de confusion non observé et des innovations. Elles ont une covariation spatiale.  

P ---> T <--- C

U ---> P

U ---> T

(U) : facteur de confusion non observé.

(cf chapitre pour revoir la fonction d'élasticité).

Il faut construire par incrémentation. 

$$ T_{i} \sim Poisson(\lambda_{i}) $$

$$ log \lambda_{i} = \bar(\alpha) + \alpha_{S[i]}  $$

Chaque société à sa deviation par rapport à la moyenne et on va les chercher avec du partial poolinf.

$i$ est un vecteur de chaque société $[\alpha_{i}, \alpha_{2} ..., \alpha_{10} ]$

On va les tirer dans une MVNormal (un pauquet de 0 pour leur moyenne respective, une matrice de covariance $K$, on l'appel parfois un Kernel).

C'est comme cela que l'on va modéliser l'effet spatiale.

On va utiliser un *Gaussian Process* :

> "an infinte dimensional generalization of multivariate normal distributions"

Au lieu d'utiliser une matrice de covariance assez grosse (par exemple celle que l'on devrait construire pour notre $K$) on va utiliser une fonction de kernel qui permet de généraliser à un nombre infini de dimensions/observations/prédictions.

Cette fonction va nous donner une covariance pour autant de paire de points en fonction de leur distance. Cela peut être un tas de distance: spatial, temporelle etc ..

Cela marche pour les variables continues et ordonnées. 

On peut faire varier la covariance qui définit le kernel pour jouer sur la coté "wiggle/bendy" des gaussiennes générées.

On peut apprendre sur les données à la fois sur la fonction de kernel, sur les bar d'erreurs et les gaussiennes pouvant passer par les points.

Pour faire cela fonctionner on doit prendre une fonction pour la *covariance kernel*:

Quadratic (L2):

$$ k(x_{1}, x_{2} = \alpha_{2} exp(\frac{-(x_{1}-x_{2}^{2})}{\sigma^{2}})) $$

besoin de deux paramètres: 

- $\alpha^2$ et $\sigma^2$

Ornstein-uhlenbeck (L1) :

$$ k(x_{1}, x_{2}) = \alpha_{2} exp(-\frac{|x_{1} - x_{2}|}{\sigma}) $$

Periodic:

$$ k(x_{1}, x_{2}) =\alpha^{2} exp(- \frac{2sin^{2}((x_{1} - x_{2})/2)}{\sigma^{2}}) $$

Ici on  va prendre le modèle quadratique.

### Covariance océanique

$$ k_{i,j} = \eta^{2} exp(-lambda^{2}d^{2}_{i.j}) $$

$k_{i,j}$ : covariance

$\eta^2$ : covariance maximum

$\lambda$ : toujours le taux de déclin

$d_{i,j}$: distance i,j

$$\bar{alpha} \sim Normal(3, 0.5) $$

$$ \eta² \sim exponential(2) $$

$$ \lambda^{2} \sim Exponential(0.5) $$

Pour comprendre ce que c'est prior implique il faut simulercar ils interactent de manière non linéaire.

``` R
# sim priors for distance model
n <- 30
etasq <- rexp(n,2)
rhosq <- rexp(n,1)
plot( NULL , xlim=c(0,7) , ylim=c(0,2) , xlab="distance (thousand km)" , ylab="covariance" )
for ( i in 1:n )
    curve( etasq[i]*exp(-rhosq[i]*x^2) , add=TRUE , lwd=4 , col=col.alpha(2,0.5) )
```

C'est une bonne idée de bien tester ses prior y compris d'en changer pour tester si cela change les conclusions (pe pas de manière global).

``` R
data(Kline2) # load the ordinary data, now with coordinates
d <- Kline2
data(islandsDistMatrix)
# display (measured in thousands of km)
Dmat <- islandsDistMatrix
colnames(Dmat) <- c("Ml","Ti","SC","Ya","Fi","Tr","Ch","Mn","To","Ha")
round(Dmat,1)

dat_list <- list(
    T = d$total_tools,
    P = d$population,
    S = 1:10,
    D = islandsDistMatrix )

mTdist <- ulam(
    alist(
        T ~ dpois(lambda),
        log(lambda) <- abar + a[S],
        vector[10]:a ~ multi_normal( 0 , K ),
        transpars> matrix[10,10]:K <- cov_GPL2(D,etasq,rhosq,0.01),
        abar ~ normal(3,0.5),
        etasq ~ dexp( 2 ),
        rhosq ~ dexp( 0.5 )
    ), data=dat_list , chains=4 , cores=4 , iter=4000 , log_lik=TRUE )

precis(mTdist,2)

```


Pour comprendre on a besoin de simuler. mTdist ne prend en compte que la distance.


(je suis paumé sur le modèle à l'équilibre)

``` R
# now full model

dat_list <- list(
    T = d$total_tools,
    P = d$population,
    S = 1:10,
    D = islandsDistMatrix )

mTDP <- ulam(
    alist(
        T ~ dpois(lambda),
        lambda <- (abar*P^b/g)*exp(a[S]), ### ici 
        vector[10]:a ~ multi_normal( 0 , K ),
        transpars> matrix[10,10]:K <- cov_GPL2(D,etasq,rhosq,0.01),
        c(abar,b,g) ~ dexp( 1 ), ## et ici 
        etasq ~ dexp( 2 ),
        rhosq ~ dexp( 0.5 )
    ), data=dat_list , chains=4 , cores=4 , iter=4000 , log_lik=TRUE )

precis( mTDP , depth=2 )

post <- extract.samples(mTDP)
```

### Primate phylogeny

Le détail de l'histoire est perdu mais on a toujours des patrons de covariation. 

``` R
data(Primates301)
```

On les traits d'histoire de vie. La masse des adultes (en log kg), la taille du cerveau (cc), la taille des groupes (en log). Tout cela varie beaucoup. C'est trois indicateur sont corrélés.  

Ce data contient pas mal de données manquantes, il y a des erreurs de mesures et des facteur de confusion non observé. Ce sont ces derniers qui vont nous intéresser. 

Ici on va se focaliser sur ce que les cas complets. Il faut noter que les valeurs manquantes ne sont pas introduit aléatoirement. 

G ---> B

M ---> B

M ---> G

Il y a sans doute des facteur de confusion comme u 

u ---> M, u ---> G et u ----> G

L'histoire agirait sur u ie : h ---> u

On a deux problème conjoint: 

1. Qu'est ce que l'histoire (phylogénie?)

2. Comment peut-on l'utiliser pour modéliser les causes? 


#### What is history?

Devenu plus précis avec la génomique. 

Il y a toujours beaucoup d'incertitude, les processus ne sont pas fixes aucune phylogénie n'est correcte pour tous les traits.

> le travail des statistiques n'est pas de nous donner les réponses que l'on souhaite mais de nous donner celles que l'on peut justifier (par modèle et données).

Basic Truth: phylogènie n'existe pas, comme les réseaux sociaux ce sont des facteurs de compressions des données. 

#### Comment on utilise une phylogénie quand on en une ? 

Il n'y a pas de réponses uniques, cela dépends des causes que l'on cherche à analyser. Pour le moment ce sont les process gaussiens qui sont utilisés. 

On peut faire un modèle linéaire estimant B en tant compte de G et en stratifiant par B pour ferme le backdoor path. 

Ce modèle peut être étendue à toutes les espèces via MVnormal et une matrice de covariance K (qui sera un kernel de process gaussien). 

$I$ est une matrice vide sauf pour sa diagonale qui est 1. Si on la multiple par $sigma^2$ on obtient une matrice vide sauf pour la diagonale avec pleins de $\sigma²$   

On va ajouter le facteur de confondeur $u$. 

Cela va être $u_{i}$ et on va utiliser la phylogénie pour l'obtenir. 

Un modèle évolutionniste et une structure en arbre indique que les patrons de covariance sont aux pointes. La covariance varie avec la distance phylogénétique. 

K va être remplacer par un kernel d'Ornstein Uhlenbeck (avec les paramètres et les prior adéquate).

Le modèle utiliser va être halfnormal car on n'a besoin de résultat positif. 


Il y a d'autres possibilités:

- Automatic relevance determiantion (ARD)

- Multi-output

- Telemetry, navigation (real time tracking and error)


