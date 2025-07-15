const express = require('express');
const axios = require('axios');
const router = express.Router();

// Base API URL of your wallet server
const API_URL = 'http://localhost:3000/api';

router.get('/', async (req, res) => {
    // dashboard shows counts
    try {
        // fetch all users (you can add an API endpoint to list users)
        // for now, just render dashboard
        res.render('dashboard', { totalUsers: 10, totalTransactions: 25 });
    } catch (err) {
        res.status(500).send('Error fetching dashboard data');
    }
});

router.get('/users/:user_id', async (req, res) => {
    try {
        const balanceRes = await axios.get(`${API_URL}/wallet/${req.params.user_id}`);
        const txnRes = await axios.get(`${API_URL}/wallet/${req.params.user_id}/transactions`);
        res.render('users', {
            userId: req.params.user_id,
            balance: balanceRes.data.balance,
            currency: balanceRes.data.currency,
            transactions: txnRes.data.transactions
        });
    } catch (err) {
        res.status(500).send('Error fetching user data');
    }
});

module.exports = router;