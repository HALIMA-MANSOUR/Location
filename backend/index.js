// index.js
const express = require('express');
const cors = require('cors'); // ← ajouter cette ligne
const app = express();
const PORT = 3000;
const multer = require('multer');
const path = require('path');
app.use(cors());

const materielsController = require('./Contoller/materielsController');
const locationsController = require('./Contoller/locationsController');
const braintreeController=require('./Contoller/PaiementController');
const adminController =require('./Contoller/adminController');
const UserController = require('./Contoller/UserController');
app.use(express.json());
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/images');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage }).any();
app.use('/images', express.static(path.join(__dirname, 'public/images')));
app.get('/materiels', materielsController.getAllMateriels);
app.get('/Catgmateriels', materielsController.getAllCategories);

app.post('/locations', locationsController.createLocation);
app.delete('/deletelocation/:id', locationsController.deleteLocation);

app.get('/token', braintreeController.generateToken);
app.post('/porfeuille', braintreeController.porfeuille);
app.post('/recupererCarteParId', braintreeController.recupererCarteParId);
app.get('/consultereserv', locationsController.getAllLocations);
app.put('/modifreserv/:id', locationsController.updateLocation);
app.get('/reservations', adminController.getAllReservations);
app.put('/reservations/:id', adminController.updateReservationStatus);
app.post('/createUser', UserController.createUser);
app.post('/ajoutmateriels', upload,materielsController.addMateriel);
app.put('/modifmateriels/:id', upload,materielsController.updateMateriel);
app.delete('/dletemateriel/:id', materielsController.deleteMateriel);
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Le serveur est en cours d'exécution sur le port :${PORT}`);
});
