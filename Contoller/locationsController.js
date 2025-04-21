const db = require('../BD/db');


const createLocation = (req, res) => {
    const { materiel_id, date_debut, date_fin } = req.body;
    const user_id = 1;
  
    // 1. Vérifier si le matériel est disponible
    const checkDisponibiliteSql = `
      SELECT disponible FROM materiels WHERE id = ?
    `;
  
    db.query(checkDisponibiliteSql, [materiel_id], (err, results) => {
      if (err) {
        console.error('Erreur lors de la vérification de disponibilité :', err);
        return res.status(500).json({ error: 'Erreur serveur' });
      }
  
      if (results.length === 0) {
        return res.status(404).json({ message: 'Matériel introuvable' });
      }
  
      const disponible = results[0].disponible;
      if (!disponible) {
        return res.status(400).json({ message: 'Ce matériel n\'est pas disponible actuellement' });
      }
  
      // 2. Si disponible, procéder à l'insertion
      const insertSql = `
        INSERT INTO locations (user_id, materiel_id, date_debut, date_fin)
        VALUES (?, ?, ?, ?)
      `;
  
      db.query(insertSql, [user_id, materiel_id, date_debut, date_fin], (err, result) => {
        if (err) {
          console.error('Erreur lors de la création de la location:', err);
          return res.status(500).json({ error: 'Erreur serveur' });
        }
  
        res.status(201).json({
          message: 'Location créée avec succès',
          locationId: result.insertId
        });
      });
    });
  };
  

const getAllLocations = (req, res) => {
  const sql = `
    SELECT l.*, m.nom AS nom_materiel, u.nom AS nom_utilisateur
    FROM locations l
    JOIN materiels m ON l.materiel_id = m.id
    JOIN users u ON l.user_id = u.id
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des locations:', err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
    res.json(results);
  });
};
const updateLocation = (req, res) => {
  const id = req.params.id; // récupérer l'ID de l'URL
  const { materiel_id, date_debut, date_fin } = req.body;

  // Vérifier que date_debut >= aujourd'hui
  const today = new Date();
  const debut = new Date(date_debut);

  // Réinitialiser l'heure pour la comparaison (ignorer heures/minutes)
  today.setHours(0, 0, 0, 0);
  debut.setHours(0, 0, 0, 0);

  if (debut < today) {
    return res.status(400).json({ message: "La date de début est déjà passée" });
  }

  // 1. Vérifier si le matériel existe
  const checkDisponibiliteSql = `
    SELECT disponible FROM materiels WHERE id = ?
  `;
  db.query(checkDisponibiliteSql, [materiel_id], (err, results) => {
    if (err) {
      console.error('Erreur lors de la vérification de disponibilité :', err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'Matériel introuvable' });
    }

    const disponible = results[0].disponible;
    if (!disponible) {
      return res.status(400).json({ message: 'Ce matériel n\'est pas disponible actuellement' });
    }

    // 2. Vérifier chevauchement avec d'autres réservations
    const checkOverlapSql = `
      SELECT * FROM locations 
      WHERE materiel_id = ? AND (
        (date_debut BETWEEN ? AND ?) OR 
        (date_fin BETWEEN ? AND ?)
      ) AND id != ?
    `;

    db.query(checkOverlapSql, [materiel_id, date_debut, date_fin, date_debut, date_fin, id], (err, overlapResults) => {
      if (err) {
        console.error('Erreur lors de la vérification des chevauchements de dates:', err);
        return res.status(500).json({ error: 'Erreur serveur' });
      }

      if (overlapResults.length > 0) {
        return res.status(400).json({ message: 'Ce matériel est déjà réservé pour cette période' });
      }

      // 3. Mise à jour
      const updateSql = `
        UPDATE locations
        SET materiel_id = ?, date_debut = ?, date_fin = ?
        WHERE id = ?
      `;

      db.query(updateSql, [materiel_id, date_debut, date_fin, id], (err, result) => {
        if (err) {
          console.error('Erreur lors de la mise à jour de la réservation:', err);
          return res.status(500).json({ error: 'Erreur serveur' });
        }

        if (result.affectedRows === 0) {
          return res.status(404).json({ message: 'Réservation introuvable' });
        }

        res.status(200).json({
          message: 'Réservation mise à jour avec succès',
          locationId: id
        });
      });
    });
  });
};



module.exports = {
  createLocation,
  getAllLocations,
  updateLocation
};
