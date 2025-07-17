// server/config/firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
require('dotenv').config();

// ✅ use your env for project id or hardcode:
const bucketName = `${process.env.FIREBASE_PROJECT_ID}.appspot.com`;


admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    //storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`,
    storageBucket: `${process.env.FIREBASE_PROJECT_ID}.firebasestorage.app`
});
const db = admin.firestore();
const bucket = admin.storage().bucket();

module.exports = { db, bucket }; // ✅ export bucket so uploadToStorage can use it
