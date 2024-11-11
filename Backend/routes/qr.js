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
        console.error('DB 조회 실패:', error);
        return res.status(500).json({ error: 'DB 조회 실패' });
    }


    if (results.length === 0) {
        console.log('No results found for user.');
        return res.status(404).json({ error: '사용자가 사용 중인 예약이 없습니다.' });
    }

    const branches = results.map(result => ({
        wh_idx: result.wh_idx, // wh_idx 확인
        name: result.wh_branch_name,
        address: result.wh_addr,
        contact: result.contact_info
    }));

   // console.log('Formatted branches:', branches); // 포맷된 응답 데이터 확인

    res.json({ branches });
    });
});


// QR 코드 검증 라우트
router.get('/check-qr', (req, res) => {
    const { reserv_idx } = req.query;
    

    // tb_qr 테이블의 reserv_idx에 따라 tb_reservation 테이블의 wh_idx와 user_id 가져오기
    const query = `
        SELECT q.is_valid, r.wh_idx, r.user_id
        FROM tb_qr q
        JOIN tb_reservation r ON q.reserv_idx = r.reserv_idx
        WHERE q.reserv_idx = ?
        ORDER BY q.created_at DESC
        LIMIT 1
    `;

    conn.query(query, [reserv_idx.split(':')[1]], (error, results) => {
        if (error) {
            return res.status(500).send('Database error');
        }

        // 쿼리 결과 확인을 위해 로그 출력
        console.log('Query results:', results);

        if (results.length > 0 && results[0].is_valid === 1) {
            const { wh_idx, user_id } = results[0];


            if (!wh_idx || !user_id) {
                return res.status(400).send('wh_idx나 user_id가 누락되었습니다');
            }

            res.json({ is_valid: 1, message: '문이 열렸습니다' });

            // FastAPI에 요청 전송 (async/await 제거하고 비동기 콜백 사용)
            fetch(`http://127.0.0.1:8000/send_to_model/${reserv_idx.split(':')[1].trim()}`, {
                method: 'POST'
            })
            .then(response => {
                console.log(`FastAPI response status: ${response.status}`);
                if (!response.ok) {
                    console.error('Failed to send data to FastAPI');
                }
            })
            .catch(err => {
                console.error('Error calling FastAPI:', err);
            });


            // tb_user_log에 데이터 삽입
            const insertQuery = 'INSERT INTO tb_user_log (wh_idx, user_id, log_type, log_at) VALUES (?, ?, ?, NOW())';
            conn.query(insertQuery, [wh_idx, user_id, 'entry'], (insertError) => {
                if (insertError) {
                    console.error('tb_user_log 삽입 오류:', insertError);
                } else {
                    console.log('tb_user_log에 성공적으로 데이터 삽입');
                }
            });
        } else {
            res.json({ is_valid: 0, message: '유효하지 않은 QR코드입니다' });
        }
    });
});

// QR 코드 퇴실 처리 라우트 추가
router.post('/exit', verifyToken, (req, res) => {
    
    const userId = req.user.userid; // JWT에서 추출한 user_id
    const { wh_idx } = req.body; // 요청 본문에서 wh_idx 가져오기

    if (!wh_idx) {
        return res.status(400).json({ error: 'wh_idx가 누락되었습니다' });
    }

    // tb_user_log 테이블에 '퇴실' 로그 삽입
    const insertQuery = 'INSERT INTO tb_user_log (wh_idx, user_id, log_type, log_at) VALUES (?, ?, ?, NOW())';
    conn.query(insertQuery, [wh_idx, userId, 'exit'], (error) => {
        if (error) {
            console.error('tb_user_log 삽입 오류:', error);
            return res.status(500).json({ error: '로그 삽입 실패' });
        } else {
            console.log('tb_user_log에 퇴실 로그가 성공적으로 삽입되었습니다');
            return res.status(200).json({ message: '퇴실 로그가 성공적으로 삽입되었습니다' });
        }
    });
});

// 출입 로그 조회 API
router.get('/entry-logs', verifyToken, (req, res) => {
    const userId = req.user.userid; // 토큰에서 추출한 user_id
    console.log(userId);
    
    const query = `
        SELECT log_at, log_type, user_id 
        FROM tb_user_log 
        ORDER BY log_at DESC
    `;

    conn.query(query, [userId], (error, results) => {
        if (error) {
            console.error('DB 조회 실패:', error);
            return res.status(500).json({ error: 'DB 조회 실패' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: '출입 로그가 없습니다.' });
        }

        res.json({ logs: results });
    });
});
module.exports = router;
