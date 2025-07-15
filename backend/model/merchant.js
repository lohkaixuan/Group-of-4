// models/Merchant.js
const db = require('../helpers/dbHelper');

class Merchant {
  constructor(row) {
    this.wallet_id = row.wallet_id;
    this.user_id = row.user_id;
    this.wallet_type = row.wallet_type;
    this.balance = row.balance;
    this.currency = row.currency;
    this.business_name = row.business_name;
    this.business_type = row.business_type;
    this.bank_header = row.bank_header;
    this.category_service = row.category_service;
    this.ssm_address = row.ssm_address;
    this.ssm_doc = row.ssm_doc;
    this.created_at = row.created_at;
  }

  toJSON() {
    return {
      wallet_id: this.wallet_id,
      wallet_type: this.wallet_type,
      balance: this.balance,
      currency: this.currency,
      business_name: this.business_name,
      business_type: this.business_type,
      bank_header: this.bank_header,
      category_service: this.category_service,
      ssm_address: this.ssm_address,
      ssm_doc: this.ssm_doc
    };
  }

  static async findWallet(user_id) {
    const rows = await db.find('wallets', { user_id, wallet_type: 'merchant' });
    return rows.length ? new Merchant(rows[0]) : null;
  }

  static async createWallet(data) {
    const row = await db.insert('wallets', data);
    return new Merchant(row);
  }
}

module.exports = Merchant;
