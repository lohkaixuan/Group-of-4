const { v4: uuidv4 } = require('uuid');
const Wallet = require('../models/walletModel');
const { success, fail, error } = require('../helpers/responseHelper');

// ✅ Get balance (specify wallet_type)
exports.getBalance = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { wallet_type } = req.query; // personal or merchant
    const wallet = await Wallet.getWallet(user_id, wallet_type || 'personal');
    if (!wallet) return fail(res, 'Wallet not found');
    return success(res, 'Balance fetched', {
      wallet_type: wallet.wallet_type,
      balance: wallet.balance,
      currency: wallet.currency
    });
  } catch (err) {
    return error(res, err.message);
  }
};

// ✅ Top up to a specific wallet
exports.topUp = async (req, res) => {
  try {
    const { user_id, amount, reference, wallet_type, payment_method } = req.body;
    const wallet = await Wallet.getWallet(user_id, wallet_type || 'personal');
    if (!wallet) return fail(res, 'Wallet not found');

    const newBalance = Number(wallet.balance) + Number(amount);
    await Wallet.updateBalance(wallet.wallet_id, newBalance);

    await Wallet.addTransaction({
      id: uuidv4(),
      wallet_id: wallet.wallet_id,
      user_id,
      type: 'topup',
      amount,
      reference,
      payment_method: payment_method || 'unknown',
      date: new Date()
    });

    return success(res, 'Top-up success', {
      wallet_type: wallet.wallet_type,
      wallet_balance: newBalance
    });
  } catch (err) {
    return error(res, err.message);
  }
};

// ✅ Pay (from one wallet to another)
exports.pay = async (req, res) => {
  try {
    const { from_user, to_user, amount, reference, from_wallet_type, to_wallet_type, payment_method } = req.body;

    const payerWallet = await Wallet.getWallet(from_user, from_wallet_type || 'personal');
    const payeeWallet = await Wallet.getWallet(to_user, to_wallet_type || 'personal');

    if (!payerWallet || !payeeWallet) return fail(res, 'Wallet not found');
    if (Number(payerWallet.balance) < Number(amount)) return fail(res, 'Insufficient balance');

    // Deduct from payer
    const newPayerBalance = Number(payerWallet.balance) - Number(amount);
    await Wallet.updateBalance(payerWallet.wallet_id, newPayerBalance);
    await Wallet.addTransaction({
      id: uuidv4(),
      wallet_id: payerWallet.wallet_id,
      user_id: from_user,
      type: 'payment',
      amount,
      reference,
      payment_method: payment_method || 'unknown',
      date: new Date()
    });

    // Add to payee
    const newPayeeBalance = Number(payeeWallet.balance) + Number(amount);
    await Wallet.updateBalance(payeeWallet.wallet_id, newPayeeBalance);
    await Wallet.addTransaction({
      id: uuidv4(),
      wallet_id: payeeWallet.wallet_id,
      user_id: to_user,
      type: 'receive',
      amount,
      reference,
      payment_method: payment_method || 'unknown',
      date: new Date()
    });

    return success(res, 'Payment successful', {
      from_wallet: { wallet_type: payerWallet.wallet_type, balance: newPayerBalance },
      to_wallet: { wallet_type: payeeWallet.wallet_type, balance: newPayeeBalance }
    });
  } catch (err) {
    return error(res, err.message);
  }
};

// ✅ Transfer between wallets of the SAME user (e.g. personal <-> merchant)
exports.transfer = async (req, res) => {
  try {
    const { user_id, from_wallet_type, to_wallet_type, amount, reference, payment_method } = req.body;

    const fromWallet = await Wallet.getWallet(user_id, from_wallet_type);
    const toWallet = await Wallet.getWallet(user_id, to_wallet_type);

    if (!fromWallet || !toWallet) return fail(res, 'Wallet not found');
    if (Number(fromWallet.balance) < Number(amount)) return fail(res, 'Insufficient balance');

    const newFromBalance = Number(fromWallet.balance) - Number(amount);
    const newToBalance = Number(toWallet.balance) + Number(amount);

    await Wallet.updateBalance(fromWallet.wallet_id, newFromBalance);
    await Wallet.updateBalance(toWallet.wallet_id, newToBalance);

    // log both transactions
    await Wallet.addTransaction({
      id: uuidv4(),
      wallet_id: fromWallet.wallet_id,
      user_id,
      type: 'transfer-out',
      amount,
      reference,
      payment_method: payment_method || 'unknown',
      date: new Date()
    });
    await Wallet.addTransaction({
      id: uuidv4(),
      wallet_id: toWallet.wallet_id,
      user_id,
      type: 'transfer-in',
      amount,
      reference,
      payment_method: payment_method || 'unknown',
      date: new Date()
    });

    return success(res, 'Transfer successful', {
      from_wallet: { wallet_type: fromWallet.wallet_type, balance: newFromBalance },
      to_wallet: { wallet_type: toWallet.wallet_type, balance: newToBalance }
    });
  } catch (err) {
    return error(res, err.message);
  }
};

// ✅ Get transactions for a wallet
exports.getTransactions = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { wallet_type } = req.query;
    const wallet = await Wallet.getWallet(user_id, wallet_type || 'personal');
    if (!wallet) return fail(res, 'Wallet not found');
    const txns = await Wallet.getTransactions(wallet.wallet_id);
    return success(res, 'Transactions fetched', { transactions: txns });
  } catch (err) {
    return error(res, err.message);
  }
};
