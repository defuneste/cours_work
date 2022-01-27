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
