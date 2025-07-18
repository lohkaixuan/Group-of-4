// 📄 models/transactionModel.js
const { db } = require('../config/firebase');
const txs = db.collection('transactions');


async function createTransaction(data) {
  const payload = {
    ...data,
    status: 'pending', // default status
    created_at: new Date().toISOString(),
  };

  const ref = await txs.add(payload);
  return { id: ref.id, ...payload };
}


 // List transactions where user is buyer

async function listTransactionsByUser(userId) {
  const snap = await txs.where('buyer_id', '==', userId).get();
  return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}


async function listTransactionsBySeller(userId) {
  const snap = await txs.where('seller_id', '==', userId).get();
  return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

async function confirmTransaction(refId) {
  const docRef = txs.doc(refId);

  // optional: check if it exists first
  const existing = await docRef.get();
  if (!existing.exists) {
    throw new Error('Transaction not found');
  }

  await docRef.update({
    status: 'confirmed',
    confirmed_at: new Date().toISOString(),
  });

  const updated = await docRef.get();
  return { id: updated.id, ...updated.data() };
}

module.exports = {
  createTransaction,
  listTransactionsByUser,
  listTransactionsBySeller, // ✅ don’t forget this
  confirmTransaction,
};
