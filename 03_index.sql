-- Index pour les 3 recherches
USE tiroir;

-- R1 : objets actifs d'une categorie, du moins cher au plus cher
-- SELECT * FROM objet WHERE id_categorie = ? AND actif = TRUE ORDER BY prix_jour;
-- les colonnes du WHERE en premier, la colonne du tri a la fin : MySQL n'a plus besoin de trier
CREATE INDEX idx_objet_categorie ON objet (id_categorie, actif, prix_jour);

-- R2 : un objet est-il libre entre deux dates ?
-- SELECT COUNT(*) FROM location WHERE id_objet = ? AND statut = 'acceptee'
--   AND date_debut <= :fin AND date_fin >= :debut;   (0 = libre)
-- egalites d'abord (id_objet, statut) puis les dates. Le trigger de RG23 s'en sert aussi.
CREATE INDEX idx_location_objet ON location (id_objet, statut, date_debut, date_fin);

-- R3 : historique d'un membre, recent en premier
-- SELECT * FROM location WHERE id_locataire = ? ORDER BY date_debut DESC;
-- le tri DESC est deja dans l'index
CREATE INDEX idx_location_locataire ON location (id_locataire, date_debut DESC);
