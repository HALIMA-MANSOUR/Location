const bcrypt = require('bcrypt');
const braintree = require('braintree');
const db = require('../BD/db'); 
const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox,
  merchantId: 'pk52wwgq7vpkggfx',
  publicKey: 'gmfg5jmd3jn54fxq',
  privateKey: 'a952632d5bf07ccab7c5640bab2ef33d',
});

const generateToken = (req, res) => {
  gateway.clientToken.generate({}, (err, response) => {
    if (err) {
      console.error('Erreur lors de la génération du token :', err);
      return res.status(500).json({ error: 'Erreur de token' });
    }
    res.send(response.clientToken);
  });
};


const porfeuille = async (req, res) => {
  const { cardNumber, expirationDate, cvv } = req.body;
  const email = req.query.email;

  try {
    // Exemple de requête SQL avec async/await
    const [rows] = await db.query('SELECT * FROM cartes WHERE cardNumber = ?', [cardNumber]);

    if (rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Ce numéro de carte existe déjà' });
    }

    const saltRounds = 6;
    const hashedCVV = await bcrypt.hash(cvv, saltRounds);

    // Insertion dans la base de données
    await db.query(
      'INSERT INTO cartes (cardNumber, expirationDate, cvv, email) VALUES (?, ?, ?, ?)',
      [cardNumber, expirationDate, hashedCVV, email]
    );

    // Simulation de carte braintree (mode test)
    const carteBraintree = await gateway.paymentMethod.create({
      customerId: '53460186134',
      paymentMethodNonce: 'fake-valid-nonce',
    });

    res.json({ success: true, message: 'Carte ajoutée avec succès', token: carteBraintree.token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Erreur lors de l'ajout de la carte" });
  }
};

const recupererCarteParId = async (req, res) => {
  const email = req.query.email;  // paramètre dans l'URL
  const cardId = req.query.cardId;  // paramètre dans l'URL
  const montantAPayer = req.body.montant;  // Montant dans le corps de la requête

  console.log(`Email: ${email}, CardId: ${cardId}, Montant: ${montantAPayer}`);

  // Vérifier que le montant est bien dans le corps de la requête
  if (!montantAPayer) {
    return res.status(400).json({ success: false, message: 'Montant à payer manquant dans la requête' });
  }

  try {
    // Rechercher la carte par email et ID
    const [rows] = await db.query(
      'SELECT * FROM cartes WHERE id = ? AND email = ?',
      [cardId, email]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Carte non trouvée' });
    }

    const carte = rows[0];

    // Simuler le paiement
    const transactionResult = await effectuerPaiement(carte, montantAPayer);

    const minimalResponse = {
      success: true,
      message: 'Paiement effectué avec succès',
      transactionId: transactionResult.transaction.id,
      amount: transactionResult.transaction.amount,
      currency: transactionResult.transaction.currencyIsoCode,
      status: transactionResult.transaction.status,
      createdAt: transactionResult.transaction.createdAt,
    };

    res.json(minimalResponse);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors du paiement' });
  }
};

const effectuerPaiement = async (carte, montant) => {
  try {
    const result = await gateway.transaction.sale({
      amount: montant,
      paymentMethodNonce: 'fake-valid-nonce', 
      options: {
        submitForSettlement: true,
      },
    });

    return result;
  } catch (error) {
    throw error;
  }
};

module.exports = {
  generateToken,
  porfeuille,
  recupererCarteParId,
};
