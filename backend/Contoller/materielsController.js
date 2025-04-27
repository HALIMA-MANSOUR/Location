
const db = require('../BD/db');


const getAllMateriels = (req, res) => {
  const sql = 'SELECT * FROM materiels';

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des matériels:', err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
    res.json(results);
  });
};

module.exports = {
  getAllMateriels
};
