<!-- Formation stats bayesienne organisée par le LBBE 
 https://lbbe.univ-lyon1.fr/fr/formation-statistique-bayesienne
 Mai 2022
 Prise de Note Olivier Leroy
 -->

# Séance 1

**Prise de notes un peu à la volée peux contenir des erreurs!**

## processus de Bernoulli

un seul tirage Bernoulli plusieurs tirage binomial. Plus le nombre est grand elle tend vers Poisson. Puis Poisson tends vers Normal. 

Loi géométrique ? sa généralisation est la négative binomiale. 

succes pour un tirages (reprendre diapo!!)

La binomiale on a un dénominateur. 

## processus de Poisson

ici pour des mesures sur volumes. 

reprendre la définition de la diapo. 

La loi exponentielle est associé à celle de Poisson. Unité de temps/surface nécessaire pour avoir une évènement.

Loi Gamma le second paramètre est pas toujours implémenté de la même manière entre R et Jags. 

si sur dispersion on passe en négative binomiale (cas ou variance > moyenne). 

C'est un melange de loi de poisson et de gamma.


La loi norma; est de - inf à + inf. CE qui veut dire que l'on va tronquer des loi pour des raisons logiques.  

Lognomarl: moyenne et écart type en log népérien. 

Distribution de Student

Plus souple que la loi normal, plus de poids au queue de distribution, definit par des degrés de liberté. Si degré = 1 loi de Cauchy. Elle est utilisé pour avoir des valeurs extrèmes loin du centre de la distribution

Loi Beta definit sur 0 / 1 => utile pour des probabilité ou des taux. La loi de Beta(1,1) est une uniforme. (il y a deux paramètres $\alpha$ et $\beta$).

support de la loi ? (domaine de definition) 
