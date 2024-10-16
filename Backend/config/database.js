// 5-1. mysql 모듈 가져오기
require('dotenv').config();
const mysql = require('mysql2');

// 5-2. DB정보 저장
const conn = mysql.createConnection({
    'host': process.env.DB_HOST,
    'user' : process.env.DB_USER,
    'password' : process.env.DB_PASSWORD,
    'port' : process.env.DB_PORT,
    'database' : process.env.DB_NAME
})
//
// 5-3. DB 정보 연결 및 모듈 내보내기
conn.connect()
module.exports = conn