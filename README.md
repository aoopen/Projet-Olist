# 🛒 Analyse de données e-commerce – Olist

## 📌 Présentation du projet

Ce projet porte sur l'analyse de données de la marketplace brésilienne Olist.

L'objectif est d'exploiter des données issues de l'activité e-commerce afin d'en extraire des informations utiles à la compréhension des performances commerciales, de la livraison et de la satisfaction client.

Le projet repose principalement sur SQL pour interroger et analyser les données, ainsi que sur Python pour produire des visualisations.

Il s'inscrit dans une démarche d'analyse décisionnelle visant à transformer des données brutes en indicateurs pertinents pour le métier.

## 🎯 Objectifs

- Mettre en place une base de données relationnelle.
- Contrôler la qualité et la cohérence des données.
- Analyser les performances commerciales de la marketplace.
- Étudier les commandes et les comportements d'achat.
- Analyser les délais de livraison.
- Explorer les indicateurs liés à la satisfaction client.
- Construire des visualisations pour communiquer les résultats.

## 🛠️ Technologies utilisées

- **SQL** : interrogation et analyse des données relationnelles.
- **Python** : analyse et manipulation des données.
- **Pandas** : traitement des données.
- **Jupyter Notebook** : analyse exploratoire et visualisation.
- **Git / GitHub** : gestion du projet et versionnement.

## 🔎 Étapes du projet

### 1. Préparation de la base de données
- Création des tables.
- Définition des relations entre les différentes tables.
- Chargement des fichiers CSV.
- Vérification des volumes de données.

### 2. Contrôle qualité des données
- Identification des valeurs manquantes.
- Vérification des doublons.
- Contrôle de la cohérence des données.
- Vérification des relations entre les tables.

### 3. Analyse commerciale
- Exploration des commandes.
- Analyse des ventes.
- Étude des performances commerciales.
- Extraction d'indicateurs pertinents pour l'activité e-commerce.

### 4. Analyse de la livraison et de la satisfaction
- Étude des délais de livraison.
- Analyse des retards éventuels.
- Exploration des avis clients.
- Recherche de liens entre livraison et satisfaction.

### 5. Visualisation et synthèse
- Création de graphiques.
- Présentation des principaux indicateurs.
- Formalisation des conclusions dans une synthèse métier.

## 📁 Structure du projet

```text
Projet-Olist/
│
├── data/
│   └── Fichiers CSV (à récupérer séparément)
│
├── notebook/
│   └── visualisations.ipynb
│
├── setup/
│   ├── 01_creation_tables.sql
│   └── 02_chargement_donnees.sql
│
├── sql/
│   ├── 01_controle_qualite.sql
│   ├── 02_analyse_commerciale.sql
│   └── 03_livraison_satisfaction.sql
│
├── SYNTHESE.md
└── README.md
```

## 🚀 Installation et utilisation

### 1. Cloner le dépôt

```bash
git clone https://github.com/aoopen/Projet-Olist.git
cd Projet-Olist
```

### 2. Récupérer les données

Les fichiers CSV ne sont pas inclus dans le dépôt en raison de leur volume.

Récupérer le dossier `data/` auprès du formateur et le placer à la racine du projet.

### 3. Préparer la base de données

Exécuter les scripts dans l'ordre :

1. `setup/01_creation_tables.sql`
2. Modifier les chemins des fichiers CSV dans `setup/02_chargement_donnees.sql`.
3. Exécuter `setup/02_chargement_donnees.sql`.

### 4. Réaliser les analyses

Exécuter les scripts SQL dans le dossier `sql/`, puis ouvrir le notebook de visualisation.

## 💡 Compétences développées

- SQL et requêtes relationnelles
- Jointures entre plusieurs tables
- Agrégations et indicateurs KPI
- Contrôle qualité des données
- Analyse commerciale
- Analyse de la satisfaction client
- Analyse des performances logistiques
- Data Visualization
- Python et Jupyter Notebook

---

**Projet d'analyse de données e-commerce réalisé dans le cadre d'une mise en pratique des compétences Data Analyst.**
