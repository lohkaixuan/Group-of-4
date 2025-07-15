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
    return success(res, "User registered successfully", {
      user_id: newUser.user_id,
      email: newUser.email,
    });
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

/**
 * REGISTER MERCHANT (existing user)
 * user_id, business_type, bank_header, category_service, ssm_address
 * Creates merchant wallet row (does not duplicate user)
 */
exports.registerMerchant = async (req, res) => {
  try {
    const {
      user_id,
      business_name, // ✅ added
      business_type,
      bank_header,
      category_service,
      ssm_address,
    } = req.body;

    if (
      !user_id ||
      !business_name || // ✅ validate
      !business_type ||
      !bank_header ||
      !category_service ||
      !ssm_address
    ) {
      return fail(res, "Missing required fields for merchant registration");
    }

    // check user exists
    const existingUser = await db.find("users", { user_id });
    if (existingUser.length === 0) {
      return fail(res, "User not found");
    }

    // check if merchant wallet already exists
    const existingWallet = await db.find("wallets", {
      user_id,
      wallet_type: "merchant",
    });
    if (existingWallet.length > 0) {
      return fail(res, "Merchant wallet already exists for this user");
    }

    // insert merchant wallet
    await db.insert("wallets", {
      wallet_id: uuidv4(),
      user_id,
      wallet_type: "merchant",
      balance: 0,
      currency: "MYR",
      business_name, // ✅ save name
      business_type,
      bank_header,
      category_service,
      ssm_address,
    });

    return success(res, "Merchant wallet added", {
      user_id,
      wallet_type: "merchant",
      business_name,
    });

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

/**
 * LOGIN
 * email, password
 * Returns basic user info and all wallets
 */
exports.login = async (req, res) => {
  try {
    const { email, phone, password } = req.body;

    if ((!email && !phone) || !password) {
      return fail(res, "Missing email/phone or password");
    }

    // Build condition for dbHelper
    let condition = {};
    if (email) {
      condition.email = email;
    } else if (phone) {
      condition.phone = phone;
    }

    // Find user
    const users = await db.find("users", condition);
    if (users.length === 0) {
      return fail(res, "User not found");
    }

    const user = users[0];

    // Compare password
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return fail(res, "Invalid credentials");
    }

    // Fetch wallets for this user
    const wallets = await db.find("wallets", { user_id: user.user_id });

    // Prepare merchant info if merchant wallet exists
    const merchantWallet = wallets.find((w) => w.wallet_type === "merchant");
    let merchantInfo = null;
    if (merchantWallet) {
      merchantInfo = {
        wallet_id: merchantWallet.wallet_id,
        wallet_type: merchantWallet.wallet_type,
        balance: merchantWallet.balance,
        currency: merchantWallet.currency,
        business_name: merchantWallet.business_name, // ✅ include business_name
        business_type: merchantWallet.business_type,
        bank_header: merchantWallet.bank_header,
        category_service: merchantWallet.category_service,
        ssm_address: merchantWallet.ssm_address,
        ssm_doc: merchantWallet.ssm_doc || null, // make sure column exists if needed
      };
    }

    // Final JSON response
    return success(res, "Login success", {
      user: {
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        ic_photo: user.ic_photo || null, // send ic_photo path if exists
        created_at: user.created_at,
      },
        currency: w.currency,
      })),
      merchant: merchantInfo, // will be null if not registered as merchant

    });
  } catch (err) {
    console.error(err);
    return error(res, err.message);
  }
};
