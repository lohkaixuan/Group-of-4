const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config(); // ✅ load .env
const { encrypt, decrypt } = require('./utils/RSA');


const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/auth', authRoutes);

app.get('/', (req, res) => {
    res.send(`✅ Auth service running on port ${process.env.PORT}`);
});

const PORT = process.env.PORT || 1060; // ✅ fallback if .env is missing
app.listen(PORT, () => console.log(`🔥 Auth server running at http://localhost:${PORT}`));


// // ✅ For testing:
// const cipherText = encrypt('hello world');
// console.log('Encrypted:', cipherText);

// // ✅ Decrypt:
// const plainText = decrypt(cipherText);
// console.log('Decrypted:', plainText);
