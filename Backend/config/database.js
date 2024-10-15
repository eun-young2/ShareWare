// 5-1. mysql 모듈 가져오기
const mysql = require('mysql2');

// 5-2. DB정보 저장
const conn = mysql.createConnection({
    'host': '127.0.0.1',
    'user' : 'root',
    'password' : '1234',
    'port' : 3306,
    'database' : 'linkdb'
})

// 5-3. DB 정보 연결 및 모듈 내보내기
conn.connect()
module.exports = conn