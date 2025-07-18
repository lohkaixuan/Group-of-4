const Wallet = require('../models/WalletModel');

exports.topUp = async (req, res) => {
    try {
        const { userId, amount } = req.body;
        const result = await Wallet.topUpWallet(userId, Number(amount));
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Top-up failed' });
    }
};

exports.getWallets = async (req, res) => {
    try {
        const { userId } = req.query;
        const result = await Wallet.getWalletByUser(userId);
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Fetch wallets failed' });
    }
};
