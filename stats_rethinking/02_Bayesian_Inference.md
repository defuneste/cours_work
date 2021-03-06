# Bayesian inference

Vidéo: https://www.youtube.com/watch?v=guTdrfycW2Q&list=PLDcUM9US4XdMROZ57-OIRtIK0aOynbgZN&index=3

NB: J'ai complété avec la lecture du chapitre 2

## Premier exemple: la Terre

On connaît la répartition terre/eau grâce à son observation mais on pourrait imaginer des météorites s'écrasant aléatoirement à sa surface et en déduire cette répartition.

Un premier jeux de données:

`LWLLWWWLWW`

L: Land
W: Water

Comment utilise t on cet échantillon? Comment le résume t on ? Comment représente t on l'incertitude?

On va compter tous les chemins que peuvent prendre le jeux de données. Les chemins les plus nombreux sont les plus possibles.

Dans le cas de notre exemple toutes les proportions eau/terre sont possibles: de 0 à 1. C'est un cas un peu complexe alors on va partir d'un cas un peu plus simple: des billes dans un sac.

### Détour par les billes dans un Sac

Le cas contient 4 billes, certaines sont bleus d'autres blanches. On ne connaît pas leur proportion.

Il y a cependant 5 possibilités:

(1) `WWWW`  
(2) `BWWW`  
(3) `BBWW`  
(4) `BBBW`  
(5) `BBBB`  

On a pris un échantillon `BWB`.

Combien y a-t-il de chemins possible pour obtenir cette observation?

Prenons le cas (2) pour commencer, qu'est ce que cela signifie?

On va utiliser *the garden of forking data*.

Premier tirage: 3W et 1B
    Second tirage (pour chaque possibilité obtenu au préalable): 3W et 1B
        Troisième tirage (idem): 3W et 1B

Pour ce cas cela fait 4 x 4 x 4.

Si on compte:

-  chemins possibles pour 1B premier tirage: 1

-  chemins possibles pour 1B puis 1W second tirage: 3

-  chemins possibles pour 1B puis 1W puis 1B troisième tirage: 3

On a donc 3 chemins possibles pour produire notre échantillon si on assume une des possibilités (la (2)). L'échantillon nous permet d'exclure les possibilités (1) et (5) car elles ne peuvent se réaliser.

Si on prend la possibilité (3):

- 2 chemins possibles pour 1B au premier tirage

- 4 chemins possibles pour 1B -> 1W au second tirage

- 8 chemins possibles pour 1B -> 1W -> 1B au troisième tirage


Si on prend la possibilités (4): 6 chemins possibles

Si on récupère toutes possibilités:

| Possibilités | *p*  | Billes | Chemins | plausibilité |
|:------------:|------|:------:|:-------:|--------------|
| (1)          | 0    | WWWW   | 0       | 0            |
| (2)          | 0.25 | BWWW   | 3       | 0.15         |
| (3)          | 0.5  | BBWW   | 8       | 0.40         |
| (4)          | 0.75 | BBBW   | 9       | 0.45         |
| (5)          | 1    | BBBB   | 0       | 0            |

> Things that can happen more ways are more plausible

*P* est la probabilité de bleu. C'est définit comme la probabilité a priori (*prior posibility*).

la plausibilité pour chaque possibilité est son nombre de chemins divisés par le nombre de chemins possible ou parfois appelé le *Likelihood*. Dans des cas plus complexes c'est une fonction de distribution associée à une variable.


``` R
chemins <- c(3, 8, 9)
chemins/sum(chemins)
```

On peut mettre à jour notre raisonnement avec plus de données: "*Bayesian updating*" (mise à jour bayesienne ?).

Ici on tire une autre bille bleu:

| Possibilités | chemin 1B | a priori | *count* |
|:------------:|:---------:|:--------:|:-------:|
| WWWW         | 0         | 0        | 0       |
| BWWW         | 1         | 3        | 3       |
| BBWW         | 2         | 8        | 16      |
| BBBW         | 3         | 9        | 27      |
| BBBB         | 4         | 0        | 0       |

Les règles sont:

1. Avoir un modèle explicatif de comment chaque observations est produite en fonction de toutes les possibilités, dans le livre c'est la *data story* ou comment sont produites les données.
2. Compter les moyens de produire ce que l'on observe pour chaque possibilités
3. Les plausibles le sont par rapport aux options de (2).

