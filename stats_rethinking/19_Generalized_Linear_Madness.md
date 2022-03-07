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

