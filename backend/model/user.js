const db = require('../helpers/dbHelper');

class User {
  constructor({
    user_id,
    name,
    ic_number,
    email,
    phone,
    password,
    role,
    ic_photo,
    created_at
  }) {
    this.user_id = user_id;
    this.name = name;
    this.ic_number = ic_number;
    this.email = email;
    this.phone = phone;
    this.password = password;
    this.role = role || 'user';
    this.ic_photo = ic_photo;
    this.created_at = created_at ? new Date(created_at) : null;
  }

  /** Return only safe/public fields */
  toJSON() {
    return {
      user_id: this.user_id,
      name: this.name,
      ic_number: this.ic_number,
      email: this.email,
      phone: this.phone,
      role: this.role,
      ic_photo: this.ic_photo,
      created_at: this.created_at
    };
  }

  // ======================= STATIC METHODS =======================

  static async findByEmail(email) {
    const rows = await db.find('users', { email });
    return rows.length ? new User(rows[0]) : null;
  }

  static async findByPhone(phone) {
    const rows = await db.find('users', { phone });
    return rows.length ? new User(rows[0]) : null;
  }

  static async findById(user_id) {
    const rows = await db.find('users', { user_id });
    return rows.length ? new User(rows[0]) : null;
  }

  static async create({ user_id, name, ic_number, email, phone, password, ic_photo }) {
    const row = await db.insert('users', {
      user_id,
      name,
      ic_number,
      email,
      phone,
      password,
      role: 'user',
      ic_photo: ic_photo || null
    });
    return new User(row);
  }
}

module.exports = User;
