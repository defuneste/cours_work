# Overfitting

Quand on a pas une bonne idée de la structure que l'on cherche à atteindre comment on arrive à l'approcher ? 

Le but de cette lecture est de construire de bonne approximation (diffèrent de bonne inférence causale).

## Les différents sens/problèmes de prédiction en statistique:

Quelle fonction décrit ces points ? On parle de *fitting*. 

C'est différent de savoir ce qui explique ces points. (*causal inference*)

C'est encore différents de: que ce passe-t-il si je change un points? (*intervention*)

Enfin: quel est la prochaine observation du même processus ? (*prediction*) 

### Leave-one-out cross-validation

1. Drop one points

2. Fit line to remaining

3. Predict dropped point (using previous lines)

4. Repeat 1. with next point

5. On compte (*score*) l'écart entre la prédiction du point et sa localisation 

On va comparer le *in sample error* avec le *out of sample score*.

Dans un contexte bayesien on ne va pas utiliser chaque point mais la distribution postérieur. 

On utilise *log pointwise predictive density* (lppd)

$$ lppd_{CV} = \sum_{i=1}^{N}\frac{1}{S}\sum_{s = 1}^{S} logPr(y_{i}|\theta_{-i,s}) $$

Livre p 210 and 218

$N$ data points

$S$ échantillons sur la distribution postérieur

Le dernier terme est le log de la probabilité a chaque point de i, calculé sur la distribution postérieur omettant le point i.

C'est une somme sur S car on moyenne le log de la proba pour chaque point i sur l'ensemble des échantillons que l'on tire.

Cela nous permet de retomber sur une densité. 

On peut changer le modèle ie passer d'un modèle linéaire simple à une fonction quadratique. Le modèle est meilleur en *in sample error* mais moins bon en *out of sample error*. C'est assez classique plus on ajoute de la complexité dans le modèle plus il va bien se caler sur l'échantillon et souvent (mais ce n'est pas une constante) ils sont donc plus sensible sur du *out of sample*.

### Cross-validation

Pour des modèles simples augmenter le nombre de paramètres améliore la description. Mais cela peut réduire la precision de la prediction *out of sample*. C'est souvent un compromis entre la flexibilité du modèle et l'*overfitting*.

*Overfitting*: apprendre des informations de l'échantillon qui ne sont pas récurrentes avec le processus que l'on cherche à étudier.  

> Fitting is easy but prediction is hard.

### Regularization 

CV mesure overfit. Cela marche en mettant de coté des données.  

L'overfitting est un produit de la flexibilité et il y a de nombreuses façon de produire de la flexibilité. L'une d'entre elle est le prior. Des a priori très large sont flexibles. On peut aussi utiliser des à priori dit sceptiques (*skeptical prior*). 

La régularisation tire son nom car on va utiliser des caractéristiques régulière du process. Il y a des caractéristiques irrégulières dans un échantillons et l'objectif est que le modèle apprennent sur celles qui sont régulières. 

On peut aussi *underfitting*. 

On prend un exemple avec un mode linèaire avec un polynome et on regarde l'effet du prior de $\beta$ sur le *in et out of sample*. 

On commence avec un prior de type $Normal(0 ,10)$ ce qui signifie une variance de 100 ce qui est quasiment plat sur des données standardiser. si on passe à $Normal(0 , 1)$ on reduit un le *out of sample*. si on prend $(0 ,0.5)$ on reduit encore le *out* par contre on commence à augmenter l'erreur *in*. 

Si l'a priori est trop sceptique il y a risque que l'on soit très loin. 

L'idée est surtout de faire un peu mieux qu'un a priori plats. 

#### Comment régulariser les a priori 

Pour de l'inférence causale on doit utiliser la science.

Pour de la prédiction pure on peut utiliser des technique de CV. 

Bien sûr on est toujours un peu entre les deux. Il faut à la fois essayer de comprendre la structure (science) et jouer sur la prédiction.

Pas besoin d'être parfait juste de faire mieux.

## Prediction penalty

Si on prend la différence entre le *in* et *out of sample* on peut calculer la *PRediction penalty*.

Plus le nombre d'échantillons est important plus le cout de la CV est important (on va caler N modèle pour N points).

Peut-on le faire avec un seul modèle? Oui on va voir deux de ces méthodes. 

- Importance sampling (PSIS)

- Information criteria (WAIC)

### Importance sampling

On prend une distribution postérieur et on l'utilise pour calculer les distributions de N - 1 points. 

Tous point avec une faible proba, définit par le modèle, a une forte influence dans la distribution postérieure. Si ce point n'est pas présent à quoi ressemble la distribution postérieure. 

Le problème est qu'on estime la distribution postérieur on ne l'a pas. Cette estimation peut être très variable surtout si on a peu d'échantillons. Pour compenser cela un type d'échantillon est utilisé:  *Pareto-smoothed importance sampling* (PSIS). Il est plus stable. Cette méthode permet aussi d'identifier des outliers. 

## Akaike Information Criterion (AIC)

Marche pour des priors plats et des grands échantillons.

Maintenant on utilise *Widely Applicable IC* (WAIC).

$$ WAIC(y, \circleddash) = -2(lppd -\sum_{i}var\circleddashedlog p(y_{i|\circleddah})) $$

Tous ce qui est dans la somme est une manière de calculer une pénalité.

WAIC, PSIS, CV servent a mesurer l'*overfitting*.

La régularisation peut servir a gérer l'overfitting.

## Model Mis-selection

Pas une bonne idée d'utiliser ce type de technique pour une inférence causal. 

Les critères prédictifs préfèrent les facteurs de confusion et les colliders.   

## Outliers and robust regression

Certains points ont plus de poids. Si un modèle a des outliers cela risque de conduire à un modèle trop confiant dans ces prédictions. 

Dans le cas de la gestion des risques les outliers sont très importants. 

> don't discreminate against data point it's not their fault


Virer les outliers est une mauvaise chose car cela nous amène à ignorer le problème.

c'est le modèle qui est mauvais pas les données. 

La régression linéaire est mauvaise avec les outliers. On peut utiliser *robust regression* 

Un modèle gaussien assume que la variation est la même partout et donc très surpris des outliers.

si on mixe ensemble un bon paquet de distributions gaussiennes on obtient un *student-t* distribution. Elle plus épaisse (dense) aux extrémités et donc gère mieux les valeurs extrêmes. 

 ``` R
 ## le code n'est pas complet j'ai juste repris la partie changeante

 D ~ dnorm(mu, sigma)
                                        # devient
 D ~ dstudent( 2 , mu , sigma ) # c'est dans rethinking
 
 ```

Il y a pleins de cas influents les données que l'on a pas mesurés (*Unobserved heterogeneity*).

## Synthèse

Il est possible de faire des bonnes prédiction sans connaître les causes. 

Il faut cependant optimiser la prédiction avec les outils vu dans cette vidéo.  
