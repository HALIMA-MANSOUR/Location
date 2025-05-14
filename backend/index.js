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
app.use(express.json());

app.get('/materiels', materielsController.getAllMateriels);

app.post('/locations', locationsController.createLocation);

app.get('/token', braintreeController.generateToken);
app.post('/porfeuille', braintreeController.porfeuille);
app.post('/recupererCarteParId', braintreeController.recupererCarteParId);
app.get('/consultereserv', locationsController.getAllLocations);
app.put('/modifreserv/:id', locationsController.updateLocation);
app.get('/reservations', adminController.getAllReservations);
app.put('/reservations/:id', adminController.updateReservationStatus);

app.listen(PORT,'0.0.0.0', () => {
  console.log(`Le serveur est en cours d'exécution sur le port :${PORT}`);
});
