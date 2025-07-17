const { db } = require('../config/firebase');
const wallets = db.collection('wallets');

// Create a new wallet
async function createWallet(userId, type) {
  const doc = await wallets.add({
    userId,
    type, // 'personal' or 'merchant'
    balance: 0,
    created_at: new Date().toISOString()
  });
  return { id: doc.id, userId, type, balance: 0 };
}

// Get all wallets for a user
async function getWalletsForUser(userId) {
  const snap = await wallets.where('userId', '==', userId).get();
  return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

module.exports = { createWallet, getWalletsForUser };
