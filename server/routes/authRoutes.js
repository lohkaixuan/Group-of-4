const express = require('express');
const router = express.Router();
const multer = require('multer');
const AuthController = require('../controllers/AuthController');

// memory storage for Firebase
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.post(
    '/register',
    upload.fields([{ name: 'ic_photo', maxCount: 1 }]), // ✅ match key in Postman
    AuthController.registerUser
);

router.post(
    '/register-merchant',
    upload.fields([
        { name: 'ic_photo', maxCount: 1 },
        { name: 'ssm_certificate', maxCount: 1 }
    ]),
    AuthController.registerMerchant
);

router.post('/login', AuthController.login);

module.exports = router;
