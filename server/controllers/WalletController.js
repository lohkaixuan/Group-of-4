// controllers/WalletController.js
const { topUpWallet, getTopUpHistory } = require('../models/WalletModel');
const { db } = require('../config/firebase');

// ✅ Top up a wallet
exports.topUp = async (req, res) => {
    try {
        const { userId, amount } = req.body;
        if (!userId || !amount) {
            return res.status(400).json({ error: 'userId and amount are required' });
        }

        const result = await topUpWallet(userId, amount);
        // result already contains { userId, walletId, balance, transactionId }

        return res.status(200).json({
            message: 'Top-up successful',
            ...result
        });
    } catch (err) {
        console.error('❌ Top-up error:', err);
        return res.status(500).json({ error: 'Top-up failed' });
    }
};

// ✅ Get all wallets for a user
exports.getWallets = async (req, res) => {
    try {
        const { userId } = req.query; // GET query param
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }

        const snap = await db.collection('wallets').where('userId', '==', userId).get();
        const wallets = snap.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        return res.status(200).json(wallets);
    } catch (err) {
        console.error('❌ Get wallets error:', err);
        return res.status(500).json({ error: 'Failed to fetch wallets' });
    }
};

// ✅ Get top‑up history for a user
exports.getTopUpHistory = async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }

        const history = await getTopUpHistory(userId);
        return res.status(200).json(history);
    } catch (err) {
        console.error('❌ Get history error:', err);
        return res.status(500).json({ error: 'Failed to fetch top-up history' });
    }
};
