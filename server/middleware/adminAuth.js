require('dotenv').config(); // ✅ load env variables

module.exports = function (req, res, next) {
    const { username } = req.session || {};
    
    if (username === process.env.ADMIN_USER) {
        return next();
    }

    return res.redirect('/admin/login');
};
