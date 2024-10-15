// 5-1. mysql 모듈 가져오기
const mysql = require('mysql2');

// 5-2. DB정보 저장
const conn = mysql.createConnection({
    'host': 'project-db-stu3.smhrd.com',
    'user' : 'Insa5_App_final_3',
    'password' : 'aischool3',
    'port' : 3307,
    'database' : 'Insa5_App_final_3'
})

// 5-3. DB 정보 연결 및 모듈 내보내기
conn.connect()
module.exports = conn