const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const verifyToken = require('../routes/verify'); // JWT 미들웨어 불러오기

// 사용자의 예약 정보와 지점 정보 조회 API
router.get('/user/warehouses', verifyToken, async (req, res) => {
    try {
        const userId = req.user.userid;
        
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

        return res.json(rows);

    } catch (error) {
        // 에러 로그에 상세 정보 추가
        console.error('서버 오류 발생 (user/warehouses):', error);
        
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
        
        // Base64로 인코딩된 String 그 자체를 반환
        const formattedRows = rows.map(row => ({
            ...row,
            prod_img: row.prod_img ? row.prod_img.toString() : null
        }));
        
        // console.log('물품 목록:', formattedRows);
        return res.json(formattedRows); // 물품 목록을 JSON 형식으로 반환
    } catch (error) {
        console.error('서버 오류 발생 (items 조회):', error);
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
          VALUES (?, ?, ?, ?, NOW(), ?, ?)
      `;

      // prod_img가 유효한 Base64 문자열인지 확인
      if (prod_img && typeof prod_img !== 'string') {
          return res.status(400).json({ error: 'prod_img는 Base64 문자열이어야 합니다.' });
      }

      const [result] = await conn.promise().query(query, [wh_idx, user_id, prod_name, prod_info, unit_idx, prod_img]);

      console.log('물건이 성공적으로 등록되었습니다:');
      console.log(`등록된 데이터: user_id=${user_id}, wh_idx=${wh_idx}, unit_idx=${unit_idx}, prod_name=${prod_name}, prod_info=${prod_info}`);
      
      return res.status(201).json({ success: true, message: '물건이 성공적으로 등록되었습니다.', prod_idx: result.insertId });

  } catch (error) {
      console.error('서버 오류 발생 (register):', error);
      return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
  }
});

// 물품 수정 API
router.put('/update/:prod_idx', verifyToken, async (req, res) => {

    try {
        const userId = req.user.userid;
        const prod_idx = parseInt(req.params.prod_idx, 10);

        const { prod_name, prod_info, prod_img, wh_idx, unit_idx } = req.body;

        if (!userId || !prod_idx || !prod_name) {
            return res.status(400).json({ error: '필수 필드가 누락되었습니다.' });
        }

        // prod_img가 유효한 Base64 문자열인지 검증
        if (prod_img && typeof prod_img !== 'string') {
            return res.status(400).json({ error: 'prod_img는 Base64 문자열이어야 합니다.' });
        }

        const query = `
            UPDATE tb_product
            SET prod_name = ?, prod_info = ?, wh_idx = ?, unit_idx = ?, prod_img = ?, updated_at = NOW()
            WHERE prod_idx = ? AND user_id = ?
        `;
        const queryParams = [prod_name, prod_info, wh_idx, unit_idx, prod_img, prod_idx, userId];

        const [result] = await conn.promise().query(query, queryParams);

        if (result.affectedRows > 0) {
            return res.status(200).json({
                success: true,
                message: '물품이 성공적으로 수정되었습니다.',
                data: {
                    prod_idx,
                    prod_name,
                    prod_info,
                    prod_img,
                    wh_idx,
                    unit_idx
                }
            });
        } else {
            return res.status(404).json({ error: `물품 수정 실패 : 물품을 찾을 수 없거나 수정할 권한이 없습니다. prod_idx=${prod_idx}, user_id=${userId}` });
        }
    } catch (error) {
        console.error('서버 오류 발생 (update):', error);
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
            return res.status(404).json({ error: `물품 삭제 실패: 물품이 존재하지 않거나 사용자 권한이 없습니다. prod_idx=${prod_idx}, user_id=${userId}` });
        }
    } catch (error) {
        console.error('서버 오류 발생 (delete):', error);
        return res.status(500).json({ error: '서버 오류가 발생했습니다. 나중에 다시 시도해 주세요.' });
    }
});

module.exports = router;
