// helpers/dbHelper.js
const pool = require('../config/db'); // ✅ re‑use your existing pool

// ✅ CREATE (insert)
async function insert(table, data) {
    const keys = Object.keys(data);
    const values = Object.values(data);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');
    const query = `INSERT INTO ${table} (${keys.join(', ')}) VALUES(${placeholders}) RETURNING *`;
    const result = await pool.query(query, values);
    return result.rows[0];
}

// ✅ READ (find)
async function find(table, condition = {}, columns = ['*']) {
    const keys = Object.keys(condition);
    let query = `SELECT ${columns.join(', ')} FROM ${table}`;
    let values = [];
    if (keys.length > 0) {
        const where = keys.map((k, i) => `${k} = $${i + 1}`).join(' AND ');
        query += ` WHERE ${where}`;
        values = Object.values(condition);
    }
    const result = await pool.query(query, values);
    return result.rows;
}

// ✅ UPDATE
async function update(table, data, condition) {
    const dataKeys = Object.keys(data);
    const setClause = dataKeys.map((k, i) => `${k} = $${i + 1}`).join(', ');
    const condKeys = Object.keys(condition);
    const whereClause = condKeys.map((k, i) => `${k} = $${i + 1 + dataKeys.length}`).join(' AND ');
    const values = [...Object.values(data), ...Object.values(condition)];

    const query = `UPDATE ${table} SET ${setClause} WHERE ${whereClause} RETURNING *`;
    const result = await pool.query(query, values);
    return result.rows;
}
// ✅ DELETE
async function remove(table, condition) {
    const condKeys = Object.keys(condition);
    const whereClause = condKeys.map((k, i) => `${k} = $${i + 1}`).join(' AND ');
    const values = Object.values(condition);

    const query = `DELETE FROM ${table} WHERE ${whereClause} RETURNING *`;
    const result = await pool.query(query, values);
    return result.rows;
}
module.exports = {
    insert,
    find,
    update,
    remove
};