const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ✅ Hardcoded absolute paths (Windows)
const privateKeyPath = 'C:\\Users\\Loh Kai Xuan\\Desktop\\Veecotech intern\\Group-of-4\\client1.key';
const certPath = 'C:\\Users\\Loh Kai Xuan\\Desktop\\Veecotech intern\\Group-of-4\\client1.crt';
    // certificate (contains public key)

const privateKey = fs.readFileSync(privateKeyPath, 'utf8');
const publicKey = fs.readFileSync(certPath, 'utf8');

/**
 * Encrypt data with public key (from certificate)
 * This is for testing or client-side simulation
 */
function encrypt(plainText) {
    const buffer = Buffer.from(plainText, 'utf8');
    const encrypted = crypto.publicEncrypt(
        {
            key: publicKey,
            padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
            oaepHash: 'sha256',
        },
        buffer
    );
    return encrypted.toString('base64');
}

/**
 * Decrypt data with private key
 * This is what you will actually use in your server
 */
function decrypt(encryptedBase64) {
    const buffer = Buffer.from(encryptedBase64, 'base64');
    const decrypted = crypto.privateDecrypt(
        {
            key: privateKey,
            padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
            oaepHash: 'sha256',
        },
        buffer
    );
    return decrypted.toString('utf8');
}

module.exports = { encrypt, decrypt };