Deux principes à garder en tête :

- la certitude du modèle n'en fais pas forcement un bon (formulé autrement cela indique qu'il est confiant dans son "*small world*" pas qu'il colle au "*big world*")
- il est important de comprendre ce qui est mis de coté par le modèle et ce qu'il fait comme inférence

### On retourne au globe

> `density`: relative plausibility of proportion of water

La courbe, avec l'augmentation du nombre d'échantillon, devient de plus en plus haute et mince. Le nombre de plausibles relatifs est fixe, la somme de proportion est toujours de 1.

La surface en dessous de la courbe représente une somme de 1.

On peut bien sûr faire l'ensemble de la procédure d'un coup mais elle peut aussi être décomposé comme dans la vidéo.

#### On peut retenir:

1. Pas de taille minimale d'échantillon, 0 est même suffisant (pour comprendre le modèle).

2. Toute la forme de la courbe reprend la taille de l'échantillon.

3. Pas d'estimateur ponctuel (central ?), l'estimateur est la courbe.

> The **distribution** is the estimate

> Summary is always the last step

4. Il n'y a pas "un" intervalle (95%, 89% etc..)

Rien de particulier apparaît à leur limite, il n'y a pas de frontière "physique".

Dans le cadre d'analyse bayesienne il n'y pas de contrôle d'erreur (*error control*) à base d'intervalles.

## Formaliser ce que l'on nos premiers exemples

Le premier travail est d'écrire nos hypothèses et toutes leurs probabilités.

Il y a deux types de variables les données (*data*) et des paramètres (*parameters*). Les paramètres sont, en général ce qui n'est pas observé. 

*data* :
- $W$: nombre d'W observé
- $L$: nombre d'L observé


$$Pr(W, L|P) = \frac{(W+L)!}{W!L!}p^{w}(1-p)^{L}$$

Ou: le nombre de chemin pour faire W et L en fonction de $p$

C'est une fonction de probabilité binomiale (ici est utilisée pour faire notre décompte de type *garden of forking paths* )

``` R
W <- 6
W_L <- 9 # nombre de tirrage ou size
P <- 0.5 # probabilité d'avoir l'un ou l'autre, ici fixé
dbinom( W, W_L, P)
```

Dans R les distributions ont une lettre avant:
- *d* correspond à *density*
- *r* à *random samples*
- *p* aux probabilités cumulées

Ici notre paramètre $p$ correspond à la proportion d'eau sur le globe

$$Pr(p) = \frac{1}{1-0} = 1 $$

Ici on prend une constante, 1 est pratique car maintient l'aire en dessous la courbe sera ainsi d we 1. On peut prendre n'importe quel valeur car on va pondérer mais 1 est pratique.

Le *posterior* est le produit normalisé

$$ Pr(p|W,L) = \frac{Pr(W,L|p)Pr(p)}{Pr(W,L)} $$

C'est la plausibilité relative de chaque valeur de p après avoir appris W,L. Ou encore avec Bayes:

Posterior = (probability of the data  x Prior)/average probability of the data

 Il y a des tas de façon de compter (MCMC, quadratic approximation). Ici c'est une *grid approximation*
 
1. Définir la grille : combien de points sont nécessaire pour le *prior* puis une liste des valeurs des paramètres. 
2. Calcul des valeurs du *prior*  pour chaque valeur de la grille
3. Calcul du *likelihood* de chaque paramètres 
4. Calcul du *posterior*  non standardisé pour chaque paramètres
5. Standardisation du *posterior* en divisant par la somme de toutes les valeurs.

L'échantillonnage est un moyen de transformer un problème compliqué de math en un problème de synthèse des données.


 ``` R
 p_grid <- seq(from = 0, to = 1, length.out = 1000) # definition de la grille (1)
 prob_p <- rep(1 , 1000) # un prior flat 1 (2)
 prob_data <- dbinom(6, size = 9, prob = p_grid) # ici prob reprend une grille (3)
 posterior <- prob_data * prob_p # (4)
 posterior <- posterior / sum(posterior) # standardisation (5)
 ```
 
 
### Du *posterior* à la prédiction

