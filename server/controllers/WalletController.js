// controllers/WalletController.js
const { topUpWallet, getTopUpHistory } = require('../models/WalletModel');
const { db } = require('../config/firebase');

// ✅ Top-up wallet
exports.topUp = async (req, res) => {
    try {
        const { userId, walletId, amount } = req.body;

        if (!userId || !walletId || !amount) {
            return res.status(400).json({ error: 'userId, walletId, and amount are required' });
        }

        // Find the wallet by ID
        const walletDocRef = db.collection('wallets').doc(walletId);
        const walletDoc = await walletDocRef.get();

        if (!walletDoc.exists) {
            return res.status(404).json({ error: 'Wallet not found' });
        }

        const walletData = walletDoc.data();

        // Ensure the wallet belongs to the user
        if (walletData.userId !== userId) {
            return res.status(403).json({ error: 'Wallet does not belong to the specified user' });
        }

        // Update wallet balance
        const newBalance = (walletData.balance || 0) + amount;
        await walletDocRef.update({ balance: newBalance });

        // Record top-up history
        const historyRef = db.collection('topUpHistory').doc();
        await historyRef.set({
            userId,
            walletId,
            amount,
            timestamp: new Date(),
            transactionId: historyRef.id
        });

        return res.status(200).json({
            message: 'Top-up successful',
            userId,
            walletId,
            balance: newBalance,
            transactionId: historyRef.id
        });

    } catch (err) {
        console.error('❌ Top-up error:', err);
        return res.status(500).json({ error: 'Top-up failed' });
    }
};

// ✅ Get all wallets for a user
exports.getWallets = async (req, res) => {
    try {
        const { userId } = req.query;

        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }

        const snap = await db.collection('wallets').where('userId', '==', userId).get();
        if (snap.empty) {
            return res.status(404).json({ error: 'No wallets found for this user' });
        }

        const wallets = snap.docs.map(doc => doc.data());
        return res.status(200).json(wallets);

    } catch (err) {
        console.error('❌ Get wallets error:', err);
        return res.status(500).json({ error: 'Failed to fetch wallets' });
    }
};

// ✅ Get top-up history for a user
exports.getTopUpHistory = async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }

        const snap = await db.collection('topUpHistory').where('userId', '==', userId).orderBy('timestamp', 'desc').get();
        const history = snap.docs.map(doc => doc.data());

        return res.status(200).json(history);
    } catch (err) {
        console.error('❌ Get history error:', err);
        return res.status(500).json({ error: 'Failed to fetch top-up history' });
    }
};
