// 📄 models/walletModel.js
const { db } = require('../config/firebase');
const { v4: uuidv4 } = require('uuid');
const { randomBytes } = require('crypto');

const wallets = db.collection('wallets');

// ✅ Create a new wallet with UUID + secret key
async function createWallet(userId, type) {
  const walletId = uuidv4();
  const secretKey = randomBytes(32).toString('hex');

  const walletData = {
    wallet_id: walletId,
    user_id: userId,
    type: type, // 'personal' or 'merchant'
    balance: 0,
    secretKey,
    created_at: new Date().toISOString()
  };

  await wallets.doc(walletId).set(walletData);
  return walletData;
}

// ✅ Get all wallets for a user
async function getWalletsForUser(userId) {
  const snap = await wallets.where('user_id', '==', userId).get();
  return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// ✅ Update wallet balance
async function updateWalletBalance(walletId, newBalance) {
  await wallets.doc(walletId).update({
    balance: newBalance,
    updated_at: new Date().toISOString()
  });
}

module.exports = {
  createWallet,
  getWalletsForUser,
  updateWalletBalance
};