Il y a parfois beaucoup de paramètres, un modèle est un résultat de nombreux paramètres simultanément. On prend des échantillons pour l'analyser.

 On va produire un *posterior predictive*

 ``` R
 samples <- sample(p_grid,  prob = posterior, size = 1e4, replace = TRUE)

 w <- rbinom(1e4, size = 9, prob = samples) # posterior predictive
 ```

 On peut utiliser l'échantillonnage pour: 

- Prédiction sur la base de modèle  
- *Causal effects*
- *Counterfactuals*
- comprendre les modèles

On peut les utiliser pour examiner les a priori.  

## Synthèse:

Analyse bayesienne des données: pour toutes possibilités de produire des données on va compter les chemins qui les produisent, les chemins ayant plus de chance sont plus plausibles.

## Sampling the Imaginary (ch03 livre)

La vidéo l'aborde peut alors je reprends mes notes sur le chapitre.

Ici j'ai l'impression que l'imaginaire fait référence à la fois aux probabilités (qui n’existe pas) et aux paramètres qui sont souvent en dehors de notre capacité de mesure.

r(positive test result|vampire) = 0.95  
Pr(positive test result|mortal) = 0.01  
Pr(vampire) = 0.0011  

$$Pr(vampire|positive) = Pr(postive|vampire)Pr(vampire)/Pr(positive)$$

Pr(positive) est le résultat positif d'un test = Pr(positive|vampire)Pr(vampire) + Pr(positive|mortal)(1-Pr(vampire))


``` R
Pr_Positive_Vampire <- 0.95
Pr_Positive_Mortal <- 0.01
Pr_Vampire <- 0.001
Pr_Positive <- Pr_Positive_Vampire * Pr_Vampire +
               Pr_Positive_Mortal * ( 1 - Pr_Vampire )
( Pr_Vampire_Positive <- Pr_Positive_Vampire*Pr_Vampire / Pr_Positive )
```
Seulement 8.7% des cas détectés comme vampire le sont bien.

Ce que montre cet exercice c'est que même si on a un test fiable si ce que l'on test est quelque chose de rare on va, à cause de faux positifs se retrouver avec un résultat qui a peu de valeur.

