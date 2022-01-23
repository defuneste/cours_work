# Good & Bad Controls

Comme il y a un des facteurs de confusion inconnu P est aussi un collider.

On est donc confronté à plusieurs mauvaises décisions:
- avoir l'effet total  
- prendre le risque d'avoir un collider

Il est important d'avoir un moyen de justifier ses choix. 

Quand on stratifie par une variable cela veut dire vérifier les effets pour chaque niveau de cette variable.

Notre travail est de:

1. Clarifier nos hypothèses et présupposé  
2. En déduire les implications  
3. Tester ces implications 

Quelques conseils : 

Éviter d'être malin, ce n'est ni certains ni transparent. 

Il faut écrire des modèles causaux et utiliser la logique en decoulant.  

On peut prendre des DAG complexes et retrouver les quatre types de facteurs de confusion (*fork*, *pipe*, *collider* et *descendant*). Dans certains cas certains éléments peuvent regrouper plusieurs facteurs différents.

## DAG thinking

Simple à utiliser aussi avec des expérimentations. 

Dans une expérimentation on contrôle ce qui a des effets (l'effet est supposé être l'expérimentateur et l expérience isolée).  

(vérifier dans le livre ce qui est entendu par randomisation).

Il y a de temps en temps des procédure statistiques permettant la randomisation. 

$$ P(Y|do(x)) = P(Y|?) $$

Ici P est a prendre comme une distribution probabiliste.

$do(X)$ signifie intervient sur X.

###  Un facteur de confusion simple:

X -> Y

U -> X 

U -> Y

U est le facteur de confusion (fork). Pour refermer la fourche il faut conditionner en fonction de U.

Dans une expérimentation on peut complètement ignorer U (retirer ses effets) et randomiser X.

$$ P(Y|do(X)) = \sum_{U} P(Y|X,U)P(U) = E_{U}P(Y|X,U) $$

La distribution de Y, stratifier par X et pondère sur la distribution de U. 

Les effets de causalité (une intervention) entre X et Y ne sont pas (en général) juste les coefficients reliants X et Y.

C'est la distribution de Y quand on change X sur les distributions des variables de contrôles (ici U).

#### un exemple avec "Marginal Effects"

Baboons -> gazelle

Cheetahs eat both 

Quand les cheetahs sont présentes les baboons ont pas d'effets sur les gazelles car ils en ont peur.

Si les Cheetahs sont absentes les baboons mangent des gazelles.

Les effets des baboons dépends de la distribution des cheetahs.

## do-calculus

Il dit si c'est possible ou pas. Ce sont des règles pour trouver P(Y|do(X)). 

do-calculus worst case : rajouter des présupposes supplémentaire renforce l'inférence

best case : si l'inférence est possible en utilisant do-calculus il ne dépend pas d'autres hypothèses

Une bonne partie du job mise en place par Judea Pearl.

### Backdoor criterion

c'est une règles pour trouver un ensemble de variable pour stratifier ou conditionner avec $P(Y|do(X))$. 

Il y a: 

1. Identifier tous les chemins de connections du traitement X a la sortie Y

2. On se concentre sur tous les chemins qui entre dans X, ils sont appelées *backdoor paths*.

3. Il faut trouver *l'adjustement set* ce sont les variables qui ferme les backdoor path.

(reprendre les dessins)

www.dagitty.Net

Il faut faire attention en stratifiant a ne pas ouvrir et fermer d'autres chemins.

## Good and Bad Controls

Une variable introduite dans une analyse juste pour le besoin d'estimer une intervention.

Pas mal de façon de faire:

- on prend tous: YOLO!

- on prend toutes celles qui ne sont pas colinéaires 

- on prends tout ce qui a été mesuré avant le traitement 


ref: A Crash Course in Good and Bad Controls  2021

Premier exemple de Bad Controls avec un cas de type social network et où stratifié par Z reviens à ouvrir un backdoor path 

Ici ce n'est pas une bonne idée d'utiliser Z en pré traitement

une règle: on ne touche pas au collider! 

Il faut faire attention au "case control biais" quand on conditionne en Z on explique un part de la variation de Y et X à moins a expliquer. Z est pas une cause de Y mais les stats ne font pas la distinction. 

"Precision parasite" on augmente la variance.

variante "bias amplification"


