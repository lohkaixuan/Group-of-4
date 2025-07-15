
const express = require('express');
const router = express.Router();
const walletCtrl = require('../controllers/walletController');

// Get a user's wallet balance
router.get('/:user_id', walletCtrl.getBalance);

// Top‑up wallet
router.post('/topup', walletCtrl.topUp);

// Pay from one user to another
router.post('/pay', walletCtrl.pay);

// Get a user's transaction records
router.get('/:user_id/transactions', walletCtrl.getTransactions);

module.exports = router;