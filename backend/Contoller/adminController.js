const db = require('../BD/db');

// ✅ 1. Fonction pour obtenir toutes les réservations avec les statuts
const getAllReservations = async (req, res) => {
  const sql = `
    SELECT l.*, m.nom AS nom_materiel, u.nom AS nom_utilisateur
    FROM locations l
    JOIN materiels m ON l.materiel_id = m.id
    JOIN users u ON l.user_id = u.id
    ORDER BY l.date_debut DESC
  `;
  try {
    const [results] = await db.promise().query(sql);
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des réservations:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

const updateReservationStatus = async (req, res) => {
  const id = req.params.id;
  const { statut } = req.body;

  const selectSql = `SELECT statut FROM locations WHERE id = ?`;

  try {
    // Récupérer le statut actuel
    const [results] = await db.promise().query(selectSql, [id]);

    if (results.length === 0) {
      return res.status(404).json({ message: 'Réservation introuvable' });
    }

    const currentStatus = results[0].statut;

    // Règle 1 : Interdire de revenir à "en_attente"
    if (statut === 'en_attente') {
      return res.status(403).json({ message: 'Impossible de revenir au statut "en_attente".' });
    }

    // Règle 2 : Si actuel est "confirmee", interdire de passer à "annulee"
    if ((currentStatus === 'confirmee' || currentStatus === 'terminee') && statut === 'annulee') {
      return res.status(403).json({ message: 'Impossible d’annuler une réservation déjà confirmée ou terminée.' });
    }

    // Mise à jour autorisée
    const updateSql = `UPDATE locations SET statut = ? WHERE id = ?`;
    const [updateResult] = await db.promise().query(updateSql, [statut, id]);

    if (updateResult.affectedRows === 0) {
      return res.status(404).json({ message: 'Réservation introuvable' });
    }

    res.status(200).json({
      message: 'Statut de la réservation mis à jour avec succès',
      id: id,
      statut: statut
    });
  } catch (err) {
    console.error('Erreur lors de la mise à jour du statut:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  getAllReservations,
  updateReservationStatus
};
