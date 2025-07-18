const Tx = require('../models/TransactionModel');
const { getWalletsForUser, updateWalletBalance } = require('../models/WalletModel'); // we'll write updateWalletBalance below

exports.create = async (req, res) => {
    try {
        const { buyer_id, seller_id, amount } = req.body;
        const tx = await Tx.createTransaction({ buyer_id, seller_id, amount, status: 'pending' });
        res.json(tx);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Transaction failed' });
    }
};

exports.confirm = async (req, res) => {
    try {
        const { refId } = req.body;

        // 1️⃣ Get the transaction
        const tx = await Tx.getTransaction(refId);
        if (!tx) return res.status(404).json({ error: 'Transaction not found' });

        // 2️⃣ Get buyer & seller wallets (assuming one wallet per user)
        const buyerWallets = await getWalletsForUser(tx.buyer_id);
        const sellerWallets = await getWalletsForUser(tx.seller_id);

        if (buyerWallets.length === 0 || sellerWallets.length === 0) {
            return res.status(400).json({ error: 'Wallet not found for buyer or seller' });
        }

        const buyerWallet = buyerWallets[0];
        const sellerWallet = sellerWallets[0];

        // 3️⃣ Check balance
        if (buyerWallet.balance < tx.amount) {
            return res.status(400).json({ error: 'Insufficient balance in buyer wallet' });
        }

        // 4️⃣ Update balances
        await updateWalletBalance(buyerWallet.id, buyerWallet.balance - tx.amount);
        await updateWalletBalance(sellerWallet.id, sellerWallet.balance + tx.amount);

        // 5️⃣ Confirm transaction
        const confirmedTx = await Tx.confirmTransaction(refId);

        res.json({ message: 'Transaction confirmed', tx: confirmedTx });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Confirm failed' });
    }
};
