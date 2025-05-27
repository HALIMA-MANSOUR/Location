const db = require('../BD/db');

// 🔹 Récupérer tous les matériels (avec filtre catégorie possible)
const getAllMateriels = async (req, res) => {
  const categorieId = req.query.categorieId || req.query.category_id;

  const sql = categorieId
    ? 'SELECT * FROM materiels WHERE categorie_id = ?'
    : 'SELECT * FROM materiels';

  try {
    const [results] = await db.query(sql, categorieId ? [categorieId] : []);
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des matériels:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

// 🔹 Récupérer toutes les catégories
const getAllCategories = async (req, res) => {
  try {
    const [results] = await db.query('SELECT * FROM categories');
    res.json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des catégories:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


const addMateriel = async (req, res) => {
  const { body, files } = req; 
  const { nom, description, prix_journalier, disponible, categorie_id } = body;
const imageFile = files.find(file => file.fieldname === 'image_url');
  const baseUrl = 'http://localhost:3000/';

  const image_url = imageFile ? `${baseUrl}images/${imageFile.filename}` : null;

  if (!nom || !prix_journalier || !categorie_id) {
    return res.status(400).json({ message: 'Nom, prix_journalier et categorie_id sont requis' });
  }

  if (!image_url) {
    return res.status(400).json({ error: "L'image est requise." });
  }

  try {
    const sql = `
      INSERT INTO materiels (nom, description, image_url, prix_journalier, disponible, categorie_id)
      VALUES (?, ?, ?, ?, ?, ?)`;
    const [result] = await db.execute(sql, [
      nom,
      description || '',
      image_url,
      prix_journalier,
      disponible ?? true,
      categorie_id
    ]);
    res.status(201).json({ message: 'Matériel ajouté', id: result.insertId });
  } catch (err) {
    console.error('Erreur ajout matériel:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


const updateMateriel = async (req, res) => {
  const { id } = req.params;
  const fields = req.body;

  if (!id || Object.keys(fields).length === 0) {
    return res.status(400).json({ message: 'ID et au moins un champ à mettre à jour sont requis' });
  }

  const allowedFields = ['nom', 'description', 'image_url', 'prix_journalier', 'disponible', 'categorie_id'];
  const updates = [];
  const values = [];

  for (const key of allowedFields) {
    if (fields[key] !== undefined) {
      updates.push(`${key} = ?`);
      values.push(fields[key]);
    }
  }

  if (updates.length === 0) {
    return res.status(400).json({ message: 'Aucun champ valide à mettre à jour' });
  }

  const sql = `UPDATE materiels SET ${updates.join(', ')} WHERE id = ?`;
  values.push(id);

  try {
    await db.execute(sql, values);
    res.json({ message: 'Matériel mis à jour avec succès' });
  } catch (err) {
    console.error('Erreur mise à jour matériel:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};


const deleteMateriel = async (req, res) => {
  const id = req.params.id;

  try {
    await db.execute('DELETE FROM materiels WHERE id = ?', [id]);
    res.json({ message: 'Matériel supprimé' });
  } catch (err) {
    console.error('Erreur suppression matériel:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  getAllMateriels,
  getAllCategories,
  addMateriel,
  updateMateriel,
  deleteMateriel
};
