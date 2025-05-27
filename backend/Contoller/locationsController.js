const db = require('../BD/db');

// Fonction pour créer une location
const createLocation = async (req, res) => {
  const { user_id, materiel_id, date_debut, date_fin, prix, total } = req.body;

  try {
    // 1. Vérifier si le matériel existe et est disponible
    const [disponibiliteResults] = await db.query(
      'SELECT disponible FROM materiels WHERE id = ?',
      [materiel_id]
    );

    if (disponibiliteResults.length === 0) {
      return res.status(404).json({ message: 'Matériel introuvable' });
    }

    const disponible = disponibiliteResults[0].disponible;
    if (!disponible) {
      return res.status(400).json({ message: 'Ce matériel n\'est pas disponible actuellement' });
    }

    // 2. Insérer la location liée à ce user
    const [result] = await db.query(
      'INSERT INTO locations (user_id, materiel_id, date_debut, date_fin, prix, total) VALUES (?, ?, ?, ?, ?, ?)',
      [user_id, materiel_id, date_debut, date_fin, prix, total]
    );

    res.status(201).json({
      message: 'Location créée avec succès',
      locationId: result.insertId
    });

  } catch (err) {
    console.error('Erreur lors de la création de la location:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


// Fonction pour obtenir toutes les locations
const getAllLocations = async (req, res) => {
  try {
    const [results] = await db.query(
      `SELECT l.*, m.nom AS nom_materiel, u.nom AS nom_utilisateur
       FROM locations l
       JOIN materiels m ON l.materiel_id = m.id
       JOIN users u ON l.user_id = u.id`
    );
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des locations:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

// Fonction pour mettre à jour une location
const updateLocation = async (req, res) => {
  const id = req.params.id; // récupérer l'ID de la réservation
  const { materiel_id, date_debut, date_fin } = req.body;

  const today = new Date();
  const debut = new Date(date_debut);
  const fin = new Date(date_fin);

  today.setHours(0, 0, 0, 0);
  debut.setHours(0, 0, 0, 0);
  fin.setHours(0, 0, 0, 0);

  if (debut < today) {
    return res.status(400).json({ message: "La date de début est déjà passée" });
  }

  if (fin <= debut) {
    return res.status(400).json({ message: "La date de fin doit être après la date de début" });
  }

  try {
    // Vérifier la disponibilité du matériel
    const [disponibiliteResults] = await db.query('SELECT disponible FROM materiels WHERE id = ?', [materiel_id]);

    if (disponibiliteResults.length === 0) {
      return res.status(404).json({ message: 'Matériel introuvable' });
    }

    const { disponible } = disponibiliteResults[0];
    if (!disponible) {
      return res.status(400).json({ message: 'Ce matériel n\'est pas disponible actuellement' });
    }

    // Vérifier s'il y a un chevauchement avec d'autres réservations
    const [overlapResults] = await db.query(
      `SELECT * FROM locations 
       WHERE materiel_id = ? AND (
         (date_debut BETWEEN ? AND ?) OR 
         (date_fin BETWEEN ? AND ?)
       ) AND id != ?`, 
      [materiel_id, date_debut, date_fin, date_debut, date_fin, id]
    );

    if (overlapResults.length > 0) {
      return res.status(400).json({ message: 'Ce matériel est déjà réservé pour cette période' });
    }

    // Récupérer le prix de la réservation existante dans la table "locations"
    const [prixResults] = await db.query('SELECT prix FROM locations WHERE id = ?', [id]);

    if (prixResults.length === 0) {
      return res.status(404).json({ message: 'Réservation introuvable' });
    }

    const { prix } = prixResults[0];

    // Calcul du nombre de jours
    const msPerDay = 24 * 60 * 60 * 1000; // millisecondes par jour
    const nombreDeJours = Math.round((fin - debut) / msPerDay);

    // Calcul du total
    const total = nombreDeJours * prix;

    // Mise à jour de la réservation avec le nouveau total
    const [updateResult] = await db.query(
      `UPDATE locations SET materiel_id = ?, date_debut = ?, date_fin = ?, total = ? WHERE id = ?`,
      [materiel_id, date_debut, date_fin, total, id]
    );

    if (updateResult.affectedRows === 0) {
      return res.status(404).json({ message: 'Réservation introuvable' });
    }

    res.status(200).json({
      message: 'Réservation mise à jour avec succès',
      locationId: id,
      nombreDeJours: nombreDeJours,
      total: total
    });

  } catch (err) {
    console.error('Erreur lors de la mise à jour de la réservation:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

const deleteLocation = async (req, res) => {
  const id = req.params.id;

  try {
    // Vérifier si la location existe avant de la supprimer
    const [locationResult] = await db.query('SELECT * FROM locations WHERE id = ?', [id]);

    if (locationResult.length === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }

    // Supprimer la location
    await db.query('DELETE FROM locations WHERE id = ?', [id]);

    res.status(200).json({ message: 'Réservation supprimée avec succès' });
  } catch (err) {
    console.error('Erreur lors de la suppression de la réservation:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

const getLocationsByUserId = async (req, res) => {
  const { userId } = req.params;

  try {
    const [results] = await db.query(
      `SELECT l.*, m.nom AS nom_materiel, u.nom AS nom_utilisateur
       FROM locations l
       JOIN materiels m ON l.materiel_id = m.id
       JOIN users u ON l.user_id = u.id
       WHERE l.user_id = ?`,
      [userId]
    );

    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des locations par utilisateur:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  createLocation,
  getAllLocations,
  updateLocation,
  deleteLocation,
  getLocationsByUserId,
};
