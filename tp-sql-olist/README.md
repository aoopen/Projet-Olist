# TP SQL : analyse de la marketplace Olist

Ton dépôt personnel pour le TP de la semaine. Tout ce que tu rends se trouve ici.

**L'énoncé complet, le planning de la semaine et les ressources sont sur
prof404 : https://prof404.agents.kaffein.tech/ressources**

Ce dépôt ne contient que la structure et les scripts de mise en place. Ne recopie
pas l'énoncé ici, il évolue et la version qui fait foi est celle en ligne.

## Mise en place

Les données ne sont pas dans ce dépôt (trop volumineuses, et ce n'est pas le rôle
de git). Récupère le dossier `data/` fourni par ton formateur, puis :

1. `setup/01_creation_tables.sql` crée les 8 tables.
2. `setup/02_chargement_donnees.sql` charge les CSV. Ouvre-le d'abord et remplace
   les chemins `C:\path\to\file\` par le chemin réel de ton dossier `data/`.

Vérifie ensuite les volumes attendus, ils sont listés dans l'énoncé en ligne. Si
un compte ne tombe pas juste, corrige avant d'aller plus loin.

## Structure attendue

```
sql/
  01_controle_qualite.sql        partie 1
  02_analyse_commerciale.sql     partie 2
  03_livraison_satisfaction.sql  partie 3
notebook/
  visualisations.ipynb           partie 4
SYNTHESE.md                      ta synthèse d'une page
```

## Ce qui est rendu

1. Les fichiers `sql/`, commentés, qui s'exécutent du début à la fin sans erreur.
2. Le notebook avec les quatre graphiques.
3. `SYNTHESE.md`, une page pour un responsable métier, sans SQL dedans.

## Rythme

**Commite à la fin de chaque journée**, même si ce n'est pas fini. Un dépôt vide
en milieu de semaine est le seul vrai signal d'alerte.

## Bloqué ?

Plus de vingt minutes sur le même point : pose ta question sur
https://prof404.agents.kaffein.tech/dashboard

Précise ce que tu as déjà essayé et le message d'erreur exact.
