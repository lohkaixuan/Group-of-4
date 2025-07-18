// server.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const session = require('express-session');
const ngrok = require('ngrok');

// import routes
const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/admin');
const transactionRoutes = require('./routes/transactionRoutes');
const walletRoutes = require('./routes/walletRoutes');
const merchantRoutes = require('./routes/merchantRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// ✅ Add session config before routes
app.use(session({
    secret: 'super_secret_admin_session_key', // use a strong secret in production!
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } // set to true if using HTTPS
}));

// ✅ Mount admin routes (needs session middleware above)
app.use('/admin', adminRoutes);

// ✅ Mount other API routes
app.use('/merchant', merchantRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/wallets', walletRoutes);
app.use('/auth', authRoutes);

app.get('/', (req, res) => {
    res.send(`✅ Auth service running on port ${process.env.PORT}`);
});

const PORT = process.env.PORT || 1060;
app.listen(PORT, '0.0.0.0', async () => {
    console.log(`🔥 Auth server running at http://0.0.0.0:${PORT}`);

    try {
        const url = await ngrok.connect({
            addr: PORT,
            proto: 'http'
        });
        console.log(`🌍 Ngrok tunnel running at: ${url}`);
        console.log(`➡️ Forwarding to http://0.0.0.0:${PORT}`);
    } catch (err) {
        console.error('❌ Error starting ngrok:', err);
    }
});
