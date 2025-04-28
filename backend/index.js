// index.js
const express = require('express');
const cors = require('cors'); // ← ajouter cette ligne
const app = express();
const PORT = 3000;

app.use(cors());

const materielsController = require('./Contoller/materielsController');
const locationsController = require('./Contoller/locationsController');
const braintreeController=require('./Contoller/PaiementController');
app.use(express.json());

app.get('/materiels', materielsController.getAllMateriels);

app.post('/locations', locationsController.createLocation);
app.get('/token', braintreeController.generateToken);
app.post('/checkout', braintreeController.processPayment);
app.get('/consultereserv', locationsController.getAllLocations);
app.put('/modifreserv/:id', locationsController.updateLocation);

app.listen(PORT,'0.0.0.0', () => {
  console.log(`Le serveur est en cours d'exécution sur le port :${PORT}`);
});
