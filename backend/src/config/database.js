const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
<<<<<<< HEAD
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'vocab_app',
    waitForConnections: true,
    connectionLimit: 10,
=======
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'vocab_app',
  waitForConnections: true,
  connectionLimit: 10,
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
});

module.exports = pool;
