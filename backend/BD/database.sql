
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('client', 'admin') DEFAULT 'client',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL
);

CREATE TABLE materiels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    prix_journalier DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE,
    categorie_id INT,
    FOREIGN KEY (categorie_id) REFERENCES categories(id)
);


CREATE TABLE locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    materiel_id INT,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    statut ENUM('en_attente', 'confirmee', 'annulee', 'terminee') DEFAULT 'en_attente',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (materiel_id) REFERENCES materiels(id)
);
ALTER TABLE locations
ADD COLUMN prix,total DECIMAL(10,2) AFTER statut;
