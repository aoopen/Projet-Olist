-- Partie 2 : analyse commerciale
-- Énoncé : https://prof404.agents.kaffein.tech/ressources/tp-sql-olist
--
-- Rappels :
--   Un client, c'est customer_unique_id, pas customer_id.
--   La doc ne fait pas foi, le schéma oui. Vérifie avec \d avant d'écrire.
--   Au-dessus de chaque requête, indique le périmètre retenu et pourquoi.


/* 1. CHIFFRE D'AFFAIRES TOTAL BASE SUR PRICE*/

SELECT SUM(price) AS chiffre_affaires
FROM order_items;

/* 2. CHIFFRE D'AFFAIRES TOTAL BASE SUR (PRICE + FREIGHT_VALUE)*/

SELECT SUM(price + freight_value) AS chiffre_affaires
FROM order_items;


/* 3. CHIFFRE D'AFFAIRES PAR MOIS
   On utilise la date d'achat de la commande.
   Le chiffre d'affaires correspond ici au prix des produits. */


WITH chiffre_affaires_mensuel AS (
    SELECT 
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS mois, 
        SUM(oi.price) AS chiffre_affaires 
    FROM orders o 
    JOIN order_items oi ON o.order_id = oi.order_id 
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT 
    mois,
    chiffre_affaires,
    LAG(chiffre_affaires) OVER (ORDER BY mois) AS chiffre_affaires_mois_precedent,
    ROUND(
        ((chiffre_affaires - LAG(chiffre_affaires) OVER (ORDER BY mois)) / LAG(chiffre_affaires) OVER (ORDER BY mois)) * 100, 
        2
    ) AS evolution_pourcentage
FROM chiffre_affaires_mensuel
ORDER BY mois ASC;


/*Septembre 2016 : 267,36 € → mois de début de période incomplet.
Octobre 2016 : 49 507,66 € → forte hausse, mais surtout parce qu'on compare avec un mois très incomplet.
Novembre 2016 : il n'y a pas de données → le LAG() compare octobre directement à décembre.
Décembre 2016 : 10,90 € → probablement un mois très incomplet/anomalie dans les données.
Septembre 2018 : 145 € → mois de fin de période incomplet.

Donc le +1 103 687,80 % de janvier 2017 n'est pas une vraie explosion du chiffre d'affaires,
il est principalement dû au chiffre d'affaires extrêmement faible de décembre 2016.*/

/*Pour une analyse plus propre, il vaut mieux retirer les mois incomplets du début et de la fin, 
et éventuellement de vérifier pourquoi décembre 2016 contient seulement 10,90 €.*/

/*Voir les commandes de décembre 2016*/

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
WHERE o.order_purchase_timestamp >= '2016-12-01'
  AND o.order_purchase_timestamp < '2017-01-01'
ORDER BY o.order_purchase_timestamp;



/* REMARQUE :

Décembre 2016 contient seulement une commande pour un montant
de 10,90 €.

Ce mois est donc très peu représentatif et explique la forte
variation du chiffre d'affaires en janvier 2017.

On peut considérer décembre 2016 comme une période incomplète
pour l'analyse mensuelle. */

/*Pour une analyse plus propre, il vaut mieux retirer les mois incomplets du début et de la fin, 
et éventuellement de vérifier pourquoi décembre 2016 contient seulement 10,90 €.*/

/* 4. PANIER MOYEN PAR COMMANDE
   On calcule le montant total de chaque commande. */


WITH panier AS (
    SELECT
        order_id,
        SUM(price) AS montant_commande
    FROM order_items
    GROUP BY order_id
)

SELECT
    ROUND(AVG(montant_commande), 2) AS panier_moyen,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY montant_commande)::numeric,
        2
    ) AS mediane,
    MIN(montant_commande) AS minimum,
    MAX(montant_commande) AS maximum
FROM panier;


 /*La moyenne (137,75 €) est assez différente de la médiane (86,90 €). Cela montre que certaines commandes avec des montants très élevés, comme celle à 13 440 €, tirent la moyenne vers le haut.
 Donc la moyenne n'est pas totalement représentative du panier habituel. La médiane de 86,90 € représente mieux une commande « normale ».*/

/* 5. TOP 10 DES CATÉGORIES
   On calcule le chiffre d'affaires, le nombre de commandes
   et le panier moyen pour chaque catégorie. */


SELECT
    p.product_category_name AS categorie,
    SUM(oi.price) AS chiffre_affaires,
    COUNT(DISTINCT oi.order_id) AS nombre_commandes,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS panier_moyen
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY chiffre_affaires DESC
LIMIT 10;

/* REMARQUE :

Les catégories avec le plus gros chiffre d'affaires sont
"beleza_saude", "relogios_presentes" et "cama_mesa_banho".
"cama_mesa_banho" possède le plus grand nombre de commandes
avec 9417 commandes.
"relogios_presentes" a un panier moyen assez élevé de 214,26 €,
ce qui explique son chiffre d'affaires important malgré moins
de commandes.
Le chiffre d'affaires dépend donc à la fois du nombre de commandes
et du montant moyen des commandes. */



/* 6. CHIFFRE D'AFFAIRES PAR ÉTAT
   On utilise l'état du client qui a passé la commande. */


SELECT
    c.customer_state AS etat,
    SUM(oi.price) AS chiffre_affaires,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER (),
        2
    ) AS pourcentage
FROM customers c
JOIN orders o
    ON c.customer_id = o.order_customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY chiffre_affaires DESC;


/* L'Etat de Sao Paulo représente une grande partie du chiffre d'affaire,
surement du au faite que c'est la ville qui a le plus d'habitant au brésil donc plus de clients.*/

/* 7. MOYENS DE PAIEMENT
   On compare le nombre de paiements et leur montant total
   pour chaque type de paiement. */


SELECT
    payment_type,
    COUNT(*) AS nombre_transactions,
    SUM(payment_value) AS montant_total
FROM order_payments
GROUP BY payment_type
ORDER BY montant_total DESC;


/* On remarque que le paiement le plus utiliser est la credit card et après on a la methode de paiement boleto disponible au brésil.*/


/* Comparaison du panier selon le nombre de mensualités */

SELECT
    payment_installments,
    COUNT(DISTINCT payment_order_id) AS nombre_commandes,
    ROUND(AVG(payment_value), 2) AS paiement_moyen
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

/*On remarque que plus le nombre de mensualités augmente, plus le paiement moyen a tendance à augmenter.
La majorité des commandes sont payées en 1 mensualité (49 060 commandes). Les résultats avec beaucoup de mensualités sont moins nombreux*/