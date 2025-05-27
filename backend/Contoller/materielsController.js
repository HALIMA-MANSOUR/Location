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
  const { nom, description, prix_journalier, disponible, categorie_id } = req.body;
  const { files } = req;

  const imageFile = files?.find(file => file.fieldname === 'image_url');
  const baseUrl = 'http://localhost:3000/';
  const image_url = imageFile ? `${baseUrl}images/${imageFile.filename}` : null;

  try {
    // Récupérer l’ancien matériel
    const [rows] = await db.execute('SELECT * FROM materiels WHERE id = ?', [id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Matériel introuvable' });
    }

    const ancien = rows[0];

    // Mise à jour avec nouvelle image ou ancienne si pas changée
    const sql = `
      UPDATE materiels SET 
        nom = ?, 
        description = ?, 
        image_url = ?, 
        prix_journalier = ?, 
        disponible = ?, 
        categorie_id = ?
      WHERE id = ?`;

    await db.execute(sql, [
      nom ?? ancien.nom,
      description ?? ancien.description,
      image_url ?? ancien.image_url,
      prix_journalier ?? ancien.prix_journalier,
      disponible ?? ancien.disponible,
      categorie_id ?? ancien.categorie_id,
      id,
    ]);

    res.status(200).json({ message: 'Matériel modifié' });
  } catch (err) {
    console.error('Erreur modification matériel:', err);
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
