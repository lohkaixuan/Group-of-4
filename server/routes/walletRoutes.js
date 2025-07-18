// routes/walletRoutes.js
const express = require('express');
const router = express.Router();
const WalletController = require('../controllers/WalletController');

// ✅ Top up a wallet
router.post('/topup', WalletController.topUp);

// ✅ Get all wallets for a user
router.get('/', WalletController.getWallets);

// ✅ NEW: Get top‑up history for a user
router.get('/history', WalletController.getTopUpHistory);

module.exports = router;
