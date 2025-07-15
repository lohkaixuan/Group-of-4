const bcrypt = require('bcrypt');
const User = require('./models/userModel');
const { success, fail, error } = require('../helpers/responseHelper');

exports.register = async (req, res) => {
    try {
        const { user_id, password, role } = req.body;
        const existing = await User.findUser(user_id);
        if (existing) {
            return fail(res, 'User exists');
        }

        const hashed = await bcrypt.hash(password, 10);
        await User.createUser(user_id, hashed, role || 'user');
        return success(res, 'User registered', { user_id });
    } catch (err) {
        return error(res, err.message);
    }
};

exports.login = async (req, res) => {
    try {
        const { user_id, password } = req.body;
        const user = await User.findUser(user_id);
        if (!user) {
            return fail(res, 'User not found');
        }

        if (!user.password) {
            return error(res, 'User password not set');
        }
        const match = await bcrypt.compare(password, user.password);
        if (!match) {
            return fail(res, 'Invalid credentials');
        }
        return success(res, 'Login success', { user_id: user.user_id, role: user.role });
    } catch (err) {
        return error(res, err.message);
    }
};