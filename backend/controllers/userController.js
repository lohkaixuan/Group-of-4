const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const User = require('../model/user');
const Merchant = require('../model/merchant');
const db = require('../helpers/dbHelper');
const { success, fail, error } = require('../helpers/responseHelper');

// ✅ Register normal user
exports.registerUser = async (req, res) => {
  try {
    const { name, ic_number, email, phone, password, ic_photo } = req.body;
    if (!name || !ic_number || !email || !phone || !password) {
      return fail(res, 'Missing required fields');
    }

    // Check existing
    const existing = await User.findByEmail(email);
    if (existing) return fail(res, 'Email already registered');

    const hashed = await bcrypt.hash(password, 10);
    const user_id = uuidv4();

    // Create user
    const newUser = await User.create({
      user_id,
      name,
      ic_number,
      email,
      phone,
      password: hashed,
      role: 'user',
      ic_photo: ic_photo || null
    });

    // Create personal wallet
    await db.insert('wallets', {
      wallet_id: uuidv4(),
      user_id: newUser.user_id,
      wallet_type: 'personal',
      balance: 0,
      currency: 'MYR'
    });

    return success(res, 'User registered successfully', newUser.toJSON());
  } catch (err) {
    console.error(err);
    return error(res, err.message);
  }
};

// ✅ Register merchant
exports.registerMerchant = async (req, res) => {
  try {
    const { user_id, business_name, business_type, bank_header, category_service, ssm_address } = req.body;
    if (!user_id || !business_name || !business_type || !bank_header || !category_service || !ssm_address) {
      return fail(res, 'Missing required fields for merchant registration');
    }

    // Check user exists
    const user = await User.findById(user_id);
    if (!user) return fail(res, 'User not found');

    // Check if merchant wallet already exists
    const existingMerchant = await Merchant.findWallet(user_id);
    if (existingMerchant) return fail(res, 'Merchant wallet already exists');

    // Create merchant wallet
    const merchantWallet = await Merchant.createWallet({
      wallet_id: uuidv4(),
      user_id,
      wallet_type: 'merchant',
      balance: 0,
      currency: 'MYR',
      business_name,
      business_type,
      bank_header,
      category_service,
      ssm_address
    });

    return success(res, 'Merchant wallet added', merchantWallet.toJSON());
  } catch (err) {
    console.error(err);
    return error(res, err.message);
  }
};

// ✅ Login
exports.login = async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    if ((!email && !phone) || !password) {
      return fail(res, 'Missing email/phone or password');
    }

    let user = null;
    if (email) user = await User.findByEmail(email);
    else if (phone) user = await User.findByPhone(phone);

    if (!user) return fail(res, 'User not found');

    const match = await bcrypt.compare(password, user.password);
    if (!match) return fail(res, 'Invalid credentials');

    // Fetch wallets
    const wallets = await db.find('wallets', { user_id: user.user_id });

    // Fetch merchant info
    const merchantWallet = await Merchant.findWallet(user.user_id);
    const merchantInfo = merchantWallet ? merchantWallet.toJSON() : null;

    return success(res, 'Login success', {
      user: user.toJSON(),
      wallets: wallets.map((w) => ({
        wallet_id: w.wallet_id,
        wallet_type: w.wallet_type,
        balance: w.balance,
        currency: w.currency
      })),
      merchant: merchantInfo
    });
  } catch (err) {
    console.error(err);
    return error(res, err.message);
  }
};
