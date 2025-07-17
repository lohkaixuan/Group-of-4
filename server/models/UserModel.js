const { db } = require('../config/firebase');
const users = db.collection('users');

async function createUser(data) {
  const doc = await users.add(data);
  return { id: doc.id, ...data };
}

async function getUser(id) {
  const snap = await users.doc(id).get();
  if (!snap.exists) return null;
  return { id: snap.id, ...snap.data() };
}

module.exports = { createUser, getUser };
