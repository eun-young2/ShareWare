const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const verifyToken = require('../routes/verify');  // JWT 미들웨어 불러오기

// 예약 목록을 가져오는 API
router.get('/reservations', verifyToken, (req, res) => {
    const userId = req.user.userid; 
    // SQL 쿼리로 tb_reservation과 tb_user 테이블을 JOIN
    const query = `
      SELECT 
        r.reserv_idx, 
        r.reserv_status, 
        u.user_name, 
        DATE_FORMAT(r.start_date, '%Y-%m-%d') AS start_date, 
        DATE_FORMAT(r.expiration_date, '%Y-%m-%d') AS expiration_date
      FROM tb_reservation r
      JOIN tb_user u ON r.user_id = u.user_id
      ORDER BY r.reserv_idx 
    `;
    
    // 쿼리 실행
    conn.query(query, [userId], (err, results) => {
      if (err) {
        console.error('Database query error: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
  
      // 예약 정보 결과를 클라이언트로 반환
      res.json(results);
    });
  });

module.exports = router;
