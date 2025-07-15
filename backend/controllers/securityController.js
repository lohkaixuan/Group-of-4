const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

// Load keys once at startup
let keys = null;
function loadKeys() {
    try {
        // FIX: Use double backslashes for Windows paths or use path.join
        const certPath = path.resolve('C:\\Users\\Loh Kai Xuan\\Desktop\\Veecotech intern\\Group-of-4\\client1.crt');
        const keyPath = path.resolve('C:\\Users\\Loh Kai Xuan\\Desktop\\Veecotech intern\\Group-of-4\\client1.key');

        // Read certificate (contains public key)
        const certPem = fs.readFileSync(certPath, 'utf8');
        const publicKey = crypto.createPublicKey(certPem);

        // Read private key
        const keyPem = fs.readFileSync(keyPath, 'utf8');
        const privateKey = crypto.createPrivateKey({
            key: keyPem,
            format: 'pem',
        });

        return { publicKey, privateKey };
    } catch (error) {
        console.error("❌ Error loading keys:", error.message);
        return null;
    }
}
keys = loadKeys();

function encrypt(publicKey, data) {
    try {
        return crypto.publicEncrypt(
            {
                key: publicKey,
                padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
                oaepHash: 'sha256',
            },
            Buffer.from(data)
        );
    } catch (error) {
        console.error("❌ Error during encryption:", error.message);
        return null;
    }
}

function decrypt(privateKey, encryptedData) {
    try {
        return crypto.privateDecrypt(
            {
                key: privateKey,
                padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
                oaepHash: 'sha256',
            },
            encryptedData
        );
    } catch (error) {
        console.error("❌ Error during decryption:", error.message);
        return null;
    }
}

// API: Encrypt data
exports.encryptData = (req, res) => {
    if (!keys || !keys.publicKey) {
        return res.status(500).json({ error: "Keys not loaded" });
    }
    const { data } = req.body;
    if (!data) {
        return res.status(400).json({ error: "Missing data to encrypt" });
    }
    const encrypted = encrypt(keys.publicKey, data);
    if (!encrypted) {
        return res.status(500).json({ error: "Encryption failed" });
    }
    return res.json({ encrypted: encrypted.toString('base64') });
};

// API: Decrypt data
exports.decryptData = (req, res) => {
    if (!keys || !keys.privateKey) {
        return res.status(500).json({ error: "Keys not loaded" });
    }
    const { encrypted } = req.body;
    if (!encrypted) {
        return res.status(400).json({ error: "Missing encrypted data" });
    }
    let buffer;
    try {
        buffer = Buffer.from(encrypted, 'base64');
    } catch (err) {
        return res.status(400).json({ error: "Invalid base64 data" });
    }
    const decrypted = decrypt(keys.privateKey, buffer);
    if (!decrypted) {
        return res.status(500).json({ error: "Decryption failed" });
    }
    return res.json({ decrypted: decrypted.toString() });
};

// Example API: Get sample JSON data
exports.getJsonData = (req, res) => {
    return res.json({
        Merchant: "Alice",
        Customer: "Ben",
        price: 20.00,
        id: 123456

    });
};

/*
exports.getJsonData = (req, res) => {
    const data = getJsonData();
    return res.json(data);
};
*/