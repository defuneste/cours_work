# Un peu de log et de puissance 

Je remets un peu de math utile pour le cours  

## Exposant

### Définitions

Un exposant **entier** indique le nombre de fois ou sa base apparaît dans la multiplication : 

$$ a^{4} = a * a * a *a $$

m doit être supérieur à 0 sinon $a^{0} = 1$ par convention (je ne me rappelle plus pourquoi).

Un exposant négatif est équivalent à l'inverse de la base affectée de l'exposant positif: 

$$ a^{-m} = \frac{1}{a^{m}} $$

et donc:   

$$ (\frac{a}{b})^{-m} = (\frac{b}{a})^{m} $$

Enfin la base affectée d'un exposant fractionnaire donne une racine.

$$ a^{\frac{m}{n}} = \sqrt[n]{a^{m}} $$

Dans R: 

``` R

## on peut utiliser 
a = 5
m = 3

bill = a ^ m
bill

# ou **

bob = a ** m
bob

all.equal(bill, bob)

# il existe cependant une petite différence
# cf: https://stackoverflow.com/questions/30043949/raise-to-power-in-r
# et ?Arithmetic

`^`(a, m)

```

### Propriétés

Produit : 

$$ a^{r} * b^{s} = x^{r+s}  $$

Quotient :

$$ \frac{a^{r}}{a^{s}} = a^{r-s} $$

Exposant d'exposant:

$$ (a^{r})^{s} = a^{rs} $$

Exposant d'un produit: 

$$ (a * b)^{r} = a^{r}b^{r}  $$

Exposant d'un quotient: 

$$ (\frac{a}{b})^{r} = \frac{a^{r}}{b^{r}} $$

## log 

