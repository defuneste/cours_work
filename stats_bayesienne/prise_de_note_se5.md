# séance 5 

## validation de modèle 
 
1. on construit un modèle 
2. on le fait tourner
3. on se pose la question de la validation de ce modèle 

Le modèle prédit il des valeurs impossibles ou au contraire ne prédît il pas valeurs attendus. 

Il  y a une nuance entre validation et comparaison. La validation teste la prédiction des données. La comparaison est entre différents modèles. 

Posterior predictive check:

- Générer des données à partir de la distribution a posteriori des paramètres du modèle. 

(proche du boostrap)

- comparer les données simulées aux données observées


Limites: 
- Difficultés dans le choix de la ou les fonctions résumé
- Approche qui surestime l'adéquation du modèle aux données: les paramètres sont estimés à partir des mêmes données que celles permettant la vérification 

L'overfitting dans le bayesien est souvent autour du prior, le modèle va se retourner vers le prior. 


AIC: Akaiki information criteriom

arbitrage entre la vraisemblance (proportionelle au nombre de paramètres) et l'optimisme du modèle. 

privilégier le modèle avec l'AIC le plus faible. C'est une approximation du leave on out.

Qu'elle va être notre fit sur des nouvelles données?

On utilise beaucoup le DIC. (cf diapo 12)

## Prior

Comment fixer les lois à priori.

question de la définition de la probabilité entre les deux approches (bayesienne / fréquentiste).

En fréquentiste on raisonne sur la probabilité des données connaissant les paramètres (vraisemblance, p-value). 

Dans le cadre bayesien on raisonne sur la distribution des valeurs du paramètres. L' apriori est sans regarder les données.


Première question dois je prendre un prior informatif ou non informatif. 

"eliciter une information a priori"

cas on ne sait rien: estimation d'une proportion

On va utiliser une loi uniforme. (dont on connait la solution de la conjugaison).

Il faut savoir sur qu'elle échelle on mets l'info à priori. 

On peut donner des ordres de grandeur pour être "vaguement informatif"

Est ce que plat c'est non informatif. 

