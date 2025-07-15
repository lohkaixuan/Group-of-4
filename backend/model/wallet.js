const db = require('../helpers/dbHelper');

class Wallet {
  constructor({
    wallet_id,
    user_id,
    wallet_type,
    balance,
    currency,
    business_name,
    business_type,
    bank_header,
    category_service,
    ssm_address,
    ssm_doc,
    created_at
  }) {
    this.wallet_id = wallet_id;
    this.user_id = user_id;
    this.wallet_type = wallet_type;
    this.balance = balance;
    this.currency = currency;
    this.business_name = business_name;
    this.business_type = business_type;
    this.bank_header = bank_header;
    this.category_service = category_service;
    this.ssm_address = ssm_address;
    this.ssm_doc = ssm_doc;
    this.created_at = created_at ? new Date(created_at) : null;
  }

  toJSON() {
    return {
      wallet_id: this.wallet_id,
      user_id: this.user_id,
      wallet_type: this.wallet_type,
      balance: this.balance,
      currency: this.currency,
      business_name: this.business_name,
      business_type: this.business_type,
      bank_header: this.bank_header,
      category_service: this.category_service,
      ssm_address: this.ssm_address,
      ssm_doc: this.ssm_doc,
      created_at: this.created_at
    };
  }

  // ---------------- STATIC METHODS ----------------

  // Get wallet by user_id and wallet_type
  static async getWallet(user_id, wallet_type = 'personal') {
    const rows = await db.find('wallets', { user_id, wallet_type });
    return rows.length ? new Wallet(rows[0]) : null;
  }

  // Update balance by wallet_id
  static async updateBalance(wallet_id, newBalance) {
    const rows = await db.update('wallets', { balance: newBalance }, { wallet_id });
    return rows.length ? new Wallet(rows[0]) : null;
  }

  // Add a transaction record
  static async addTransaction({ id, wallet_id, user_id, type, amount, reference, payment_method, date }) {
    const row = await db.insert('transactions', {
      id,
      wallet_id,
      user_id,
      type,
      amount,
      reference,
      payment_method,
      date
    });
    return row; // raw row is fine here
  }

  // Get all transactions for a wallet
  static async getTransactions(wallet_id) {
    const rows = await db.find('transactions', { wallet_id });
    return rows; // return as array of plain objects
  }
}

module.exports = Wallet;
