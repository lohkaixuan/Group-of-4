const { v4: uuidv4 } = require('uuid');
const Wallet = require('../models/walletModel');
const { success, fail, error } = require('../helpers/responseHelper');

exports.getBalance = async (req, res) => {
    try {
        const wallet = await Wallet.getWallet(req.params.user_id);
        if (!wallet) return fail(res, 'Wallet not found');
        return success(res, 'Balance fetched', { balance: wallet.balance, currency: wallet.currency });
    } catch (err) {
        return error(res, err.message);
    }
};

exports.topUp = async (req, res) => {
    try {
        const { user_id, amount, reference } = req.body;
        const wallet = await Wallet.getWallet(user_id);
        if (!wallet) return fail(res, 'Wallet not found');

        const newBalance = Number(wallet.balance) + Number(amount);
        await Wallet.updateBalance(user_id, newBalance);
        const txn = { id: uuidv4(), user_id, type: 'topup', amount, reference, date: new Date() };
        await Wallet.addTransaction(txn);

        return success(res, 'Top-up success', { wallet_balance: newBalance });
    } catch (err) {
        return error(res, err.message);
    }
};

exports.pay = async (req, res) => {
    try {
        const { from_user, to_user, amount, reference } = req.body;
        const payer = await Wallet.getWallet(from_user);
        const payee = await Wallet.getWallet(to_user);
        if (!payer || !payee) return fail(res, 'Wallet not found');
        if (Number(payer.balance) < Number(amount)) return fail(res, 'Insufficient balance');

        // Deduct payer
        await Wallet.updateBalance(from_user, Number(payer.balance) - Number(amount));
        await Wallet.addTransaction({ id: uuidv4(), user_id: from_user, type: 'payment', amount, reference, date: new Date() });

        // Add payee
        await Wallet.updateBalance(to_user, Number(payee.balance) + Number(amount));
        await Wallet.addTransaction({ id: uuidv4(), user_id: to_user, type: 'receive', amount, reference, date: new Date() });

        return success(res, 'Payment successful');
    } catch (err) {
        return error(res, err.message);
    }
};

exports.getTransactions = async (req, res) => {
    try {
        const txns = await Wallet.getTransactions(req.params.user_id);
        return success(res, 'Transactions fetched', { transactions: txns });
    } catch (err) {
        return error(res, err.message);
    }
};