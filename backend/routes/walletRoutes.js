// routes/walletRoutes.js
const express = require('express');
const router = express.Router();
const walletCtrl = require('./controllers/walletController');

// GET balance for a specific wallet type (query: ?wallet_type=personal/merchant)
router.get('/:user_id/balance', walletCtrl.getBalance);

// TOP UP to a specific wallet
router.post('/topup', walletCtrl.topUp);

// PAY from one user/wallet to another
router.post('/pay', walletCtrl.pay);

// TRANSFER between personal and merchant wallet of same user
router.post('/transfer', walletCtrl.transfer);

// GET transactions for a wallet (query: ?wallet_type=personal/merchant)
router.get('/:user_id/transactions', walletCtrl.getTransactions);

module.exports = router;
