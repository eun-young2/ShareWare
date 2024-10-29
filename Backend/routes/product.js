 const express = require('express');
 const router = express.Router();
 const conn = require("../config/database");
 const verifyToken = require('../routes/verify');  // JWT 미들웨어 불러오기
 

// 사용자의 예약 정보와 지점 정보 조회 API
router.get('/user/warehouses', verifyToken, async (req, res) => {
    
    const userId = req.user.userid;  // 로그인된 사용자의 ID를 JWT나 세션을 통해 확인
  
    if (!userId) {
      return res.status(401).json({ error: '사용자가 인증되지 않았습니다.' });
    }
  
    const query = `
      SELECT unit_idx, w.wh_idx, w.wh_branch_name
      FROM tb_reservation r
      JOIN tb_warehouse w ON r.wh_idx = w.wh_idx
      WHERE r.user_id = ? AND r.reserv_status = 'in_use'
    `;
  
    try {
      const [rows] = await conn.promise().query(query, [userId]);
      if (rows.length === 0) {
        return res.status(404).json({ error: '예약된 지점을 찾을 수 없습니다.' });
      }
  
      const warehouseNames = rows.map(row => row.wh_branch_name);
      return res.json(warehouseNames);
    } catch (error) {
      console.error('DB 쿼리 중 오류 발생:', error);
      return res.status(500).json({ error: '서버 오류가 발생했습니다.' });
    }
  });

 module.exports = router;
