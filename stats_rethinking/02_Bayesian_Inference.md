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
 

### Du *posterior** à la prédiction

Il y a parfois beaucoup de paramètres, un modèle est un résultat de nombreux paramètres simultanément. On prend des échantillons pour l'analyser.

 On va produire un *posterior predictive*

 ``` R
 samples <- sample(p_grid,  prob = posterior, size = 1e4, replace = TRUE)

 w <- rbinom(1e4, size = 9, prob = samples) # posterior predictive
 ```


MCMC ne produit que des échantillons.

On peut utiliser l'echantillonnage pour: 

- Prédiction sur la base de modèle  
- *Causal effects*
- *Counterfactuals*
- comprendre les modèles

On peut les utiliser pour examiner les a priori.  

## Synthèse:

Analyse bayesienne des données: pour toutes possibilités de produire des données on va compter les chemins qui les produisent, les chemins ayant plus de chance sont plus plausibles.
