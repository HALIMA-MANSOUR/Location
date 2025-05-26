// index.js
const express = require('express');
const cors = require('cors'); // ← ajouter cette ligne
const app = express();
const PORT = 3000;

app.use(cors());

const materielsController = require('./Contoller/materielsController');
const locationsController = require('./Contoller/locationsController');
const braintreeController=require('./Contoller/PaiementController');
const adminController =require('./Contoller/adminController');
const UserController = require('./Contoller/UserController');
app.use(express.json());

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
app.post('/ajoutmateriels', materielsController.addMateriel);
app.put('/modifmateriels/:id', materielsController.updateMateriel);
app.delete('/dletemateriel/:id', materielsController.deleteMateriel);
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Le serveur est en cours d'exécution sur le port :${PORT}`);
});
