# Estimation du prix de diamants

- Vincent Haney
- Félix Pelletier
- Charles-François St-Cyr
- Mikael Vaillant

## Description

Cet ensemble classique de données classique contient les prix les caractéristiques de près de 54 000 diamants. Il s'agit d'un ensemble de données idéal pour mettre en pratique les modèles statistiques vus en MTH3302 !

Vous devrez prédire le prix des diamants de l'ensemble de test en fonction des caractéristiques. Vos prédictions seront évaluées et comparées aux prédictions des autres équipes de la classe. Prévoyez votre travail, car nous n'avez que deux soumissions possibles par jour UTC sur Kaggle pour évaluer vos prédictions.

## Concour

[Lien Kaggle](https://www.kaggle.com/competitions/prix-des-diamants2/data?select=train.csv)

### Description des données

Les données sont constituées des fichiers suivants :

- train.csv
- test.csv

Le fichier train.csv contient le prix de vente en dollar américain de 40 455 diamants en fonction des caractéristiques suivantes :

- cut : qualité de coupe (Fair, Good, Very Good, Premium, Ideal)
- color : couleur du diamant (de J (pire) à D (meilleure)
- clarity : clarté du diamant (I1 (pire), SI2, SI1, VS2, VS1, VVS2, VVS1, IF (meilleure))
- x: longueur en mm
- y: largeur en mm
- z: profondeur en mm
- depth: pourcentage de la profondeur exprimée comme 2*z/(x+y)
- table: pourcentage de la largeur du sommet du diamant par rapport au point le plus large

Le fichier test.csv contient les caractéristiques de 13 485 diamants pour lesquels vous devriez prédire le prix de vente.

#### Données manquantes

Les fichiers contiennent des données manquantes. C'est à vous de décider de la meilleure façon de faire pour traiter avec ces données manquantes. Vous pouvez entres autres ignorer les lignes comportant des observations manquantes ou bien tenter de les imputer.
