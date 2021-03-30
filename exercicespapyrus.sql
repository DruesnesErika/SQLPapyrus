-- CAS PAPYRUS

-- LES BESOINS D'AFFICHAGE

-- 1-Quelles sont les commandes du fournisseur 09120?

SELECT numcom, numfou
FROM entcom
WHERE numfou = 9120

-- 2-Afficher le code des fournisseurs pour lesquels des commandes ont été passées

SELECT DISTINCT entcom.numfou AS numerofournisseur, 
nomfou AS nomfournisseur 
FROM entcom
JOIN fournis
ON entcom.numfou = fournis.numfou

-- 3-Afficher le nombre de commandes fournisseurs passées, et le nombre de fournisseurs concernés

SELECT COUNT(numcom) AS nombrecommandes, 
COUNT(DISTINCT numfou) AS nombrefournisseurs
FROM entcom

-- 4-Editer les produits ayant un stock inférieur ou égal au stock d'alerte et dont la quantité annuelle est inférieure à 1000 (informations à fournir : n° produit, libelléproduit, stock, stockactuel d'alerte, quantitéannuelle)

SELECT codart AS numeroproduit, 
libart AS libelleproduit, 
stkphy AS stockphysique,
stkale AS stockactueldalerte,
qteann AS quantiteannuelle
FROM produit
WHERE stkphy <= stkale
AND qteann < 1000

-- 5-Quels sont les fournisseurs situés dans les départements 75 78 92 77 ? L’affichage (département, nom fournisseur) sera effectué par département décroissant, puis par ordre alphabétique

SELECT LEFT(posfou, 2) AS departement, nomfou AS nomfournisseur
FROM fournis
WHERE posfou LIKE '92%'
OR posfou LIKE '75%'
OR posfou LIKE '78%'
OR posfou LIKE '77%'
ORDER BY posfou DESC, nomfou ASC

-- 6-Quelles sont les commandes passées au mois de mars et avril?

SELECT numcom AS commandesmarsavril
FROM entcom
WHERE MONTH(datcom) BETWEEN 03 AND 04

-- 7-Quelles sont les commandes du jour qui ont des observations particulières ?(Affichage numéro de commande, date de commande)

SELECT numcom AS numerodecommande, datcom AS datedecommande
FROM entcom 
WHERE obscom IS NOT NULL
AND obscom != " "
AND obscom != ""

-- 8-Lister le total de chaque commande par total décroissant (Affichage numéro de commande et total)

SELECT nomfou AS nomfournisseur, ligcom.numcom AS numerocommande, 
SUM(QTECDE*PRIUNI) AS total
FROM ligcom
JOIN entcom ON ligcom.numcom = entcom.numcom
JOIN fournis ON entcom.numfou = fournis.numfou
GROUP BY ligcom.numcom
ORDER BY SUM(QTECDE*PRIUNI) DESC

-- 9-Lister les commandes dont le total est supérieur à 10000€; on exclura dans le calcul du total les articles commandés en quantité supérieure ou égale à 1000.(Affichage numéro de commande et total)

SELECT nomfou AS nomfournisseur, ligcom.numcom AS numerocommande,
SUM(QTECDE*PRIUNI) AS total
FROM ligcom
JOIN entcom ON ligcom.numcom = entcom.numcom 
JOIN fournis ON entcom.numfou = fournis.numfou
WHERE qtecde < 10000
GROUP BY ligcom.numcom
HAVING TOTAL > 10000
ORDER BY TOTAL DESC

-- 10-Lister les commandes par nom fournisseur (Afficher le nom du fournisseur, le numéro de commande et la date)

SELECT nomfou AS nomfournisseur, entcom.numcom AS numerocommande, datcom AS datedecommande
FROM entcom
JOIN fournis ON entcom.numfou = fournis.numfou
GROUP BY numcom
ORDER BY nomfou

-- 11-Sortir les produits des commandes ayant le mot "urgent" en observation?(Afficher le numéro de commande, le nom du fournisseur, le libellé du produit et le sous total= quantité commandée * Prix unitaire)

SELECT nomfou AS nomfournisseur, libart AS libelleproduit, ligcom.codart AS codeproduit, ligcom.numcom AS numerocommande, 
SUM(qtecde*priuni) AS soustotal
FROM ligcom
JOIN entcom ON ligcom.numcom = entcom.numcom
JOIN fournis ON entcom.numfou = fournis.numfou
JOIN produit ON ligcom.codart = produit.codart 
WHERE obscom LIKE '%urgent%'
GROUP BY ligcom.numcom, nomfou, libart

-- 12-Coder de 2 manières différentes la requête suivante: Lister le nom des fournisseurs susceptibles de livrer au moins un article

-- 1/ 

SELECT DISTINCT nomfou AS nomfournisseur
FROM fournis, entcom, ligcom
WHERE fournis.numfou = entcom.numfou 
AND entcom.numcom = ligcom.numcom
AND qteliv < qtecde

