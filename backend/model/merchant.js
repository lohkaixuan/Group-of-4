const db = require('../helpers/dbHelper');

class Merchant {
  constructor({
    wallet_id,
    user_id,
    wallet_type,
    balance,
    currency,
    business_type,
    bank_header,
    category_service,
    ssm_address,
    created_at
  }) {
    this.wallet_id = wallet_id;
    this.user_id = user_id;
    this.wallet_type = wallet_type;
    this.balance = balance;
    this.currency = currency;
    this.business_type = business_type;
    this.bank_header = bank_header;
    this.category_service = category_service;
    this.ssm_address = ssm_address;
    this.created_at = created_at ? new Date(created_at) : null;
  }

  /** Return only safe/public fields */
  toJSON() {
    return {
      wallet_id: this.wallet_id,
      user_id: this.user_id,
      wallet_type: this.wallet_type,
      balance: this.balance,
      currency: this.currency,
      business_type: this.business_type,
      bank_header: this.bank_header,
      category_service: this.category_service,
      ssm_address: this.ssm_address,
      created_at: this.created_at
    };
  }

  // ======================= STATIC METHODS =======================

  static async findMerchantWallet(user_id) {
    const rows = await db.find('wallets', { user_id, wallet_type: 'merchant' });
    return rows.length ? new Merchant(rows[0]) : null;
  }

  static async createMerchantWallet({ user_id, business_type, bank_header, category_service, ssm_address, uuidv4 }) {
    const row = await db.insert('wallets', {
      wallet_id: uuidv4(),
      user_id,
      wallet_type: 'merchant',
      balance: 0,
      currency: 'MYR',
      business_type,
      bank_header,
      category_service,
      ssm_address
    });
    return new Merchant(row);
  }
}

module.exports = Merchant;
