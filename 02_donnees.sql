-- Tiroir : jeu d'essai
USE tiroir;

INSERT INTO membre (nom, prenom, pseudo, email, telephone, code_postal) VALUES
('Ferrand', 'Julie',  'julief',      'julie.ferrand@tiroir.fr', '0612345678', '75011'),
('Martin',  'Lucas',  'lucas_brico', 'lucas.martin@mail.fr',    '0623456789', '69003'),
('Benali',  'Sofia',  'sofia_b',     'sofia.benali@mail.fr',    '0634567890', '42000'),
('Dupont',  'Hugo',   'hugod',       'hugo.dupont@mail.fr',     '0645678901', '92500'),
('Nguyen',  'Emma',   'emma.ng',     'emma.nguyen@mail.fr',     '0656789012', '33000'),
('Moreau',  'Thomas', 'tom_camp',    'thomas.moreau@mail.fr',   '0667890123', '13001');

-- les categories racines d'abord, ensuite les sous-categories
INSERT INTO categorie (libelle, id_categorie_parent) VALUES
('Bricolage', NULL),  -- 1
('Camping',   NULL),  -- 2
('Cuisine',   NULL),  -- 3
('Jardin',    NULL);  -- 4

INSERT INTO categorie (libelle, id_categorie_parent) VALUES
('Perceuses', 1),             -- 5
('Ponceuses', 1),             -- 6
('Tentes', 2),                -- 7
('Appareils a raclette', 3),  -- 8
('Tondeuses', 4);             -- 9

-- l'objet 7 est en pause
INSERT INTO objet (titre, description, prix_jour, caution, etat, actif, id_membre, id_categorie) VALUES
('Perceuse Bosch 18V',         'Perceuse visseuse sans fil, 2 batteries', 8.00,  80.00,  'tres_bon', TRUE,  2, 5), -- 1
('Perceuse a percussion',      'Makita 750W, ideale beton',               6.50,  60.00,  'bon',      TRUE,  4, 5), -- 2
('Tente 4 places Quechua',     'Tente 2 seconds, montage rapide',         12.00, 150.00, 'neuf',     TRUE,  6, 7), -- 3
('Appareil a raclette 8 pers', 'Avec grill, 8 poelons',                   5.00,  40.00,  'tres_bon', TRUE,  3, 8), -- 4
('Ponceuse excentrique',       'Black+Decker, disques fournis',           4.00,  50.00,  'use',      TRUE,  2, 6), -- 5
('Tondeuse thermique',         'Coupe 46 cm, bac 55 L',                   15.00, 200.00, 'bon',      TRUE,  5, 9), -- 6
('Tente 2 places',             'Tente legere de randonnee',               7.00,  80.00,  'bon',      FALSE, 6, 7), -- 7
('Mini appareil a raclette',   'Pour 2 personnes',                        3.00,  20.00,  'neuf',     TRUE,  1, 8); -- 8

INSERT INTO photo (id_objet, numero, url) VALUES
(1, 1, 'https://cdn.tiroir.fr/objets/1/1.jpg'),
(1, 2, 'https://cdn.tiroir.fr/objets/1/2.jpg'),
(2, 1, 'https://cdn.tiroir.fr/objets/2/1.jpg'),
(3, 1, 'https://cdn.tiroir.fr/objets/3/1.jpg'),
(3, 2, 'https://cdn.tiroir.fr/objets/3/2.jpg'),
(3, 3, 'https://cdn.tiroir.fr/objets/3/3.jpg'),
(4, 1, 'https://cdn.tiroir.fr/objets/4/1.jpg'),
(6, 1, 'https://cdn.tiroir.fr/objets/6/1.jpg');

-- le prix_total est calcule par le trigger
INSERT INTO location (date_debut, date_fin, statut, date_demande, id_objet, id_locataire) VALUES
('2026-06-05', '2026-06-07', 'terminee', '2026-06-01 10:00:00', 1, 3),  -- 1 : 3 j x 8   = 24
('2026-07-10', '2026-07-17', 'terminee', '2026-07-01 09:30:00', 3, 1),  -- 2 : 8 j x 12  = 96
('2026-08-15', '2026-08-15', 'terminee', '2026-08-10 18:00:00', 4, 5),  -- 3 : 1 j x 5   = 5
('2026-09-01', '2026-09-03', 'terminee', '2026-08-25 12:00:00', 6, 4),  -- 4 : 3 j x 15  = 45
('2026-09-20', '2026-09-21', 'terminee', '2026-09-15 14:00:00', 2, 2),  -- 5 : 2 j x 6.5 = 13
('2026-10-02', '2026-10-04', 'annulee',  '2026-09-28 08:00:00', 5, 6),  -- 6
('2026-11-20', '2026-11-25', 'acceptee', '2026-11-01 11:00:00', 3, 4),  -- 7
('2026-11-26', '2026-11-28', 'acceptee', '2026-11-02 16:00:00', 3, 5),  -- 8 : juste apres la 7, ca passe
('2026-11-22', '2026-11-24', 'refusee',  '2026-11-03 10:00:00', 3, 2),  -- 9 : chevauche la 7 mais refusee donc ok
('2026-12-01', '2026-12-05', 'demandee', '2026-11-05 20:00:00', 1, 6);  -- 10

-- avis seulement sur les locations terminees (1 a 5)
INSERT INTO avis (id_location, cote, note, commentaire) VALUES
(1, 'locataire',    5, 'Perceuse au top, batteries chargees.'),
(1, 'proprietaire', 5, 'Locataire ponctuel et soigneux.'),
(2, 'locataire',    4, 'Tente propre, un peu longue a replier.'),
(2, 'proprietaire', 5, NULL),
(3, 'locataire',    3, 'Un poelon manquant.'),
(4, 'proprietaire', 4, 'Rendue un peu sale mais OK.');

INSERT INTO favori (id_membre, id_objet, date_ajout) VALUES
(1, 1, '2026-05-20 10:00:00'),
(1, 6, '2026-08-01 12:30:00'),
(3, 3, '2026-06-15 09:00:00'),
(4, 4, '2026-09-10 19:45:00'),
(5, 3, '2026-10-20 21:00:00'),
(6, 2, '2026-10-30 07:15:00');
