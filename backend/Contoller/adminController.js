const db = require('../BD/db');


const getAllReservations = async (req, res) => {
  const sql = `
    SELECT l.*, m.nom AS nom_materiel, u.nom AS nom_utilisateur
    FROM locations l
    JOIN materiels m ON l.materiel_id = m.id
    JOIN users u ON l.user_id = u.id
    ORDER BY l.date_debut DESC
  `;
  try {
    const [results] = await db.query(sql); // plus besoin de .promise()
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des réservations:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


const updateReservationStatus = async (req, res) => {
  const id = req.params.id;
  const { statut } = req.body;

  try {
    // Étape 1 : Vérifie si la réservation existe
    const [results] = await db.query(
      `SELECT statut FROM locations WHERE id = ?`,
      [id]
    );

    if (results.length === 0) {
      return res.status(404).json({ message: 'Réservation introuvable' });
    }

    const currentStatus = results[0].statut;

    // Étape 2 : Applique les règles métier
    // Si statut actuel est "en_attente"
    if (currentStatus === 'en_attente') {
      if (statut === 'confirmee' || statut === 'annulee') {
        // Changement autorisé vers "confirmée" ou "annulée"
        const [updateResult] = await db.query(
          `UPDATE locations SET statut = ? WHERE id = ?`,
          [statut, id]
        );
        if (updateResult.affectedRows === 0) {
          return res.status(404).json({ message: 'Aucune mise à jour effectuée. Réservation introuvable.' });
        }
        return res.status(200).json({
          message: 'Statut de la réservation mis à jour avec succès',
          id: id,
          nouveauStatut: statut
        });
      } else {
        return res.status(403).json({ message: 'Changement non autorisé depuis "en_attente".' });
      }
    }

    // Si statut actuel est "confirmee" ou "annulee"
    if (currentStatus === 'confirmee' || currentStatus === 'annulee') {
      return res.status(403).json({ message: 'Une réservation confirmée ou annulée ne peut plus être modifiée.' });
    }

    // Si statut actuel est "payee"
    if (currentStatus === 'payee') {
      if (statut === 'terminee') {
        const [updateResult] = await db.query(
          `UPDATE locations SET statut = ? WHERE id = ?`,
          [statut, id]
        );
        if (updateResult.affectedRows === 0) {
          return res.status(404).json({ message: 'Aucune mise à jour effectuée. Réservation introuvable.' });
        }
        return res.status(200).json({
          message: 'Statut de la réservation mis à jour avec succès',
          id: id,
          nouveauStatut: statut
        });
      } else {
        return res.status(403).json({ message: 'Seule la mise à jour vers "terminée" est autorisée pour une réservation payée.' });
      }
    }

    // Si statut actuel est "terminee"
    if (currentStatus === 'terminee') {
      return res.status(403).json({ message: 'Une réservation terminée ne peut plus être modifiée.' });
    }

    // Cas non pris en charge
    return res.status(400).json({ message: 'Statut inconnu ou modification non autorisée.' });
  } catch (err) {
    console.error('Erreur lors de la mise à jour du statut:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


module.exports = {
  getAllReservations,
  updateReservationStatus
};
