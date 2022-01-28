# Markov Chain Monte Carlo MCMC

Les moyens pour calculer la distribution posterieur

1. Approche analytique (souvent impossible)

2. Grid approximation (très intensif)

3. Quadratic approximation (limité: tous les problèmes ne sont pas gaussien)

4. Markov Chain Monte Carlo (intensive)

MCMC est plus gourmand mais à ce point. 

## Une analogie pour comprendre 

On a un roi Markov, il gouverne un archipel Metropolis qui comporte un certain nombre d'îles (différente tailles). Il a promis de visiter ses administrés en proportion de la taille de leur Îles.

Étape 1: il visite une île et à la fin il jette une pièce:
        - 1/2 il va à droite   
        - 1/2 il va à gauche 
        
L'île où il va s'appelle *proposal island* 

Étape 2: il demande la taille de la population ($p5$) 

Étape 3: il compare cette taille à la taille de l'île précédente ($p4$)

Étape 4: Il s'y déplace avec une probabilité = $\frac{p5}{p4}$

Si la proba est plus elevé que 1 il s'y déplace sinon il tire la proba. 

Étape 5: on répète en 1
        
Cette procédures vérifie que le roi Markov va visiter chaque île en proportion de sa taille (sur un temps long). 

### Une définition plus formel:

Est utilisé pour tirer des échantillons à partir d'une distribution posterieur. 

Les îles sont des valeurs de parmètres. 

La taille de la population sont la probabilité posterieur. 

On a donc une visite de chaque valeur de paramètre en fonction de la probabilité à posteriori. 

Marche pour toutes les dimensions (paramètres) possibles. 

On a pas besoin de passer par l'évaluation totale de toutes les possibilités comme dans la méthode de grid approximation. 

On l'appel une *chain* car c'est une séquence de tirage à partir d'une distribution. 

Ce sont des *Markov Chain* car l'histoire n'a pas d'importance où il va ensuite ne dépend que de la où il est. 

*Monte carlo*: un algorithme de randomisation.  

L'algorithme utilisé est celui dit "*Metropolis algorithm*". Une version simple de MCMC. Simple à écrire, très générique et souvent peu efficient.

Arianna Rosenbluth travaillait sur un ordinateur dont le nom était MANIAC (Mathematical Analyzer Numeric Integrator, and Computer).

Il en existe des nouveaux. Les meilleurs méthodes utilisent des *gradients* (on utilise la courbure de ce que l'on étudie).

Ce cours mobilise *Hamiltonian Monte Carlo*.  

Ce type d'algorithme ne travail que localement. 

## Hamiltonian Monte Carlo

Une analogie avec le skateboard dans une piscine/skateparc. Le skate passe peu de temps dans en haut pour des raisons de gravité.

On lance le skate et on note où il s'arrête. Le point où il s'arrête est un tirage dans la distribution posterieur. 

Pour que cela marche on a besoin de connaître le gradient ou la courbure. Ces méthodes ont aussi besoin d'être ajustée (stepsize, length, trajectories). 


L'idée est de trouver la courbure global à partir de tas de la local en s'y deplacant comme le skateboard. 

 p276-278 détail de l'algorithme. La part difficile est de calculer le gradient. 
 
## Calculus is a superpower. 
 
On utilise **Auto-diff**: Automatic differentiation 

Cela permet de calculer le *symbolic derivatives* du modèle définit. Une matrice de dérivée, parfois appelée jacobian. En apprentissage machine: backpropagation (cas particulier d'auto-diff).  

Stan vient de Stanislw Ulam (1909-1984).

## HMC en pratique

Voici un exemple que l'on a déjà utilisé et voici son implèmentation en quap.

 ``` R
library(rethinking)
data(WaffleDivorce)
d <- WaffleDivorce

dat <- list(
  D = rethinking::standardize(d$Divorce),
  M = rethinking::standardize(d$Marriage),
  A = rethinking::standardize(d$MedianAgeMarriage)
)

f <- alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bM*M + bA*A,
  a ~ dnorm(0, 0.2),
  bM ~ dnorm(0, 0.5),
  bA ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
)

mq <- quap( f , data = dat)

library(cmdstanr)
mc.cores = parallel::detectCores()
mHMC <- ulam( f , data = dat)
precis(mHMC)

```

## Pure Stan approach

ulam sert a construire du code stan.

Stan code est "portable" et tourne sur tout. 

On peut afficher le code de stan en utilisant la fonction `stancode`

``` R
rethinking::stancode(mHMC)
```


```
data{
    vector[50] D;
    vector[50] A;
    vector[50] M;
}
parameters{
    real a;
    real bM;
    real bA;
    real<lower=0> sigma;
}
model{
    vector[50] mu;
    sigma ~ exponential( 1 );
    bA ~ normal( 0 , 0.5 );
    bM ~ normal( 0 , 0.5 );
    a ~ normal( 0 , 0.2 );
    for ( i in 1:50 ) {
        mu[i] = a + bM * M[i] + bA * A[i];
    }
    D ~ normal( mu , sigma ); 

```


Le haut de stan reprend les données. Ici on a 50 car c'est le nombre d'états que l'on a et vector c'est le type de données. 

Il faut dire ce que le computer doit gérer en mémoire. Cela permet d'éviter pas mal de debugging.

La suite correspond au paramètres. Stan a besoin de savoir le type pour y appliquer différentes check et contraintes.

Ex: sigma à une contrainte indiquant qu'il doit être positif.

Enfin on a le modèle utilisé pour produire la distribution à posteriori. 

On sauve le code de Stan dans son fichier. On peut ensuite utiliser la fcontion `rethinking::cstan` pour passer se fichier à stan. 

``` R
mHMC_stan <- cstan(file = "08_mHMC.stan", data = dat) # exemple
```


## Introduction des technique pour estimer ses resultats

### Faire de graphs 

#### trace plots

La region grise est le "warmup" c'est le moment ou Stan va configurer le stepsize etc.. 

On doit le faire pour chaque paramètres. On vérifie qu'ils partent pas n'importe comment. Il doit être stationnaire.   

Il est bien de ne pas utiliser qu'une chaîne mais plusieurs. Cela permet d'assurer que chaque chaîne explore le bon coté de la distribution et que chaque chaîne explore la mêmes distribution. On appelle ce la **convergence**.

  ``` R
 mHMC <- ulam( f , data = dat , chains = 4, cores = 4) 
 ```

#### Trace Rank (trank) plots
 
On utilise des valeurs en rang cela permet de voir si une chaîne est trop en dessus/dessous.

### R-Hatfield

Si des chaînes converges: 

- Le départ et la fin de chaque chaîne explorent la même zone.

- Les chaînes independante explorent la même zone.

R-hat est un ratio de variances: quand la variance total se rapproche de la variance intra chains R-hat tend vers 1


### n_eff 

Estime le nombre effectif d'echantillons. 

> How long would the chain be, if each sample was independant of the one before it? 

Quand les échantillons sont autocorrelés ont a moins de n_eff. 

### Divergent transitions

De temps il y a des propositions (cf. l'analogie avec le roi Markov) qui sont rejetés. Si ils y en trop c'est possible que l'on est une explication faible et de possible biais. 

### Exemples de mauvaises chaînes

On passe de *hairy caterpilar* à des montages russes. 

> When you have computational problems, often there's a problem with your model."

Andrew Gelman: "the fold theorem of statistical computing"  


