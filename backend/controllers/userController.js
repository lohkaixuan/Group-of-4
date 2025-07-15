const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const User = require('../model/user');
const Merchant = require('../model/merchant');
const db = require('../helpers/dbHelper');
const { success, fail, error } = require('../helpers/responseHelper');

// ✅ Register normal user
exports.registerUser = async (req, res) => {
  try {
    const { name, ic_number, email, phone, password } = req.body;
    // ic_photo is handled by multer, available as req.file
    if (!name || !ic_number || !email || !phone || !password) {
      return fail(res, 'Missing required fields');
    }

    // Check existing
    const existing = await User.findByEmail(email);
    if (existing) return fail(res, 'Email already registered');

    const hashed = await bcrypt.hash(password, 10);
    const user_id = uuidv4();

    // Handle ic_photo upload
    let ic_photo = null;
    if (req.file && req.file.path) {
      ic_photo = req.file.path;
    }

    // Create user
    const newUser = await User.create({
      user_id,
      name,
      ic_number,
      email,
      phone,
      password: hashed,
      ic_photo,
    });

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
    const {
      user_id,
      business_name,
      business_type,
      bank_header,
      category_service,
      ssm_address,
    } = req.body;

    // ssm_doc is handled by multer, available as req.files?.ssm_doc
    let ssm_doc = null;
    if (req.files && req.files.ssm_doc && req.files.ssm_doc[0]) {
      ssm_doc = req.files.ssm_doc[0].path;
    }

    if (
      !user_id ||
      !business_name ||
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
      business_name,
      business_type,
      bank_header,
      category_service,
      ssm_address,
      ssm_doc,
    });

    return success(res, "Merchant wallet added", {
      user_id,
      wallet_type: "merchant",
      business_name,
    });
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
        business_name: merchantWallet.business_name,
        business_type: merchantWallet.business_type,
        bank_header: merchantWallet.bank_header,
        category_service: merchantWallet.category_service,
        ssm_address: merchantWallet.ssm_address,
        ssm_doc: merchantWallet.ssm_doc || null,
      };
    }

    // Final JSON response
    return success(res, "Login success", {
      user: {
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        ic_photo: user.ic_photo || null,
        created_at: user.created_at,
      },
      wallets: wallets.map((w) => ({
        wallet_id: w.wallet_id,
        wallet_type: w.wallet_type,
        balance: w.balance,
        currency: w.currency,
      })),
      merchant: merchantInfo,
    });
  } catch (err) {
    console.error(err);
    return error(res, err.message);
  }
};
