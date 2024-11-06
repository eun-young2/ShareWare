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
// 방문객 통계 API
router.get('/visitor-stats', verifyToken, (req, res) => {
  const userId = req.user.userid;

  // 월간 방문객 수 쿼리 (지난 30일 동안)
  const monthlyQuery = `
    SELECT COUNT(*) AS monthly_visitors
    FROM tb_reservation
    WHERE reserv_status = 'in_use'
      AND start_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  `;

  // 금일 방문객 수 쿼리
  const dailyQuery = `
    SELECT COUNT(*) AS daily_visitors
    FROM tb_reservation
    WHERE reserv_status = 'in_use'
      AND DATE(start_date) = CURDATE()
  `;

  // 첫 번째 쿼리 실행
  conn.query(monthlyQuery, [userId],(err, monthlyResults) => {
    if (err) {
      console.error('Database query error (monthly): ', err);
      return res.status(500).json({ message: 'Internal server error' });
    }


    // 두 번째 쿼리 실행
    conn.query(dailyQuery,[userId], (err, dailyResults) => {
      if (err) {
        console.error('Database query error (daily): ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }

      // 응답 형식: { monthly_visitors: 값, daily_visitors: 값 }
      res.json({
        monthly_visitors: monthlyResults[0].monthly_visitors,
        daily_visitors: dailyResults[0].daily_visitors
      });
    });
  });
});

module.exports = router;
