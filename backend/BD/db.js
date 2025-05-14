const mysql = require('mysql2/promise');  // Assurez-vous d'utiliser mysql2 avec promesses

// Créer une connexion à la base de données avec le support des promesses
const connection = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'location_materiels',
  dateStrings: true,
});

// Exporter la connexion pour l'utiliser ailleurs dans le code
module.exports = connection;
