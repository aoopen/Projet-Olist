-- Partie 3 : livraison et satisfaction
-- Énoncé : https://prof404.agents.kaffein.tech/ressources/tp-sql-olist
--
-- Rappels :
--   Un client, c'est customer_unique_id, pas customer_id.
--   La doc ne fait pas foi, le schéma oui. Vérifie avec \d avant d'écrire.
--   Au-dessus de chaque requête, indique le périmètre retenu et pourquoi.

/* 1.DÉLAI DE LIVRAISON RÉEL, EN JOURS, ENTRE L'ACHAT ET LA LIVRAISON CLIENT..*/

SELECT (order_delivered_customer_date::DATE - order_purchase_timestamp::DATE ) AS nombres_jours_livraison
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

/* 2.MOYENNE ET MÉDIANE DU DÉLAI DE LIVRAISON, EN JOURS, ENTRE L'ACHAT ET LA LIVRAISON CLIENT.*/

/* 2. MOYENNE ET MÉDIANE DU DÉLAI DE LIVRAISON */

WITH livraison_reel AS (
    SELECT
        order_id,
        order_delivered_customer_date::DATE
        - order_purchase_timestamp::DATE AS nombre_jours_livraison
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)

SELECT
    ROUND(AVG(nombre_jours_livraison), 2) AS nombre_jours_livraison_moyen,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY nombre_jours_livraison)::NUMERIC,
        2
    ) AS mediane
FROM livraison_reel;

/*Le fait que la moyenne (12,5 jours) soit supérieure à la médiane (10 jours) indique une asymétrie positive (ou étalement vers la droite) de la distribution des délais.
La performance globale (Médiane = 10 jours) : Dans 50 % des cas, les clients reçoivent leur colis en 10 jours ou moins.
L'impact des anomalies (Moyenne = 12,5 jours) : La moyenne est tirée vers le haut par un groupe de livraisons qui subissent des retards importants.
Cet étalement montre qu'une part importante de clients attend beaucoup plus longtemps (parfois 15, 20 jours ou plus pour atteindre cette moyenne).*/


/* 3.COMPARAISON DES LIVRAISONS EN RETARD, LIVRAISONS EN AVANCE ET LIVRAISONS LIVRÉES À TEMPS.
calculer sans prendre en compte les livraisons non effectué.*/


SELECT COUNT(*) FILTER (WHERE (order_delivered_customer_date::DATE - order_estimated_delivery_date::DATE) > 0) AS nombres_livraison_en_retard ,
       COUNT(*)FILTER (WHERE(order_estimated_delivery_date::DATE - order_delivered_customer_date::DATE) > 0) AS nombres_livraison_en_avance,
       COUNT(*)FILTER (WHERE(order_estimated_delivery_date::DATE - order_delivered_customer_date::DATE) = 0) AS nombres_livraison_a_temps
FROM orders
WHERE order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL;


SELECT 
    ROUND((COUNT(*) FILTER (WHERE (order_delivered_customer_date::DATE - order_estimated_delivery_date::DATE) > 0) * 100.0) 
        /COUNT(*),2) AS pourcentage_livraison_en_retard,
    ROUND((COUNT(*) FILTER (WHERE (order_estimated_delivery_date::DATE - order_delivered_customer_date::DATE) > 0) * 100.0) 
        /COUNT(*),2) AS pourcentage_livraison_en_avance,
        
    ROUND((COUNT(*) FILTER (WHERE (order_estimated_delivery_date::DATE - order_delivered_customer_date::DATE) = 0) * 100.0) 
        /COUNT(*),2) AS pourcentage_livraison_a_temps
FROM orders
WHERE order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL;



/*Livraison en avance : 91,89 % (88 649 clients)
La grande majorité des commandes arrivent avant la date estimée. Cela montre que les délais annoncés sont plutôt prudents. 
On pourrait donc envisager de réduire légèrement le délai affiché sur le site, tout en gardant une marge de sécurité.

Livraison à temps : 1,34 % (1 292 clients)
Une faible partie des commandes arrive exactement à la date prévue. Les clients concernés reçoivent donc leur commande dans le délai annoncé.

Livraison en retard : 6,77 % (6 535 clients)
Les retards peuvent avoir un impact négatif sur la satisfaction des clients et sur l'image de l'entreprise. 
Il serait intéressant d'identifier les États vendeurs, les transporteurs et les produits qui sont les plus concernés par ces retards.*/


/* 4.ANALYSE DU RETARD PAR RAPPORT AU NOTE DE SATISFACTION.*/

