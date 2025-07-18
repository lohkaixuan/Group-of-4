const { db } = require('../config/firebase');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const uploadToStorage = require('../utils/uploadToStorage');
const { validateIC, validatePhone, validateEmail, validatePin } = require('../utils/validation');
const { createWallet } = require('../models/WalletModel');
require('dotenv').config();
const SECRET_KEY = process.env.JWT_SECRET;

// 🔹 Register normal user
exports.registerUser = async (req, res) => {
    try {
        const { name, email, phone, ic_number, pin } = req.body;

        // ✅ Validate
        if (!validateIC(ic_number)) return res.status(400).json({ error: 'Invalid IC number format' });
        if (!validatePhone(phone)) return res.status(400).json({ error: 'Invalid phone number' });
        if (!validateEmail(email)) return res.status(400).json({ error: 'Invalid email address' });
        if (!validatePin(pin)) return res.status(400).json({ error: 'PIN must be exactly 6 digits' });

        if (!req.files || !req.files.ic_photo) {
            return res.status(400).json({ error: 'IC photo is required' });
        }

        // ✅ Hash PIN and upload photo
        const hashedPin = await bcrypt.hash(pin, 10);
        const icPhotoUrl = await uploadToStorage(req.files.ic_photo[0], 'ic_photos');

        // ✅ Create user in Firestore
        const docRef = await db.collection('users').add({
            name,
            email,
            phone,
            ic_number,
            hashedPin,
            ic_photo: icPhotoUrl,
            role: 'user',
            created_at: new Date().toISOString(),
        });

        // ✅ Create personal wallet
        const personalWallet = await createWallet(docRef.id, 'personal');

        // ✅ Save wallet ID into user record
        await db.collection('users').doc(docRef.id).update({
            personal_wallet_id: personalWallet.wallet_id,
        });

        // ✅ Build user object for response
        const userObj = {
            id: docRef.id, // ✅ include user ID
            name,
            email,
            phone,
            ic_number,
            ic_photo: icPhotoUrl,
            role: 'user',
            personal_wallet_id: personalWallet.wallet_id, // ✅ include wallet id
        };

        return res.status(201).json({
            message: 'User registered successfully',
            user: userObj,
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'User registration failed' });
    }
};

// 🔹 Register merchant
exports.registerMerchant = async (req, res) => {
    try {
        const {
            name,
            email,
            phone,
            ic_number,
            pin,
            business_type,
            category_service,
            business_name,
        } = req.body;

        // ✅ Validate
        if (!validateIC(ic_number)) return res.status(400).json({ error: 'Invalid IC number format' });
        if (!validatePhone(phone)) return res.status(400).json({ error: 'Invalid phone number' });
        if (!validateEmail(email)) return res.status(400).json({ error: 'Invalid email address' });
        if (!validatePin(pin)) return res.status(400).json({ error: 'PIN must be exactly 6 digits' });
        if (!business_name || business_name.trim() === '') {
            return res.status(400).json({ error: 'Business name is required' });
        }
        if (!req.files || !req.files.ic_photo || !req.files.ssm_certificate) {
            return res.status(400).json({ error: 'IC photo and SSM certificate are required' });
        }

        // ✅ Check if user exists
        const snap = await db.collection('users').where('ic_number', '==', ic_number).get();
        let userId = null;
        let existingData = null;

        if (!snap.empty) {
            const doc = snap.docs[0];
            userId = doc.id;
            existingData = doc.data();
            const pinMatches = await bcrypt.compare(pin, existingData.hashedPin || '');
            if (!pinMatches) {
                return res.status(400).json({ error: 'Provided PIN does not match existing account.' });
            }
        }

        // ✅ Hash PIN and upload documents
        const hashedPin = await bcrypt.hash(pin, 10);
        const icPhotoUrl = await uploadToStorage(req.files.ic_photo[0], 'ic_photos');
        const ssmUrl = await uploadToStorage(req.files.ssm_certificate[0], 'ssm_certificates');

        const merchantData = {
            name,
            email,
            phone,
            ic_number,
            hashedPin,
            ic_photo: icPhotoUrl,
            business_name,
            business_type,
            category_service,
            ssm_certificate: ssmUrl,
            role: 'merchant',
            status: 'pending_approval',
            updated_at: new Date().toISOString(),
        };

        if (userId) {
            await db.collection('users').doc(userId).update(merchantData);
        } else {
            const docRef = await db.collection('users').add({
                ...merchantData,
                created_at: new Date().toISOString(),
            });
            userId = docRef.id;
        }

        return res.status(201).json({
            message: 'Merchant registration saved',
            user: {
                id: userId, // ✅ include user ID
                name,
                email,
                phone,
                role: 'merchant',
                business_name,
                business_type,
                category_service,
                status: 'pending_approval',
                ic_photo: icPhotoUrl,
                ssm_certificate: ssmUrl,
            },
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Merchant registration failed' });
    }
};

// 🔹 Login
exports.login = async (req, res) => {
    try {
        const { email, phone, pin } = req.body;
        if (!pin) return res.status(400).json({ error: 'PIN is required' });

        let snap;
        if (email) {
            snap = await db.collection('users').where('email', '==', email).get();
        } else if (phone) {
            snap = await db.collection('users').where('phone', '==', phone).get();
        } else {
            return res.status(400).json({ error: 'Either email or phone is required' });
        }

        if (snap.empty) return res.status(401).json({ error: 'User not found' });

        const doc = snap.docs[0];
        const userData = { id: doc.id, ...doc.data() }; // ✅ include id from Firestore doc.id

        const match = await bcrypt.compare(pin, userData.hashedPin);
        if (!match) return res.status(401).json({ error: 'Invalid PIN' });

        const token = jwt.sign(
            { uid: doc.id, role: userData.role, email: userData.email },
            SECRET_KEY,
            { expiresIn: '1h' }
        );

        await db.collection('users').doc(doc.id).update({
            lastLoginAt: new Date().toISOString(),
            token: token,
        });

        return res.json({
            message: 'Login successful',
            token,
            user: {
                id: userData.id, // ✅ explicitly include user id
                name: userData.name,
                email: userData.email,
                phone: userData.phone,
                role: userData.role,
                personal_wallet_id: userData.personal_wallet_id || null,
                merchant_wallet_id: userData.merchant_wallet_id || null,
                token: token,
            },
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Login failed' });
    }
};
