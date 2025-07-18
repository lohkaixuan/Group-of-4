// utils/blockchain.js
const { db } = require('../config/firebase');
const crypto = require('crypto');
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY; // 64-char hex string
const IV_LENGTH = 16; // for AES, this is always 16

let blockchain = [];

function generateHash(data) {
    return crypto.createHash('sha256').update(JSON.stringify(data) + Date.now()).digest('hex');
}

function encrypt(text) {
    const iv = crypto.randomBytes(IV_LENGTH);
    // parse hex string into Buffer
    const key = Buffer.from(ENCRYPTION_KEY, 'hex'); // ✅ ensures 32 bytes
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decrypt(text) {
    const parts = text.split(':');
    const iv = Buffer.from(parts.shift(), 'hex');
    const encryptedText = Buffer.from(parts.join(':'), 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString();
}

async function addBlock(merchant) {
    const prevBlock = blockchain[blockchain.length - 1];

    const blockData = {
        id: merchant.id,
        name: merchant.name,
        email: merchant.email,
        phone: merchant.phone,
        business_type: merchant.business_type || '',
        category_service: merchant.category_service || '',
        approved_at: merchant.approved_at || new Date().toISOString(),
        ssm_certificate: merchant.ssm_certificate ? encrypt(merchant.ssm_certificate) : '',
        status: 'approved',
    };

    const newBlock = {
        index: blockchain.length + 1,
        timestamp: new Date().toISOString(),
        data: blockData,
        prevHash: prevBlock?.hash || '0',
        hash: generateHash(blockData),
    };

    blockchain.push(newBlock);
    await db.collection('blockchain').doc(merchant.id).set(newBlock);

    return newBlock;
}

async function getMerchantBlock(userId) {
    const found = blockchain.find(b => b.data.id === userId);
    let block = found;

    if (!found) {
        const doc = await db.collection('blockchain').doc(userId).get();
        if (!doc.exists) return null;
        block = doc.data();
    }

    try {
        if (block.data?.ssm_certificate) {
            block.data.ssm_certificate = decrypt(block.data.ssm_certificate);
        }
    } catch (err) {
        console.error('🔓 Decryption failed:', err);
        block.data.ssm_certificate = '🔐 [Invalid or corrupted encrypted data]';
    }

    return block;
}

module.exports = {
    addBlock,
    getMerchantBlock,
    encrypt,
    decrypt
};
