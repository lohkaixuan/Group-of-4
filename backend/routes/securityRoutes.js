const express = require('express');
const router = express.Router();
const securityCtrl = require('../controllers/securityController');

// Encrypt data
router.post('/encrypt', securityCtrl.encryptData);

// Decrypt data
router.post('/decrypt', securityCtrl.decryptData);

// Get sample JSON data
router.get('/json', securityCtrl.getJsonData);

module.exports = router;