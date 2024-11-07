const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const verifyToken = require('../routes/verify');  // JWT 미들웨어 불러오기

// 지점 정보 조회 API
router.get('/branches', verifyToken, (req, res) => {
    const userId = req.user.userid; // 토큰에서 추출한 user_id

    const checkUserReservationQuery = `
        SELECT r.wh_idx, w.wh_branch_name, w.wh_addr, w.contact_info 
        FROM tb_reservation r
        JOIN tb_warehouse w ON r.wh_idx = w.wh_idx
        WHERE r.user_id = ? AND r.reserv_status = 'in_use'
    `;

    conn.query(checkUserReservationQuery, [userId], (error, results) => {
        if (error) {
            return res.status(500).json({ error: 'DB 조회 실패' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: '사용자가 사용 중인 예약이 없습니다.' });
        }

        const branches = results.map(result => ({
            wh_idx: result.wh_idx,
            name: result.wh_branch_name,
            address: result.wh_addr,
            contact: result.contact_info
        }));

        res.json({ branches });
    });
});

// QR 코드 검증 라우트
router.get('/check-qr', (req, res) => {
    const { reserv_idx } = req.query;
    const query = 'SELECT is_valid FROM tb_qr WHERE reserv_idx = ? ORDER BY created_at DESC LIMIT 1';

    conn.query(query, [reserv_idx.split(':')[1]], async (error, results) => {
        if (error) {
            return res.status(500).send('Database error');
        }

        console.log('Query results:', results);
        console.log('is_valid value:', results[0].is_valid);
        

        if (results.length > 0 && results[0].is_valid === 1) {
            
            res.json({ is_valid: 1, message: '문이 열렸습니다' });

            // FastAPI에 요청 전송
            try {
                const response = await fetch(`http://127.0.0.1:8000/send_to_model/${reserv_idx.split(':')[1].trim()}`, {
                    method: 'POST'
                });
                console.log(`FastAPI response status: ${response.status}`);

                if (!response.ok) {
                    console.error('Failed to send data to FastAPI');
                }
            } catch (err) {
                console.error('Error calling FastAPI:', err);
            }
        } else {
            res.json({ is_valid: 0, message: '유효하지 않은 QR코드입니다' });
        }
    });
});

module.exports = router;
