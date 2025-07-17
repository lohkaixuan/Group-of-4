const { db } = require('../config/firebase');
const txs = db.collection('transactions');

async function createTransaction(data) {
  const ref = await txs.add(data);
  return { id: ref.id, ...data };
}

async function listTransactionsByUser(userId) {
  const snap = await txs.where('buyer_id', '==', userId).get();
  return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

async function confirmTransaction(refId) {
  await txs.doc(refId).update({ status: 'confirmed' });
  const doc = await txs.doc(refId).get();
  return { id: doc.id, ...doc.data() };
}

module.exports = { createTransaction, listTransactionsByUser, confirmTransaction };
