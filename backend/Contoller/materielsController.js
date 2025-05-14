const db = require('../BD/db');

const getAllMateriels = async (req, res) => {
  const categorieId = req.query.categorieId || req.query.category_id; // Accepte les deux noms

  const sql = categorieId
    ? 'SELECT * FROM materiels WHERE categorie_id = ?'
    : 'SELECT * FROM materiels';

  try {
    const [results] = await db.query(sql, categorieId ? [categorieId] : []);
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des matériels:', err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

// Récupérer toutes les catégories
const getAllCategories = async (req, res) => {
  const sql = 'SELECT * FROM categories';

  try {
    const [results] = await db.query(sql);
    res.json(results); // Retourne les catégories
  } catch (err) {
    console.error('Erreur lors de la récupération des catégories:', err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  getAllMateriels,
  getAllCategories
};
