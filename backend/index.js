// index.js
const express = require('express');
const cors = require('cors'); // ← ajouter cette ligne
const app = express();
const port = 3000;

app.use(cors());

const materielsController = require('./Contoller/materielsController');
const locationsController = require('./contoller/locationsController');
const braintreeController=require('./Contoller/PaiementController');
app.use(express.json());

app.get('/materiels', materielsController.getAllMateriels);

app.post('/locations', locationsController.createLocation);
app.get('/token', braintreeController.generateToken);
app.post('/checkout', braintreeController.processPayment);
app.get('/consultereserv', locationsController.getAllLocations);
app.put('/modifreserv/:id', locationsController.updateLocation);

app.listen(3000, () => {
  console.log('Serveur démarré sur le port 3000 🚀');
});
