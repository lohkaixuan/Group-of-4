const express = require('express');
const router = express.Router();
const WalletController = require('../controllers/WalletController');

router.post('/topup', WalletController.topUp);
router.get('/', WalletController.getWallets);

module.exports = router;
