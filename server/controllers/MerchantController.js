const Wallet = require('../models/WalletModel');
const { db } = require('../config/firebase');

const crypto = require('crypto');
const { db } = require('../config/firebase');
const Wallet = require('../models/WalletModel');

exports.approveMerchant = async (req, res) => {
  try {
    const { userId } = req.body;
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Generate merchant secret key
    const merchantSecretKey = crypto.randomBytes(32).toString('hex');

    // Create dual wallets
    const personalWallet = await Wallet.createWallet(userId, 'personal');
    const merchantWallet = await Wallet.createWallet(userId, 'merchant');

    // Update Firestore
    await userRef.update({
      status: 'approved',
      merchant_secret_key: merchantSecretKey,
      wallets: {
        personal_wallet_id: personalWallet.id,
        merchant_wallet_id: merchantWallet.id
      },
      approved_at: new Date().toISOString()
    });

    // Return to admin panel (you can also send it to merchant securely)
    res.json({
      message: 'Merchant approved',
      merchant_secret_key: merchantSecretKey, // show once
      personal_wallet_id: personalWallet.id,
      merchant_wallet_id: merchantWallet.id
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Approval failed' });
  }
};
