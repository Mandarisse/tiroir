-- Migration : commission sur les locations (base en prod, on ne bloque pas la table)
USE tiroir;

-- ALGORITHM=INSTANT : MySQL change juste la structure, il ne recopie pas la table.
-- Si c'est impossible il renvoie une erreur plutot que de bloquer.
ALTER TABLE location
    ADD COLUMN commission DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ALGORITHM = INSTANT;

-- pas de CHECK (commission >= 0) : ca recopierait la table et bloquerait les ecritures

-- 10 % du prix total pour les locations deja terminees
START TRANSACTION;
UPDATE location SET commission = ROUND(prix_total * 0.10, 2) WHERE statut = 'terminee';
COMMIT;
