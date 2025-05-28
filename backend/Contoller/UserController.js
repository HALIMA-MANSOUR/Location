const db = require('../BD/db');
const bcrypt = require('bcrypt');

const createUser = async (req, res) => {
  const { nom, email, mot_de_passe } = req.body;

  // Vérifier que tous les champs sont présents
  if (!nom || !email || !mot_de_passe) {
    return res.status(400).json({ message: 'Tous les champs sont requis' });
  }

  // Vérifier le format de l’email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: 'Format d\'email invalide' });
  }

  try {
    // Vérifier si l’email existe déjà
    const [existingUser] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existingUser.length > 0) {
      return res.status(409).json({ message: 'Cet email est déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

    // Insérer le nouvel utilisateur
    const [result] = await db.execute(
      `INSERT INTO users (nom, email, mot_de_passe) VALUES (?, ?, ?)`,
      [nom, email, hashedPassword]
    );

    res.status(201).json({ message: 'Utilisateur créé avec succès', userId: result.insertId });
  } catch (error) {
    console.error('Erreur création utilisateur :', error);
    res.status(500).json({ message: 'Erreur serveur lors de la création du compte' });
  }
};
const loginUser = async (req, res) => {
  const { email, mot_de_passe } = req.body;

  if (!email || !mot_de_passe) {
    return res.status(400).json({ success: false, message: 'Email et mot de passe requis' });
  }

  try {
    const [results] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

    if (results.length === 0) {
      return res.status(401).json({ success: false, message: 'Utilisateur introuvable' });
    }

    const user = results[0];

    const isMatch = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Mot de passe incorrect' });
    }

    return res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      user: {
        id: user.id,
        nom: user.nom,
        email: user.email,
        role:user.role
      }
    });
  } catch (error) {
    console.error('Erreur :', error);
    return res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
};
const getUser = async (req, res) => {
  const userId = req.params.id;

  try {
    const [results] = await db.execute('SELECT id, nom, email, role FROM users WHERE id = ?', [userId]);

    if (results.length === 0) {
      return res.status(404).json({ success: false, message: 'Utilisateur introuvable' });
    }

    const user = results[0];

    res.status(200).json({ success: true, user });
  } catch (error) {
    console.error('Erreur lors de la récupération du profil utilisateur :', error);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
};
const modifierUser = async (req, res) => {
  const userId = req.params.userId; 
  const { nom, email } = req.body;

  if (!nom && !email) {
    return res.status(400).json({ success: false, message: 'Aucune donnée à mettre à jour.' });
  }

  let fields = [];
  let values = [];

  if (nom) {
    fields.push('nom = ?');
    values.push(nom);
  }

  if (email) {
    fields.push('email = ?');
    values.push(email);
  }

  values.push(userId);

  const sql = `UPDATE users SET ${fields.join(', ')} WHERE id = ?`;

  try {
    const [result] = await db.execute(sql, values);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

    res.json({ success: true, message: 'Utilisateur mis à jour avec succès.' });
  } catch (err) {
    console.error('Erreur MySQL:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur.' });
  }
};
const deleteUser = (req, res) => {
  const userId = req.params.id;

  const sql = 'DELETE FROM users WHERE id = ?';

  db.query(sql, [userId], (err, result) => {
    if (err) {
      console.error('Erreur lors de la suppression :', err);
      return res.status(500).json({ success: false, message: 'Erreur serveur' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé' });
    }

    return res.json({ success: true, message: 'Utilisateur supprimé avec succès' });
  });
};
module.exports = { createUser,loginUser ,getUser,modifierUser,deleteUser};
