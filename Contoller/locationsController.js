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

module.exports = {
  createLocation,
  getAllLocations
};