L'auteur n'aime pas cet exemple qui aurait très bien être donné dans un cas fréquentiste et qui utilise une formule un peu tombée du ciel. (elle se comprend mais j'ai eu besoin de l’écrire)

Il existe une autre manière de présenter ce problème :

- Dans une population de 100 000 personnes, 100 sont des vampires
- Sur ces 100 vampires 95 sont détectés
sur les 99 900 mortels, 999 sont détectes comme vampire (faux positif)

Ici on a juste besoin de compter : 95 / (95 + 999) = 0.087

Ce type d'approche est dite *frequency format* ou *natural frequencies*. C'est plus intuitif car on rencontre plus souvent des fréquences que des probabilités.

> "In any event, randomness is always a property of information, never of the real world"

Je suis d'accord avec cette phrase mais c'est plus une vision des choses que quelque chose de démontrable.

Ce chapitre enseigne les connaissances de base pour travailler avec des échantillons à partir de la distribution postérieure. Les raisons de le faire y compris sur des cas simples sont que l'on est mauvais en calcul d’intégral mais plutôt bon sur la synthèse de données. Travailler avec des échantillons transforme un problème de calcule en un problème de fréquence. Ensuite les méthodes comme les Markov chain Monte Carlo (MCMC) produisent des échantillons. 


### Echantillonnage sur une approximation du posterieur par une grille

 ``` R
p_grid <- seq( from = 0 , to = 1 , length.out = 1000 )
prob_p <- rep( 1 , 1000 ) # aka prior
prob_data <- dbinom( 6 , size = 9 , prob = p_grid ) # aka likelihood
posterior <- prob_data * prob_p
posterior <- posterior / sum(posterior)

samples <- sample( p_grid , prob = posterior , size = 1e4 , replace = TRUE )

plot( samples )

library("rethinking")
rethinking::dens(samples)

 ```
 
### Echantillonner pour résumer
 
Une fois le model calculé c'est terminé pour lui et c'est au scientifique de faire son travail.

Trois types de questions :

1. Intervalles de limites  
2. Intervals comprenant une masse de probabilités définit  
3. Estimation de points  
 
#### Intervales de limites définies

Question : probabilité posterior que la proportion d'eau soit moins de 0.5 ?
 
 ``` R
 sum( posterior[ p_grid < 0.5 ] ) # la ruse est ici que les deux veteurs sont de meme longeur on index par un immense vecteur True/False
 ```
 
C'est simple mais on a ici l'approximation par grid qui n'est pas toujours disponibles.

Si on prend l'échantillonnage :

``` R
sum( samples < 0.5 ) / 1e4
```

Ici on compte toutes les valeurs de samples qui correspondent à la condition divisées par le nombre d’échantillons ($1e4$). 

#### Intervals d'un volume défini

Les intervals de confiance sont des intervals d'un volume défini (*Intervals of defined mass*). Les intervals sur lesquels on va travailler devrait plutôt être nommés **interval crédible** pour les intervals sur des postérieurs.

Ici c'est plus simple d’utiliser les échantillons que la proba obtenue par l'estimation par grille.

Si on veut la proportion de la limite inférieur des 80 % ou encore les 80% centraux. C'est possible en une ligne :

``` R
quantile(samples , .8)
quantile( samples , c( 0.1 , 0.9 ) )
```

On va ici les appeler les *Intervals percentils* (pourcentil d'intervals ?). C'est bien dans le cas de distribution pas trop asymétrique. Si on prend le cas d'une distribution postérieur avec un priori uniforme et 3 tirage d'eau : on a une forte probabilité proche de 1 que les intervals ne prennent pas bien en compte. 

Voici la distribution :

 ``` R
p_grid <- seq( from = 0 , to = 1 , length.out=1000 )
prior <- rep(1, 1000)
likelihood <- dbinom( 3 , size = 3 , prob=p_grid )
posterior <- likelihood * prior
posterior <- posterior / sum(posterior)
samples <- sample( p_grid , size = 1e4 , replace = TRUE , prob=posterior )
dens( samples ) 
 ```

Exemple : {rethinking} a une fonction PI() pour faire des intervals percentils :

``` R
PI(samples, prob = 0.5)
```

Ici on exclue la proba avec la plus de chance (1) donc c'est pas fou.

On peut plutôt utiliser le HDPI : *Highest Posterior density interval*. C'est, comme son nom, l'indique intervalle qui prend en compte la plus forte densité.

``` R
HPDI(samples, prob = .5)
```

Dans le cadre d'une gaussienne, ils sont pareils. HPDI est plus gourmand en calcul et est plus sensible au nombre d’échantillons que le pourcentils intervals.

#### Estimation d'un points

En prenant en compte la distribution de l'ensemble de la distribution postérieure qu'elle valeur doit on prendre ? L'estimation bayésienne est l’ensemble de la distribution donc prendre un seul point est loin d'être toujours une bonne idée.

Un premier point utile est celui avec le plus de probabilité à posteriori. Il est appelé le MAP : *maximum a posteriori*

``` R
p_grid[ which.max(posterior) ]
```

On peut aussi obtenir le mode (sur les échantillons), la moyenne ou la médiane. Pour savoir lequel choisir on peut utiliser une *loss function**. L'idée est que la perte (si on mise une somme) est proportionnelle à l’écart à la bonne réponse. Apparemment c'est la médiane qui maximise nos gains.

Ici p = 0.5 comme décision

``` R
sum( posterior*abs( 0.5 - p_grid ) )
```

Si on calculer pour toutes les valeurs de p (dans l'approximation par grille) on passe par un sapply :

``` R
loss <- sapply( p_grid , function(d) sum( posterior*abs( d - p_grid ) ) )
```

Puis on peut demander ce qui minimise nos pertes:

``` R
p_grid[ which.min(loss) ]
```

Ce qui est très proche de la médiane. Dans ce cas on a utiliser la "perte absolue". Si on avait pris la perte quadratic $(d-p)²$ qui conduit à la moyenne.

#### Échantillonner pour simuler

Un autre outils courant des échantillons est lors de simulations. Produire des observations à partir d'un modèle est utile pour plusieurs raisons :

- *Model design* : on peut échantillonner sur le posterior mais aussi sur le prior pour vous ce que le modèle suppose.   
- *Model Checking** : Après la collecte de données on peut vérifier si il correspond bien aux données.  
- *Software validation* : on peut aussi vérifier ce que fait le logiciel  
- *Research design* : On peut faire des simulations pour tester le design de capture de données, par exemple une analyse de puissance  
- *Forecasting*  : On peut faire des prédictions et comparer nos prédictions aux données

#### Dummy data

Les fonctions de Likelihoods marchent dans les deux sens (c'est surtout du à nos hypothèses dont le fait que le nouveau tirage n'influe pas le prochain tirage je trouve). En fonction des observations passées on peut savoir la plausibilité d'une nouvelle observation et en fonction des paramétrés on peut définir un likelihood qui va produire une distribution dans lequel on peut échantillonner pour simuler des observations.

On appelle ce type d'observations *dummy data* pour les distingués des observations réelles.

Likelihoods semble se traduire par vraisemblance. La fonction de vraisemblance du jeté de globe est une binomiale.

En prenant deux lancés, les possibilités d'avoir de l'eau sont 0, 1 ou 2 et si on prend 70% de couverture d'eau cela donne :

``` R
dbinom( 0:2 , size=2 , prob=0.7 )
```

Soit 9% d'avoir 0 eau, 42% d'en avoir 1 et 49% 2.

Si on veut échantillonner cette distribution on peut utiliser `sample` mais R fourni un moyen plus simple pour les fonctions "classiques" :

``` R
rbinom( 1 , size=2 , prob=0.7 )
```

Ici c'est pour un échantillon de taille de 1 qui nous retourne 0 si 0 eau sur deux lancé, 1 pour un eau pour 2 lancé et 2 pour deux eau. r devant binon signifie random.

On peut en faire 10k :

 ``` R
dummy_w <- rbinom( 1e5 , size=2 , prob=0.7 )
table(dummy_w)/1e5 
 ```

On est proche des valeur de proba mais on sera toujours un peu fluctuant.

``` R
dummy_w <- rbinom( 1e5 , size=9 , prob=0.7 )
simplehist( dummy_w , xlab="dummy water count" ) # attention c´est une fonction de rethinking (pas ultra sexy de plus) mais qui gagne du tps
```

> "In neither case is “sampling” a physical act. In both cases, it’s just a mathematical device and produces only small world"

Ici je pense qu'il y a une polysémie sur samples. Un échantillonnage spatial me semble correspondre à un "physical act".

#### Model checking

Il faut vérifier que le modèle marche correctement et répond au objectif.

Il faut vérifier si le programme utilisé fait bien ce que l'on souhaite.

##### le model est il adéquate ?

Ici comme le modèle est par définition inexacte il est important de regarder quel part des données n'est pas bien retranscrit. Pour le moment nous allons apprendre à combiner l échantillonage sur simulations avec l'échantillonnage sur les paramètres à partir de la distribution posterieur.

Il y a d'abord l'incertitude des observations. Pour chaque valeur du paramètre de *p* il y un unique patrons possible d'observations que le modèle implique. Même si on connaît *p* on ne sait pas ce que les observations vont nous retourner (sauf pour p = 0 ou 1). Il y a aussi une incertitude sur la valeur de *p* (et donc sur tout ce qui dépend de *p*). Pour chaque valeur de *p* on peut générer des distributions postérieures. On peut générer des échantillonnages pour chacune de ces distributions, en faire une moyenne que l'on va nommer la *posterior predictive distribution*.

Prendre en compte qu'un seul paramètre de *p*, le plus probable conduit à surestimer.

``` R
w <- rbinom( 1e4 , size=9 , prob=0.6 ) # pourgénerer un sampling
w <- rbinom( 1e4 , size=9 , prob=samples ) # ici la prob est "propagés"
```

Comme les valeurs échantillonnée de p sont proportionnelles à la distribution posterieure.

Pour le momemt on est partit du principe que chaque tirage est independant. Ce qui meme dans notre cas de lancement de globe est peu probable avec par exemple une présence concentré des terres/mers.

Si on prend un tirage de 9 globes : W L W W W L W L W

La plus grande serie du meme type est 3 (W W W), le nombre de changement d'un état à un autre est 6. Ce sont deux facon de mesurer la corrélation entre les échantillons. On peut produire des simulations et regarder ou sont représenter ces mesures dans nos simulations.

### conclusion

Ce chapitre visait à introduire les distributions postérieures. Les fondements de nos techniques est de tirer dans ces distributions ce qui transforme un problème d'intégrales à un problèmes de synthèses. Les vérifications des prédictions du posterieur combine l'incertitude des paramètres décrits par distribution postérieure avec l'incertitude des résultats décrit par la fonction de vraisemblance.


