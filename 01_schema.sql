-- TP Tiroir - creation de la base (MySQL 8)
-- RGxx = regles de gestion de regles.txt

DROP DATABASE IF EXISTS tiroir;
CREATE DATABASE tiroir CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tiroir;

CREATE TABLE membre (
    id_membre   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom         VARCHAR(50)  NOT NULL,
    prenom      VARCHAR(50)  NOT NULL,
    pseudo      VARCHAR(30)  NOT NULL UNIQUE,   -- RG02
    email       VARCHAR(255) NOT NULL UNIQUE,   -- RG03
    telephone   VARCHAR(20)  NOT NULL,
    code_postal CHAR(5)      NOT NULL           -- RG01
);

CREATE TABLE categorie (
    id_categorie        INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    libelle             VARCHAR(60)  NOT NULL UNIQUE,
    id_categorie_parent INT UNSIGNED NULL,      -- NULL = pas de parente (RG13)
    FOREIGN KEY (id_categorie_parent) REFERENCES categorie (id_categorie)
);

CREATE TABLE objet (
    id_objet     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    titre        VARCHAR(100) NOT NULL,
    description  TEXT         NOT NULL,
    prix_jour    DECIMAL(8,2) NOT NULL CHECK (prix_jour > 0),       -- RG08
    caution      DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (caution >= 0), -- RG09
    etat         ENUM('neuf','tres_bon','bon','use') NOT NULL,      -- RG07
    actif        BOOLEAN      NOT NULL DEFAULT TRUE,                -- RG10 (FALSE = en pause)
    id_membre    INT UNSIGNED NOT NULL,         -- proprietaire (RG05)
    id_categorie INT UNSIGNED NOT NULL,         -- RG12
    FOREIGN KEY (id_membre)    REFERENCES membre (id_membre),
    FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie)
);

CREATE TABLE photo (
    id_objet INT UNSIGNED     NOT NULL,
    numero   TINYINT UNSIGNED NOT NULL CHECK (numero >= 1),
    url      VARCHAR(255)     NOT NULL,
    PRIMARY KEY (id_objet, numero),             -- RG16
    FOREIGN KEY (id_objet) REFERENCES objet (id_objet) ON DELETE CASCADE  -- RG17
);

CREATE TABLE location (
    id_location  INT UNSIGNED  NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date_debut   DATE          NOT NULL,
    date_fin     DATE          NOT NULL,
    prix_total   DECIMAL(10,2) NOT NULL DEFAULT 0,   -- rempli par le trigger (RG20)
    statut       ENUM('demandee','acceptee','refusee','annulee','terminee')
                               NOT NULL DEFAULT 'demandee',   -- RG21
    date_demande DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_objet     INT UNSIGNED  NOT NULL,
    id_locataire INT UNSIGNED  NOT NULL,
    CHECK (date_fin >= date_debut),                  -- RG19
    FOREIGN KEY (id_objet)     REFERENCES objet (id_objet),
    FOREIGN KEY (id_locataire) REFERENCES membre (id_membre)
);

-- cote : 'locataire' = il note l'objet, 'proprietaire' = il note le locataire
CREATE TABLE avis (
    id_location INT UNSIGNED NOT NULL,
    cote        ENUM('locataire','proprietaire') NOT NULL,
    note        TINYINT UNSIGNED NOT NULL CHECK (note BETWEEN 1 AND 5),  -- RG26
    commentaire TEXT NULL,
    date_avis   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_location, cote),                 -- RG27
    FOREIGN KEY (id_location) REFERENCES location (id_location) ON DELETE CASCADE
);

CREATE TABLE favori (
    id_membre  INT UNSIGNED NOT NULL,
    id_objet   INT UNSIGNED NOT NULL,
    date_ajout DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- RG29
    PRIMARY KEY (id_membre, id_objet),               -- RG28
    FOREIGN KEY (id_membre) REFERENCES membre (id_membre) ON DELETE CASCADE,
    FOREIGN KEY (id_objet)  REFERENCES objet (id_objet)   ON DELETE CASCADE
);


-- Triggers (pour ce que CHECK ne peut pas faire)
DELIMITER $$

-- RG14 : une categorie ne peut pas etre sa propre parente
CREATE TRIGGER categorie_avant_maj BEFORE UPDATE ON categorie
FOR EACH ROW
BEGIN
    IF NEW.id_categorie_parent = NEW.id_categorie THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG14 : une categorie ne peut pas etre sa propre parente';
    END IF;
END$$

-- RG11, RG20, RG22, RG23
CREATE TRIGGER location_avant_ajout BEFORE INSERT ON location
FOR EACH ROW
BEGIN
    DECLARE proprio INT UNSIGNED;
    DECLARE prix DECIMAL(8,2);
    DECLARE est_actif BOOLEAN;

    SELECT id_membre, prix_jour, actif INTO proprio, prix, est_actif
    FROM objet WHERE id_objet = NEW.id_objet;

    IF NEW.id_locataire = proprio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG22 : impossible de louer son propre objet';
    END IF;

    IF est_actif = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG11 : objet en pause';
    END IF;

    -- prix du jour x nombre de jours (on compte le premier et le dernier jour)
    SET NEW.prix_total = prix * (DATEDIFF(NEW.date_fin, NEW.date_debut) + 1);

    IF NEW.statut = 'acceptee' AND EXISTS (
        SELECT 1 FROM location
        WHERE id_objet = NEW.id_objet AND statut = 'acceptee'
          AND date_debut <= NEW.date_fin AND date_fin >= NEW.date_debut
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG23 : objet deja loue sur cette periode';
    END IF;
END$$

CREATE TRIGGER location_avant_maj BEFORE UPDATE ON location
FOR EACH ROW
BEGIN
    DECLARE proprio INT UNSIGNED;

    IF NEW.prix_total <> OLD.prix_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG20 : le prix total ne change pas';
    END IF;

    SELECT id_membre INTO proprio FROM objet WHERE id_objet = NEW.id_objet;
    IF NEW.id_locataire = proprio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG22 : impossible de louer son propre objet';
    END IF;

    IF NEW.statut = 'acceptee' AND EXISTS (
        SELECT 1 FROM location
        WHERE id_objet = NEW.id_objet AND id_location <> NEW.id_location
          AND statut = 'acceptee'
          AND date_debut <= NEW.date_fin AND date_fin >= NEW.date_debut
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG23 : objet deja loue sur cette periode';
    END IF;
END$$

-- RG24
CREATE TRIGGER avis_avant_ajout BEFORE INSERT ON avis
FOR EACH ROW
BEGIN
    IF (SELECT statut FROM location WHERE id_location = NEW.id_location) <> 'terminee' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG24 : la location n''est pas terminee';
    END IF;
END$$

CREATE TRIGGER avis_avant_maj BEFORE UPDATE ON avis
FOR EACH ROW
BEGIN
    IF (SELECT statut FROM location WHERE id_location = NEW.id_location) <> 'terminee' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG24 : la location n''est pas terminee';
    END IF;
END$$

DELIMITER ;
