const db = require('../BD/db');

const getAllMateriels = async (req, res) => {
  const sql = 'SELECT * FROM materiels';

  try {
    const [results] = await db.query(sql);
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des matériels:', err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  getAllMateriels
};
