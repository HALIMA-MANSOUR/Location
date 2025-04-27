const braintree = require('braintree');

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

const processPayment = (req, res) => {
  const { amount, paymentMethodNonce } = req.body;

  gateway.transaction.sale({
    amount: amount,
    paymentMethodNonce: paymentMethodNonce,
    options: {
      submitForSettlement: true,
    },
  }, (err, result) => {
    if (err) {
      console.error('Erreur lors du paiement :', err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
    if (result.success) {
      res.status(200).json({ success: true, transactionId: result.transaction.id });
    } else {
      res.status(400).json({ success: false, message: result.message });
    }
  });
};

module.exports = {
  generateToken,
  processPayment,
};