-- 2/

SELECT DISTINCT nomfou AS nomfournisseur
FROM fournis
JOIN entcom ON fournis.numfou = entcom.numfou
JOIN ligcom ON entcom.numcom = ligcom.numcom
WHERE qteliv < qtecde

-- 13-Coder de 2 manières différentes la requête suivante: Lister les commandes (Numéro et date) dont le fournisseur est celui de la commande 70210

-- 1/

SELECT numcom AS numerocommande, datcom AS datecommande
FROM entcom
WHERE numfou = (
    SELECT numfou
    FROM entcom
    WHERE numcom = 70210
)

-- 2/

SELECT numcom AS numerocommande, datcom AS datecommande 
FROM entcom
JOIN fournis ON entcom.numfou = fournis.numfou 
WHERE entcom.numfou = (
    SELECT entcom.numfou
    FROM entcom
    WHERE entcom.numcom = 70210
)

-- 14- Dans les articles susceptibles d’être vendus, lister les articles moins chers (basés sur Prix1) que le moins cher des rubans (article dont le premier caractère commence par R). On affichera le libellé de l’article et prix1

SELECT vente.codart, libart, prix1
FROM vente, produit 
WHERE produit.codart = vente.codart
AND vente.prix1 < (
    SELECT MIN(prix1)
    FROM vente
    WHERE vente.codart LIKE 'R%'
)
GROUP BY codart

-- 15- Editer la liste des fournisseurs susceptibles de livrer les produits dont le stock est inférieur ou égal à 150 % du stock d'alerte. La liste est triée par produit puis fournisseur

SELECT fournis.nomfou AS nomfournisseur,
vente.numfou AS numerofournisseur,
produit.libart AS libellearticle,
vente.codart AS codearticle
FROM fournis, produit, vente
WHERE fournis.numfou = vente.numfou
AND produit.codart = vente.codart 
AND produit.stkphy <= 1.5*produit.stkale
GROUP BY vente.codart, nomfou
ORDER BY vente.codart, nomfou

-- 16-Éditer la liste des fournisseurs susceptibles de livrer les produits dont le stock est inférieur ou égal à 150 % du stock d'alerte et un délai de livraison d'au plus 30 jours. La liste est triée par fournisseur puis produit

SELECT fournis.nomfou AS nomfournisseur,
vente.numfou AS numerofournisseur,
produit.libart AS libellearticle,
vente.codart AS codearticle
FROM fournis, produit, vente
WHERE fournis.numfou = vente.numfou
AND produit.codart = vente.codart
AND produit.stkphy <= 1.5*produit.stkale 
AND delliv <= 30
GROUP BY vente.codart, nomfou
ORDER BY vente.codart, nomfou

-- 17-Avec le même type de sélection que ci-dessus, sortir un total des stocks par fournisseur trié par total décroissant

SELECT SUM(produit.stkphy) AS stock, 
fournis.nomfou AS nomfournisseur, 
fournis.numfou AS numerofournisseur
FROM vente, fournis, produit
WHERE produit.codart = vente.codart
AND vente.numfou = fournis.numfou
GROUP BY nomfou
ORDER BY stock DESC

-- 18-En fin d'année, sortir la liste des produits dont la quantité réellement commandée dépasse 90% de la quantité annuelle prévue

SELECT ligcom.codart AS 'produitdepassant90%quantiteannuelle',
produit.libart AS libellearticle
FROM ligcom, produit
WHERE qtecde > 0.9*qteann 
AND ligcom.codart = produit.codart
GROUP BY ligcom.codart

-- 19-Calculer le chiffre d'affaire par fournisseur pour l'année 93 sachant que les prix indiqués sont hors taxes et que le taux de TVA est de 20%

SELECT SUM(qtecde*priuni*1.2) AS total, nomfou AS nomfournisseur 
FROM ligcom, fournis, entcom
WHERE ligcom.numcom = entcom.numcom
AND entcom.numfou = fournis.numfou
AND year(datcom) = 2018
GROUP BY nomfou
ORDER BY total DESC

-- LES BESOINS DE MISES A JOUR

-- 1-Application d'une augmentation de tarif de 4% pour le prix1, 2% pour le prix2 pour le fournisseur 9180

UPDATE vente
SET prix1 = prix1*1.04, prix2 = prix2*1.02
WHERE numfou = 9180

-- 2-Dans la table vente, mettre à jour le prix2 des articles dont le prix2 est null, en affectant a valeur de prix

UPDATE vente
SET prix2 = prix1
WHERE prix2 = 0

-- 3-Mettre à jour le champ obscom en postionnant '*****' pour toutes les commandes dont le fournisseur a un indice de satisfaction <5

UPDATE entcom, fournis
SET obscom = '*****'
WHERE entcom.numfou = fournis.numfou
AND fournis.satisf < 5

-- 4-Suppression du produit I110

DELETE FROM produit
WHERE codart = 'I110'
