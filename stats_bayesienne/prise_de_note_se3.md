# prise de note séance 3

On va multiplier une loi à priori avec une fonction/loi de vraisemblance et on va retomber soit sur une loi de même type mais pas toujours. 

Ce sont des cas de conjugaison: une loi conjugué pour la fonction de vraisemblance (TODO regarder sont cours). 

On va utiliser un algorithme qui va produire la densité ou fonction distribution à posteriori.

Il faut pouvoir échantillon des valeurs qui correspondent à la distribution que l'on cherche. 


Les méthodes de MCMC permet de générer des valeurs qui correspondent à celle que l'on souhaite à posteriori. On va converger vers une distribution qui correspond à un échantillon de la distribution à posteriori.

Que faut il vérifier pour être sur que l'algo aura bien converger vers la distribution à posteriori.

## vérification des résultats de l'algo MCMC

on appelle aussi les fuzzy moustach les "traces". 

On peut regarder la variabilité inter chaînes et intra chaînes. 


La variabilité inter chaîne doit être minime / à a variabilité intra. (cf indice de Gelman). On doit être autour de 1.

On ne garde que les valeurs de fin de chaînes pas celle dites de la phase dite de chauffe. Il faut donc avoir assez d'itération pour résumer de manière fiable la distribution, il en faut pas mal pour avoir par exemple les quantiles 2.5 et 97.5%.

On utilise des "cumul plot". ce dernier doit être stable. 

Il y a une auto correlation entre les valeurs de la chaîne pas définition de l'algo. Si j'ai beaucoup d'auto correlation il faut faire tourner l'algo plus longtemps.

Un des moyens on peut "thin" méthode dite des "thining" on retient par exemple une sur 4 ou sur 2. 

Il faut vérifier: 

- convergence
- autocorrelation
- a t on assez d'itération 

On va utiliser JAGS qui appartient à la famille de BUGS Bayesian inference Using Gibbs Samplings. 

Il y a des outils plus ou moins performant en fonction du domaine d'application. 


## exemples

### premier exemple

``` R

data <- read.table("seance3/donnees_ppraevia.txt", h = T)
ppraevia = data$ppraevia

```


Proba d'avoir une fille:

Modele 

fille_i ~ Bernoulli(p)

P ~ uniform(0,1)

### codes un modeles dans JAGS

Il faut coder le modèle 

``` JAGS
model
{
    fille ~ dbern(p) ## on fait comme si on avait un evenement / mesure

}

```

Dans JAGS Normal prend tau, la précision $tau = 1/sigma²$

Dans JAGS on ne donne pas de nom mais on ordonne les paramètres dans un sens.

le ~ est pour une relation stochastique et les relations déterministes sont indiqué comme <- 

Il existe des fonctions dans JAGS.


``` JAGS
model
{

for (i in 1:n)
    {
    fille[i] ~ dbern(p) ## on fait comme si on avait un evenement / mesure
    }
    
    p ~ dunif(0, 1 )
}

```

Dans JAGS on a pas le droit de redéfinir une observation dans le modèle (définie une seule fois). une variable ne peut apparaître que une fois a droite. 

``` JAGS

model
{
for(i in 1:n)
    {
    taille_enfant[i] ~ dnorm(mu[i], tau)
    mu[i] <- beta0 + beta1 * taille_pere[i]
    }
    tau <- 1/(sigma^2)
    beta0 ~ dunif(-10, 10)
    beta1 ~ dunif(-0.2, 0.2)
    sigma ~ dunif(0, 1)
}

```



