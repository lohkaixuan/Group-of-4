const Tx = require('../models/TransactionModel');

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
    const tx = await Tx.confirmTransaction(refId);
    res.json(tx);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Confirm failed' });
  }
};
