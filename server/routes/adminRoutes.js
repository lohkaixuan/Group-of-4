const express = require('express');
const router = express.Router();
const MerchantController = require('../controllers/MerchantController');

// Approve merchant and create wallets
router.post('/approve-merchant', MerchantController.approveMerchant);

module.exports = router;