SELECT
    CASE
        WHEN (o.order_delivered_customer_date::DATE
              - o.order_estimated_delivery_date::DATE) < -7
            THEN 'Plus de 7 jours d''avance'

        WHEN (o.order_delivered_customer_date::DATE
              - o.order_estimated_delivery_date::DATE) BETWEEN -7 AND -1
            THEN '1 à 7 jours d''avance'

        WHEN o.order_delivered_customer_date::DATE
             = o.order_estimated_delivery_date::DATE
            THEN 'Le jour promis'

        WHEN (o.order_delivered_customer_date::DATE
              - o.order_estimated_delivery_date::DATE) BETWEEN 1 AND 7
            THEN '1 à 7 jours de retard'

        ELSE 'Plus de 7 jours de retard'
    END AS livraison,

    COUNT(DISTINCT o.order_id) AS nombre_commandes,
    ROUND(AVG(r.review_score), 2) AS note_moyenne
FROM orders o
JOIN order_reviews r
    ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY livraison;


/* On remarque que pour les commandes qui arrivent en avance ou le jour promis on a des notes de satifsfaction assez elevé,
alors que pour les commandes qui arrivent en retards les notes sont trés bas et surtout quand ça dépasse les 7 jours de retard les notes sont catastrophiques.
Cette analyse montre qu'il existe une relation entre le délai de livraison et la satisfaction client.*/ 

/* 5.ANALYSE DU RETARD PAR RAPPORT A L'ETAT DU VENDEUR QUI A PLUS DE 1000 COMMANDES.*/

WITH commandes_etat AS (
    SELECT
        s.seller_state AS etat_vendeur,
        o.order_id,
        o.order_delivered_customer_date::DATE
        - o.order_estimated_delivery_date::DATE AS retard_jours
    FROM orders o

    JOIN order_items oi
        ON oi.order_id = o.order_id

    JOIN sellers s
        ON s.seller_id = oi.seller_id

    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        s.seller_state,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
),

etats AS (
    SELECT
        etat_vendeur,
        COUNT(*) AS nombre_commandes,

        COUNT(*) FILTER (
            WHERE retard_jours > 0
        ) AS commandes_en_retard

    FROM commandes_etat

    GROUP BY etat_vendeur

    HAVING COUNT(*) >= 1000
)

SELECT
    etat_vendeur,
    nombre_commandes,
    commandes_en_retard,

    ROUND(
        commandes_en_retard * 100.0 / nombre_commandes,
        2
    ) AS pourcentage_retard

FROM etats
ORDER BY pourcentage_retard DESC;


/*J'ai choisi un seuil de 1 000 commandes car nous avons une période de données de presque deux ans. Les États avec moins de 1 000 commandes ont un volume plus faible et peuvent donner des pourcentages de retard moins représentatifs.
Ce seuil permet donc de comparer les États avec un volume de commandes suffisamment important.
Pour les retards par rapports aux etats des vendeurs avec plus de 1000 produits vendu,
on constate que les retards sont sur les etats de SP et RJ et c'est surement du au faite que c'est les villes les plus grandes du brésil et avec le plus de population.*/


/* 6. LIVRAISONS ANORMALEMENT LENTES

On considère qu'une livraison est anormalement lente
si son délai est au moins 50 % supérieur à la moyenne
de son État vendeur. */

WITH delais AS (
    SELECT
        s.seller_state AS etat_vendeur,
        o.order_id,
        o.order_delivered_customer_date::DATE
        - o.order_purchase_timestamp::DATE AS delai_jours
    FROM orders o

    JOIN order_items oi
        ON oi.order_id = o.order_id

    JOIN sellers s
        ON s.seller_id = oi.seller_id

    WHERE o.order_delivered_customer_date IS NOT NULL

    GROUP BY
        s.seller_state,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
),

moyennes AS (
    SELECT
        etat_vendeur,
        AVG(delai_jours) AS moyenne_etat
    FROM delais
    GROUP BY etat_vendeur
)

SELECT
    d.etat_vendeur,
    d.order_id,
    d.delai_jours,
    ROUND(m.moyenne_etat, 2) AS moyenne_etat
FROM delais d

JOIN moyennes m
    ON d.etat_vendeur = m.etat_vendeur

WHERE d.delai_jours > m.moyenne_etat * 1.5

ORDER BY d.delai_jours DESC;

/*On remarque que plusieurs commandes ont des délais de livraison beaucoup plus élevés que la moyenne de leur État.
Par exemple, certaines commandes atteignent 28 jours ou plus alors que les moyennes des États sont généralement autour de 12 à 14 jours.
L'État SP revient très souvent dans les résultats, avec une moyenne de 12,29 jours et plusieurs commandes avec des délais de 28 jours ou plus.
On retrouve aussi des commandes anormalement longues dans les États PR, RJ, MG et SC.
Cela permet de repérer les commandes qui ont eu un délai beaucoup plus long que le délai habituel de leur État vendeur.*/



