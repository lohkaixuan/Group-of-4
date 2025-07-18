const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const MerchantController = require('../controllers/MerchantController');
const { getMerchantBlock } = require('../utils/blockchain');

// 🔍 Public API: basic info + block
router.get('/public/:id', async (req, res) => {
    try {
        const id = req.params.id;
        const snap = await db.collection('users').doc(id).get();
        if (!snap.exists) {
            return res.status(404).json({ error: 'Merchant not found' });
        }

        const data = snap.data();
        if (data.role !== 'merchant' || data.status !== 'approved') {
            return res.status(403).json({ error: 'Merchant not approved' });
        }

        // fetch blockchain block for merchant
        const block = await getMerchantBlock(id);

        return res.json({
            id,
            name: data.name,
            email: data.email,
            business_type: data.business_type,
            category_service: data.category_service,
            status: data.status,
            verified: true,
            block: block || {}
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Server error' });
    }
});

// 🔗 Blockchain verification endpoint (with decryption)
router.get('/verify/:userId', async (req, res) => {
    try {
        const data = await MerchantController.getMerchantBlockchainData(req.params.userId);
        if (!data) {
            return res.status(404).json({ verified: false, error: 'Merchant block not found' });
        }
        return res.json({ verified: true, block: data });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
