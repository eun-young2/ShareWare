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

module.exports = router;
