# Generalized Linear madness

GLM: flexible 

Avec un modèle causal externe permet une interprétation causale. 

Seulement une fraction des phénomènes scientifiques peuvent s'exprimer avec un GLM (M).

Elles sont le "trou carré" de notre tool kit et ont peu faire plus satisfaisant.  

Mêmes si ils sont suffisant, il est important de partir de la théorie. 

## Geometric people

Le poids est proportionnel à la masse. 

On va partir d'un cylindre: $h * r$ (radius * hauteur)

Le volume d'un cylindre:

$$ V = \pi r^{2} h  $$

On va utiliser une proportion pour radius 

$$ V = \pi (ph)^{2} h $$

$ph$ est le radius estimé à une proportion de la hauteur.

Enfin notre poids (weight, w) est proportionnel au volume:

$$ W = kV = k \pi (ph)^{2} h^{3} $$

Une fois que l'on a cela il nous faut trouver des distributions et leurs paramètres.

Comment choisir ces priors:

1. choisir des échelles de mesures

2. faire des simulations

3. Penser :P

### Choisir une échelles de mesures

Ici on veut des kg, on a des kg/cm³ et des cm³.

Les unités des paramètres (ici $k$) sont déterminées par celles des données. 

Les échelles de mesures sont un artifice humain. 

Si on divise le poids par le poids moyen et la hauteur par la hauteur moyenne on simplifie les unités et cela devient plus simple.

Un prior pour $p$ entre 0-1 et < 0.5 (quasi impossible d'être plus large que long)

$$ p \sim Distribution(...) $$

Un prior pour la densité rée; postif > 1

$$ k \sim Distribution(...) $$

### simulations

$$ p \sim Beta(25,50) $$

Beta est une distribution pour les probabilité

$$ k \sim exponential(0.5) $$

On part de celle-ci.

Il nous faut trouver la distribution pour W. Le poids est positif et sa variance va avec la moyenne (grande personne sont en moyenne plus large).

Ici on va prendre la Log Normal, la croissances est un process multiplicatif.


$$ W \sim LogNormal(\mu_{i}, \sigma) $$


Attention mu in log normal de la moyene du log. 

C'est pour cela que l'on utilise un `exp()` pour $\mu$

Pas très mauvais pour un cylindre mais pas terrible pour les enfants. Ce qui est mauvais donne des infos pour changer le modèle, c'est donc informatif. $p$ est différents pour les enfants. 


### Penser

Quand on voit ce type de courbe, cela semble indiqué que ce que l'on identifie n'est pas plusieurs paramètres mais un produit entre un même paramètre.

$$ k =  \frac{1}{\pi p²}$$

La plupart des relation entre la hauteur et le poids est juste la relation entre la hauteur et le volume (pas besoin de rajouter p par exemple).

Le changement dans la forme des enfants explique pas très bien pour les enfants.

Il n'y a pas d'empirisme sans théorie. 

## State-based childern

Les options sont:

- "majority choice": 3 enfants prennent la même couleur et on un jouet

- "minority choice": un enfant prends trois fois la même couleur et à trois fois un jouet.

- "unchosen": un cas non exploré par aucun enfant

C'est important vis à vis de "social conformity".

Est ce que les enfants copie la majorité. Cependant on ne peut pas voir leur stratégie mais leurs choix. 

On peut avoir un choix:

- de "random color" : choisit la majorité 1/3 

- de "random demonstrator": 3/4 choisit la majorité 

- de "random demonstration": 1/2 (la minorité à autant de jouet) 

On commence par une simulation: 

``` R
## R code 16.6
set.seed(7)

N <- 100 # number of children

# half choose random color
# sample from 1,2,3 at random for each
y1 <- sample( 1:3 , size=N/2 , replace=TRUE )

# half follow majority
y2 <- rep( 2 , N/2 )

# combine and shuffle y1 and y2
y <- sample( c(y1,y2) )

# count the 2s
sum(y==2)/N

plot( table(y) , lwd=12 , col=c(4,0,7) , xlim=c(0.5,3.5) , xlab="" , ylab="frequency" , xaxt="n" )
axis(1,at=1:3,labels=c("unchosen","majority","minority"))
lines( c(2,2) , c(0,sum(y1==2)-2) , lwd=12 , col=2 )
lines( c(2,2) , c(sum(y1==2)+2,sum(y==2)) , lwd=12 , col=2 )
```

le choix de la majorité est un mixte de "random choosers" et de "random followers".

Pour s'en sortir il faut un modèle génératif. On va faire un state-based modèle. 

### State-based model

Stratégies :

1. Majorité

2. Minorité

3. maverick

4. Random color

5. Follow first : copie le premier

$$I_{i} \sim Categorical(\theta) $$ 

$\theta$ vecteur avec la probabilité de chaque choix : probabilité de (1) unchosen, (2) majority, (3) minority.

$$ \theta_{j} = \sum_{S = 1}^{5} P_{s} Pr(Y = j|S ) $$

On moyenne sur les différentes stratégies. $p_{s}$ la probabilité à priori de chaque stratégie S. $Pr(y = j|S)$ la probabilité du choix j en assumant la stratégie S.

$$$p \sim Dirichlet([4,4,4,4])$$

On va le faire avec Stan.

``` Stan
# todo code
```

Definir simplex. 


Ce type de modèle est definit par:

Ce que l'on veut: "latent states"

Ce que l'on a: "Emissions" 

Il y a souvent beaucoup d´incertitude. C'est une grande famille:  mouvement (et particulièrement les stratégies), apprentisage, dynamique des populations, international relations, étude des ménages. 

## Populations dynamics (ODEs)

C'est un processus dans le temps. On mets de coté le modèle linéaire et on a besoin de "latent states" (pouvant varier).

L'estimand est comment différentes espèces interagisses. 

$$ \frac{dH}{dt} = H_{t} * (birth rate) - H_{t} * (death rate) $$

$$ \frac{dL}{dt} = L_{t} * (birth rate) - L_{t} * (death rate) $$

$b_{H}$: taux de naissance des lapins (lièvres).

$L_{t}m_{H}$ effet des lynx sur mortalité des lapins.

Le taux de naissance des lynx dépens des lièvres.

Premier problème: résoudre le nombre, on ne l'a pas on a que leur pelage.

Deuxième problème: transformer les équations différentielles (on passe par une intégrale).

``` Stan
// rajouter le code
```

### Science before statistics

Faire de la science avant les stats (on a bcp parler de stats mais peu de la definition de science). 

Important d'avoir une théorie.

Il faut être patient, pratiquer, les experts apprennent de bonnes habitudes sans danger.   


