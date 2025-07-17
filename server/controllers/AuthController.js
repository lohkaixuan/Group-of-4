const { db } = require('../config/firebase');
const jwt = require('jsonwebtoken');
const { validateIC, validatePhone, validateEmail, validatePin } = require('../utils/validation');
const uploadToStorage = require('../utils/uploadToStorage');
const bcrypt = require('bcrypt');
require('dotenv').config();
const SECRET_KEY = process.env.JWT_SECRET;

// 🔹 Register normal user
exports.registerUser = async (req, res) => {
    try {
        const { name, email, phone, ic_number, pin } = req.body;
        console.log('req.body:', req.body);
        console.log('req.files:', req.files);

        // 🔹 Validate inputs
        if (!validateIC(ic_number)) {
            return res.status(400).json({ error: 'Invalid IC number format (expected XXXXXX-XX-XXXX)' });
        }
        if (!validatePhone(phone)) {
            return res.status(400).json({ error: 'Invalid phone number (digits only)' });
        }
        if (!validateEmail(email)) {
            return res.status(400).json({ error: 'Invalid email address' });
        }
        if (!validatePin(pin)) {
            return res.status(400).json({ error: 'PIN must be exactly 6 digits' });
        }

        if (!req.files || !req.files.ic_photo) {
            return res.status(400).json({ error: 'IC photo is required' });
        }
        const hashedPin = await bcrypt.hash(pin, 10);

        // 🔹 Upload and save
        const icPhotoUrl = await uploadToStorage(req.files.ic_photo[0], 'ic_photos');
        const docRef = await db.collection('users').add({
            name,
            email,
            phone,
            ic_number,
            hashedPin, // save pin (⚠️ consider hashing!)
            ic_photo: icPhotoUrl,
            role: 'user',
            created_at: new Date().toISOString(),
        });

        res.json({ id: docRef.id, name, email, phone, ic_number, ic_photo: icPhotoUrl, role: 'user' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'User registration failed' });
    }
};


// 🔹 Register as merchant (reuses user record if exists)
exports.registerMerchant = async (req, res) => {
    try {
        const { name, email, phone, ic_number, pin, business_type, category_service } = req.body;

        // 🔹 Validate inputs first
        if (!validateIC(ic_number)) {
            return res.status(400).json({ error: 'Invalid IC number format' });
        }
        if (!validatePhone(phone)) {
            return res.status(400).json({ error: 'Invalid phone number' });
        }
        if (!validateEmail(email)) {
            return res.status(400).json({ error: 'Invalid email address' });
        }
        if (!validatePin(pin)) {
            return res.status(400).json({ error: 'PIN must be exactly 6 digits' });
        }
        if (!req.files || !req.files.ic_photo || !req.files.ssm_certificate) {
            return res.status(400).json({ error: 'IC photo and SSM certificate required' });
        }

        // 🔹 Look up existing user by IC
        const snap = await db.collection('users').where('ic_number', '==', ic_number).get();
        let userId = null;
        let existingData = null;

        if (!snap.empty) {
            const doc = snap.docs[0];
            userId = doc.id;
            existingData = doc.data();

            // ✅ Check PIN match
            if (existingData.hashedPin) {
                const pinMatches = await bcrypt.compare(pin, existingData.hashedPin);
                if (!pinMatches) {
                    return res.status(400).json({ error: 'Provided PIN does not match existing account.' });
                }
            } else {
                // If somehow no PIN stored, also reject or handle
                return res.status(400).json({ error: 'Existing account has no PIN to verify.' });
            }
        }

        // 🔹 Hash the new PIN (you may choose to re‑hash or keep existing)
        const hashedPin = await bcrypt.hash(pin, 10);

        // 🔹 Upload files
        const icPhotoUrl = await uploadToStorage(req.files.ic_photo[0], 'ic_photos');
        const ssmUrl = await uploadToStorage(req.files.ssm_certificate[0], 'ssm_certificates');

        // 🔹 Prepare merchant data
        const merchantData = {
            name,
            email,
            phone,
            ic_number,
            hashedPin, // overwrite or store new
            ic_photo: icPhotoUrl,
            business_type,
            category_service,
            ssm_certificate: ssmUrl,
            role: 'merchant',
            status: 'pending_approval',
            updated_at: new Date().toISOString(),
        };

        if (userId) {
            // Update existing user
            await db.collection('users').doc(userId).update(merchantData);
            return res.json({ id: userId, ...existingData, ...merchantData });
        } else {
            // Create new document
            const docRef = await db.collection('users').add({
                ...merchantData,
                created_at: new Date().toISOString(),
            });
            return res.json({ id: docRef.id, ...merchantData });
        }
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Merchant registration failed' });
    }
};


exports.login = async (req, res) => {
    try {
        const { email, phone, pin } = req.body;

        if (!pin) {
            return res.status(400).json({ error: 'PIN is required' });
        }

        let snap;

        // Search by email or phone
        if (email) {
            snap = await db.collection('users').where('email', '==', email).get();
        } else if (phone) {
            snap = await db.collection('users').where('phone', '==', phone).get();
        } else {
            return res.status(400).json({ error: 'Either email or phone is required' });
        }

        if (snap.empty) {
            return res.status(401).json({ error: 'User not found' });
        }

        const doc = snap.docs[0];
        const userData = { id: doc.id, ...doc.data() };

        // Compare pin
        const match = await bcrypt.compare(pin, userData.hashedPin);
        if (!match) {
            return res.status(401).json({ error: 'Invalid PIN' });
        }

        // Generate a new token
        const token = jwt.sign(
            { uid: doc.id, role: userData.role, email: userData.email },
            SECRET_KEY,
            { expiresIn: '1h' }
        );

        // 👉 Save this token back to Firestore (optional but you asked for it)
        await db.collection('users').doc(doc.id).update({
            lastLoginAt: new Date().toISOString(),
            token: token
        });

        // Respond with token and user
        res.json({ token, user: { ...userData, token } });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Login failed' });
    }
};
