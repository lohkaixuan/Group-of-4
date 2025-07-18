const express = require('express');
const router = express.Router();
const MerchantController = require('../controllers/MerchantController');
const { db } = require('../config/firebase');
const adminAuth = require('../middleware/adminAuth'); // ✅ ADD THIS

// 📥 Login form
router.get('/login', (req, res) => {
    res.send(`
    <h2>Admin Login</h2>
    <form method="POST" action="/admin/login">
        <input name="username" placeholder="Username"/><br/>
        <input name="password" type="password" placeholder="Password"/><br/>
        <button type="submit">Login</button>
    </form>
    `);
});

// 📤 Login handler
router.post('/login', express.urlencoded({ extended: true }), (req, res) => {
    const { username, password } = req.body;
    if (username === process.env.ADMIN_USER && password === process.env.ADMIN_PASS) {
        req.session.username = username;
        return res.redirect('/admin/dashboard');
    }
    res.send('❌ Invalid credentials. <a href="/admin/login">Try again</a>');
});

// 📋 Dashboard with merchants table
router.get('/dashboard', adminAuth, async (req, res) => {
    console.log('📌 Admin dashboard accessed');
    const snap = await db.collection('users').where('role', '==', 'merchant').get();
    console.log(`📌 Found ${snap.size} merchants`);
    let html = `<h2>Merchant Approval Dashboard</h2>
    <table border="1" cellpadding="8">
    <tr><th>Name</th><th>Email</th><th>Status</th><th>Action</th></tr>`;

    snap.docs.forEach(doc => {
        const d = doc.data();
        html += `<tr>
        <td>${d.name || ''}</td>
        <td>${d.email || ''}</td>
        <td>${d.email || ''}</td>
        <td>
            ${d.ssm_certificate
                ? `<a href="${d.ssm_certificate}" target="_blank">View SSM</a>`
                : 'No SSM uploaded'}
        </td>
        <td>  ${d.ic_photo
                ? `<a href="${d.ic_photo}" target="_blank">
                        <img src="${d.ic_photo}" alt="IC Photo" style="width:80px; height:auto; border:1px solid #ccc; border-radius:4px;" />
                    </a>`
                : 'No IC uploaded'}
        </td>
        <td>
            ${d.status === 'approved' ? '—' : `
            <form method="POST" action="/admin/approve">
            <input type="hidden" name="id" value="${doc.id}" />
            <button type="submit">Approve</button>
            </form>
        `}
        </td>
    </tr>`;
    });

    html += `</table><br/><a href="/admin/logout">Logout</a>`;
    res.send(html);
});

// ✅ Approve handler
router.post('/approve', express.urlencoded({ extended: true }), adminAuth, async (req, res) => {
    const id = req.body.id;
    await MerchantController.approveMerchantById(id);
    res.redirect('/admin/dashboard');
});

// 🚪 Logout
router.get('/logout', (req, res) => {
    req.session.destroy(() => {
        res.redirect('/admin/login');
    });
});

module.exports = router;
