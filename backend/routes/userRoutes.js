const express = require('express');
const router = express.Router();
const userCtrl = require('../controllers/userController');
const upload = require('../middlewares/upload');

// Single file upload for user IC photo
router.post('/register',
  upload.single('ic_photo'),  // field name in form-data
  userCtrl.registerUser
);

// Multiple fields for merchant (e.g. SSM doc)
router.post('/register-merchant',
  upload.fields([
    { name: 'ssm_doc', maxCount: 1 }
  ]),
  userCtrl.registerMerchant
);

router.post('/login', userCtrl.login);

module.exports = router;
    