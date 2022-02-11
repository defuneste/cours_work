# Ordered Categories

On ne peut parfois pas avoir ce que l'on veut. 

On va travailler sur un cas de variante du "trolley problems"

``` R
library(rethinking)
data(Trolley)
```

Le jeux de données contient 331 individus (âge, genre, niveau d'éducation).

Il a été collecté via des volontaire en ligne. 

Il regroupe 30 différents cas de "trolley problems" regroupant l'action, l'intention et le contact physique. 

Il regroupe 9930 réponses de type "How appropriate (from 1 to 7)"

On est intéressé à comprendre comment un traitement (variante de action, intention, contact) va modifié la réponse R

X (traitement) --> R

Comment A/I/C est associé à d'autres variables.

X --> R <-- S (story)

On a aussi: 

E (éducation) --> R

Y (âge) --> R

G (genre) --> R

Bien sûr:

Y -- > E

G --> E

## Ordered categories

Categories : discrete types (cat, dog, chicken)

Ordered categories: type discret avec un ordre de relation (bad, good, excellent)

Besoin d'un nouveau golem. 

Mais la distance entre chaque valeur n'est pas toujours la même, par exemple il y a une difference entre 4 et 5 et 6 et 7. 

Il y a des "anchor points" par exemple 5 "meh" response. Ces points peuvent être très différents en fonction des individus et des cultures.


Comment transformer cela en une distribution proba ? 

Quand quelque chose est ordonnée, cela signifie que c'est cumulatif au minimum. 

On va le convertir en proportion tous les individus = 1 et on part de 0 (aucun individus)

On va utiliser une fonction logit mais cette fois ci *cumulative* logs-odds. Même si c'est cumulatif la fonction suit les même regles : 0 autour de 50 % -6 impossible et 6 totalement le cas. Dans notre exemple 7 est Inf car 1/0 est dur. Les autres sont les *cutspoints*. Les espaces entre ces *cupoints* sont les *outcomes*. (TODO reprendre le graph).

$$ Pr(r_{i} = k) = Pr(R_{i} \le k) - Pr(R_{i} \le k - 1) $$

Comme c'est cumulée exemple:

$$ Pr(R_{i} = 3) = Pr(R_{i} \le 3) - Pr(R_{i} \le 2) $$

Ie l'axe y, la probabilité cumulée.


$$ log \frac{Pr(R_{i} \le k)}{1 - Pr(R_{i} \e k)} = \alpa_{k} $$

La partie de gauche est le cumulative log-odds et la partie de droite est le cutpoint que l'on cherche à estimer.

C'est les $alpha$ que l'on veut connaître. 

On peut stratifier les cutpoints. mais on peut aussi "offset" chaque cutpoint par la valeur de du modèle linaire $\phi_{i}$.

$$ \phi_{i} = \beta x_{i} $$

$$ log \frac{Pr(R_{i} \le k)}{1 - Pr(R_{i} \e k)} = \alpa_{k} + \phi_{i} $$

$$ R_{i} \sim OrderedLogit(\phi_{i},alpha) $$

Plus phi est grand plus la valeur la plus basse probable (bouger phi vers plus de logg odds dont maintenir la distance entre la valeur cumulée donc tasse les diff de proba entre elles si on bouge vers négatif on tasse les petites valeurs en proba et on augmente les plus hautes).

$$ R_{i} \sim OrderedLogit(\phi, \alpha) $$

$$ \phi_{i} = \beta_{A} A_{i} + \beta_{C} C_{i} + \beta_{I} I_{i} $$ 

A/I/C : action / intention / contact

$$ \beta_{} \sim Normal(0, 0.5) $$

$$ \alpha_{j} Normal(0 , 1) $$


(TODO code dordlogit)

Attention c'est un "voluntary sample". On peut rentrer cela dans le DAG.

E ---> P (participation)

Y ---> P

G ---> P

P est un collider sur E, Y, G. Si on conditionne sur P, E,Y,G covarie avec le sample. Exemple genre et age ne covarie par mais ils peuvent covarier à cause de notre recrutement d'échantillon (endogenous selection). 

L'échantillon est sélectionné sur un collider. Cela peut créer des associations entre variables. On ne peut pas avoir l'effet total de G mais on peut avoir l'effet direct en stratifiant par E et Y.

On peut toujours faire des inférences sur des échantillons biaisés en pensant bien les facteurs de confusion.

### Ordered monotonic predictors

l'éducation est une catégorie ordonnée. 

Il n'y a pas de distance constante entre le niveau. 

1 (elemetary) $ \phi_{i} = 0 $

(pris en charge par alpha, intercepte )

2 (middle school)

$$ \phi_{i} = \delta_{1} $$

3 (some high school) $$ \phi_{i} = \delta_{1} + delta_{2} $$

etc.. C'est l'addition des delta qui assure l'ordre

Pour le max on utilise un \beta E qui est la somme de tout les delta (max effect of education)

$$  \sigma_{0} = 0 $$

$$ \sum^7_{j = 0} = 1 $$ 

La somme de tout les delta doit etre egale à 1. 

Cela nous permet d'avoir:

$$ \phi_{i} = \beta_{E} \sum^{E_{i} - 1}_{j = 0} \sigma_{j} $$

les delta forment un *simplex*. 

(simplex est un vecteur dont l'addition = 1).

Il y a des distribution de probablité pour des distribution de probabilité. 

Un exemple est Dirichlet. 

$$ \sigma \ sim Dirichlet(a) $$

$$ a = [2 ,2 ,2 ,2 ,2, 2, 2] $$

Tous les niveaux d'éducation ont les mêmes effets. 

Plus le nombre dans le vecteur est petit plus il y a de variations. Plus c'est important moins il y a de variations entre eux.

(mais les nombre de vecteur ne doivent pas être nécessairement identique).

Le dirichlet est une généralisation de la distribution beta.

(TODO code)


Cependant l échantillon n'est pas interpretable vu le biais de sélection. Il y a des non causal path (avec notre modèle car il y a des backdoor path).

Il nous faut donc ajouter d'autre variables. On va stratifier par G et Y.

Ici on peut utiliser `threads = 2` car c'est additif. (entre 6 minutes) 

On a besoin de la marginalization pour comprendre les effets de causes. 

Exemple: si on veut l'effet de E il nous faut la distribution de Y et G pour moyenner dessus. Ici ce n'est pas possible car on a P. 

Si on a un modèle génératif on peut tirer des échantillon à posteriori. 

Pour la suite on va regarder plus en détail les stories et les individus. 

Comment faire des estimations sur un grand nombre de paramètres avec peu de data chacun. 


