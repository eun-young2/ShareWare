const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const verifyToken = require('../routes/verify'); // JWT 미들웨어 불러오기

// 사용자의 예약 정보와 지점 정보 조회 API
router.get('/user/warehouses', verifyToken, async (req, res) => {
    try {
        const userId = req.user.userid; // 로그인된 사용자의 ID를 JWT나 세션을 통해 확인
        
        if (!userId) {
            console.warn('인증 오류: 사용자 ID를 확인할 수 없습니다.');
            return res.status(401).json({ error: '사용자가 인증되지 않았습니다.' });
        }

        const query = `
            SELECT unit_idx, w.wh_idx, w.wh_branch_name
            FROM tb_reservation r
            JOIN tb_warehouse w ON r.wh_idx = w.wh_idx
            WHERE r.user_id = ? AND r.reserv_status = 'in_use'
        `;

        const [rows] = await conn.promise().query(query, [userId]);
        
        if (rows.length === 0) {
            console.info(`예약 정보 없음: user_id=${userId}`);
            return res.status(404).json({ error: '예약된 지점을 찾을 수 없습니다.' });
        }

        return res.json(rows); // 각 row에 wh_branch_name, unit_idx, wh_idx 포함

    } catch (error) {
        if (error.code === 'ER_BAD_DB_ERROR') {
            console.error('데이터베이스 오류: 잘못된 데이터베이스 이름이 설정되어 있습니다.', error);
        } else if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            console.error('접근 오류: 데이터베이스에 접근할 수 없습니다. 사용자 권한을 확인하세요.', error);
        } else if (error instanceof TypeError) {
            console.error('타입 오류 발생:', error);
        } else {
            console.error('알 수 없는 서버 오류:', error);
        }
        
        return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
    }
});


// 선택된 지점과 유닛에 해당하는 물품 목록 조회 API
router.get('/items', verifyToken, async (req, res) => {
    try {
        const userId = req.user.userid;
        const { wh_idx, unit_idx } = req.query;

        if (!userId || !wh_idx || !unit_idx) {
            return res.status(400).json({ error: '필수 매개변수가 누락되었습니다.' });
        }

        const query = `
            SELECT prod_idx, prod_name, prod_info, prod_img
            FROM tb_product
            WHERE user_id = ? AND wh_idx = ? AND unit_idx = ? AND prod_deleted = 1
        `;
        
        const [rows] = await conn.promise().query(query, [userId, wh_idx, unit_idx]);
        
        // Buffer를 Base64로 변환
        const formattedRows = rows.map(row => ({
            ...row,
            prod_img: row.prod_img ? row.prod_img.toString('base64') : null
        }));
        
        // console.log('물품 목록:', formattedRows);
        return res.json(formattedRows); // 물품 목록을 JSON 형식으로 반환
    } catch (error) {
        console.error('서버 오류:', error);
        return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
    }
});

// 물건 등록 API
router.post('/register', verifyToken, async (req, res) => {

  try {
      const user_id = req.user.userid;
      const { wh_idx, unit_idx, prod_name, prod_info, prod_img } = req.body;

      if (!user_id || !wh_idx || !unit_idx || !prod_name) {
          console.warn('유효성 검사 오류: 필수 필드가 누락되었습니다.');
          return res.status(400).json({ error: '필수 필드가 누락되었습니다.' });
      }

      const query = `
          INSERT INTO tb_product (wh_idx, user_id, prod_name, prod_info, created_at, unit_idx, prod_img)
          VALUES (?, ?, ?, ?, NOW(), ?,?)
      `;

      const [result] = await conn.promise().query(query, [wh_idx, user_id, prod_name, prod_info, unit_idx, JSON.stringify(prod_img)]);

      console.log('물건이 성공적으로 등록되었습니다:');
      console.log(`등록된 데이터: user_id=${user_id}, wh_idx=${wh_idx}, unit_idx=${unit_idx}, prod_name=${prod_name}, prod_info=${prod_info},prod_img=${prod_img}`);
      
      return res.status(201).json({ success: true, message: '물건이 성공적으로 등록되었습니다.', prod_idx: result.insertId });

  } catch (error) {
      console.error('서버 오류:', error);
      return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
  }
});

// 물품 삭제 API
router.delete('/delete/:prod_idx', verifyToken, async (req, res) => {
    try {
        const userId = req.user.userid;
        const { prod_idx } = req.params;

        if (!userId || !prod_idx) {
            return res.status(400).json({ error: '필수 매개변수가 누락되었습니다.' });
        }

        const query = `
            UPDATE tb_product
            SET prod_deleted = 0
            WHERE prod_idx = ? AND user_id = ?
        `;

        const [result] = await conn.promise().query(query, [prod_idx, userId]);

        if (result.affectedRows > 0) {
            console.log(`물품 삭제 성공: prod_idx=${prod_idx}, user_id=${userId}`);
            return res.status(200).json({ success: true, message: '물품이 성공적으로 삭제되었습니다.' });
        } else {
            console.warn(`물품 삭제 실패: 물품이 존재하지 않거나 사용자 권한이 없습니다. prod_idx=${prod_idx}, user_id=${userId}`);
            return res.status(404).json({ error: '물품을 찾을 수 없거나 삭제할 권한이 없습니다.' });
        }
    } catch (error) {
        console.error('서버 오류:', error);
        return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
    }
});

module.exports = router;
