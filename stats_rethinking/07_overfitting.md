# Overfitting

Quand on a pas une bonne idée de la structure que l'on cherche à atteindre comment on arrive à l'approcher ? 

Le but de cette lecture est de construire de bonne approximation (diffèrent de bonne inférence causale).

## les différents sens/problèmes de prédiction en statistique:

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


