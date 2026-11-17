-- Partie 1 : contrôle qualité des données
-- Énoncé : https://prof404.agents.kaffein.tech/ressources/tp-sql-olist
--
-- Rappels :
--   Un client, c'est customer_unique_id, pas customer_id.
--   La doc ne fait pas foi, le schéma oui. Vérifie avec \d avant d'écrire.
--   Au-dessus de chaque requête, indique le périmètre retenu et pourquoi.



/* 1. COMPTER LE NOMBRE DE LIGNES DE CHAQUE TABLE
   Objectif :
   Vérifier combien de données sont présentes dans chacune
   des tables de la base.
*/

SELECT
    'geolocation' AS table_name,
    COUNT(*) AS nombre_de_lignes
FROM geolocation

UNION ALL

SELECT
    'customers',
    COUNT(*)
FROM customers

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'order_payments',
    COUNT(*)
FROM order_payments

UNION ALL

SELECT
    'order_reviews',
    COUNT(*)
FROM order_reviews

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'sellers',
    COUNT(*)
FROM sellers

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items
ORDER BY table_name;


/* 2. AFFICHER QUELQUES DONNÉES DE CHAQUE TABLE
   Objectif :
   Vérifier visuellement que les données ont bien été importées.*/


SELECT *
FROM geolocation
LIMIT 10;


SELECT *
FROM customers
LIMIT 10;


SELECT *
FROM orders
LIMIT 50;


SELECT *
FROM order_payments
LIMIT 50;


SELECT *
FROM order_reviews
LIMIT 10;


SELECT *
FROM products
LIMIT 10;


SELECT *
FROM sellers
LIMIT 10;


SELECT *
FROM order_items
LIMIT 10;


/* 3. VÉRIFIER LA PÉRIODE COUVERTE PAR LES COMMANDES
   Objectif :
   Trouver la première et la dernière date d'achat présentes
   dans la base.
*/

SELECT
    MIN(order_purchase_timestamp)::DATE AS premiere_date_achat,
    MAX(order_purchase_timestamp)::DATE AS derniere_date_achat
FROM orders;

/*Les requêtes 1 à 3 vérifient le volume des données et la période des commandes.
Ces requêtes servent uniquement à contrôler les données importées.*/

/* 4. RÉPARTITION DES COMMANDES PAR STATUT
   Objectif :
   Connaître le nombre de commandes pour chaque statut
   et leur pourcentage dans l'ensemble des commandes.
*/


SELECT
    order_status,
    COUNT(*) AS nombre_commandes,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS pourcentage

FROM orders
GROUP BY order_status
ORDER BY nombre_commandes DESC;

/*La requête 4 vérifie la répartition des commandes selon leur statut.
On va conserver tous les statuts.
Les commandes annulées ou livrées sont utiles pour les analyses.*/


/* 5. COMPTER LES VALEURS MANQUANTES DANS LES DATES
   Objectif :
   Vérifier les valeurs NULL dans trois colonnes importantes :
*/

SELECT

    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS approved_manquantes,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS carrier_manquantes,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS customer_manquantes
FROM orders;


/*  6. POURCENTAGE DE VALEURS MANQUANTES
   Même contrôle que précédemment, mais cette fois on calcule
   le pourcentage de valeurs manquantes.
*/

SELECT

    ROUND(
        COUNT(*) FILTER (
            WHERE order_approved_at IS NULL
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_approved_manquantes,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_carrier_date IS NULL
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_carrier_manquantes,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date IS NULL
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_customer_manquantes
FROM orders;


/*Les requêtes 5 et 6 recherchent les dates manquantes.
On va conserver les `NULL`.
Une date peut être absente normalement, par exemple pour une commande non livrée.*/


/*   7. INCOHÉRENCE :
      COMMANDE "DELIVERED" SANS DATE DE LIVRAISON CLIENT*/

SELECT
    COUNT(*) AS nombre_incoherences

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;


/* 8. AFFICHER LES COMMANDES CONCERNÉES
   Ici, on affiche les commandes problématiques afin de pouvoir
   les analyser plus précisément.*/

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;


/*  9. INCOHÉRENCE :
      DATE DE LIVRAISON CLIENT AVANT DATE D'ACHAT
   Une livraison ne devrait normalement pas avoir lieu avant
   l'achat.*/


SELECT
    COUNT(*) AS nombre_incoherences
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


/*10. INCOHÉRENCE :
       LIVRAISON AU TRANSPORTEUR AVANT L'ACHAT
    On vérifie maintenant si la date à laquelle la commande
   a été remise au transporteur est antérieure à la date d'achat..*/

SELECT
    COUNT(*) AS nombre_incoherences
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;


/* 11. INCOHÉRENCE :
       APPROBATION AVANT DATE D'ACHAT
   Une commande ne devrait normalement pas être approuvée
   avant d'avoir été passée.*/


SELECT
    COUNT(*) AS nombre_incoherences
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

/*Les requêtes 7 à 11 recherchent des problèmes de chronologie : livraison sans date, 
Livraison avant achat, transporteur avant achat et validation avant achat.
Conserver les commandes, mais exclure les dates incohérentes des calculs concernés.
Les autres informations de la commande restent utiles.*/

/* 12. VÉRIFIER L'UNICITÉ DE review_id
   Objectif :
   Vérifier si un même review_id apparaît plusieurs fois.*/

SELECT review_id,
       COUNT(*) AS lignes,
       COUNT(DISTINCT order_id) AS commandes_differentes
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY lignes DESC;



/*La requête 12 vérifie si un `review_id` apparaît plusieurs fois.
La table a été créée sans index unique (UNIQUE) sur la colonne review_id. 
PostgreSQL a donc techniquement le droit d'accepter les doublons.
Conserver les doublons dans un premier temps car c'est le meme id de review pour des commandes differentes.*/


/* 13. COMMANDES AVEC PLUSIEURS LIGNES DE PAIEMENT
   Objectif :
   Identifier combien de commandes ont plusieurs lignes
   dans order_payments.*/


SELECT
    COUNT(*) AS commandes_avec_plusieurs_paiements

FROM (SELECT payment_order_id
        FROM order_payments
        GROUP BY payment_order_id
        HAVING COUNT(*) > 1);


/* 14. COMPRENDRE POURQUOI UNE COMMANDE A PLUSIEURS PAIEMENTS
   On affiche ici les détails des différentes lignes de paiement :*/


SELECT
    payment_order_id AS order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value

FROM order_payments
WHERE payment_order_id IN (

    SELECT
        payment_order_id

    FROM order_payments

    GROUP BY payment_order_id

    HAVING COUNT(*) > 1
)
ORDER BY
    payment_order_id,
    payment_sequential;

/*Les requêtes 13 et 14 recherchent les commandes ayant plusieurs lignes de paiement et permettent d'en comprendre la raison.
Conserver les lignes de paiement.
Plusieurs paiements pour une même commande peuvent être normaux.*/

