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

module.exports = { createUser };
