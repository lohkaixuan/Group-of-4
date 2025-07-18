const express = require('express');
const router = express.Router();
const TxController = require('../controllers/TransactionController');
const generateDownloadUrl = require('../utils/generateDownloadUrl');

// GET /transactions/download/:filename
router.get('/download/:filename', async (req, res) => {
    try {
        const filename = req.params.filename; // e.g. "transaction_pdfs/uuid_invoice.pdf"
        const url = await generateDownloadUrl(filename);
        res.json({ downloadUrl: url });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Could not generate download URL' });
    }
});
router.post('/', TxController.create);
router.post('/confirm', TxController.confirm);

module.exports = router;
