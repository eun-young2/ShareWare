module.exports = function (wss) {
    const express = require('express');
    const app = express(); // Express 앱 생성
    const router = express.Router();
    const conn = require("../config/database");
    const bcrypt = require("bcrypt");
    require('dotenv').config();
    const jwt = require('jsonwebtoken'); // JWT 라이브러리 추가
    const secretKey = process.env.JWT_SECRET_KEY; // JWT 서명에 사용할 비밀키
    const verifyToken = require('../routes/verify');  // JWT 미들웨어 불러오기
    const WebSocket = require("ws");

    // 요청 본문에서 JSON 데이터를 파싱하기 위해 필요
    app.use(express.json());

    // 회원가입
    router.post('/signup', async (req, res) => {
        console.log("회원가입 요청이 들어왔습니다:", req.body);

        const { name, userid, password, phone_number } = req.body;

        try {
            const hash = await bcrypt.hash(password, 10);
            const query = 'INSERT INTO tb_user (user_name, user_id, user_pw, user_phone, user_type, joined_at) VALUES (?, ?, ?, ?, "user", CURRENT_TIMESTAMP)';

            conn.query(query, [name, userid, hash, phone_number], (error, results) => {
                if (error) {
                    console.log('SQL 에러:', error);
                    return res.status(400).json({ message: '회원가입 실패' });
                }
                console.log('회원가입 성공:', results);
                res.status(200).json({ message: '회원가입 성공' });
            });
        } catch (error) {
            console.log('서버 에러:', error);
            return res.status(500).json({ message: '서버 오류' });
        }
    });

    // 로그인
    router.post('/login', async (req, res) => {
        const { userid, password } = req.body;

        try {
            const query = 'SELECT * FROM tb_user WHERE user_id = ?';
            conn.query(query, [userid], async (error, results) => {
                if (error) {
                    console.log('SQL 에러:', error);
                    return res.status(500).json({ message: '서버 오류' });
                }

                if (results.length > 0) {
                    const user = results[0];

                    // 비밀번호 확인
                    const isPasswordMatch = await bcrypt.compare(password, user.user_pw);
                    if (isPasswordMatch) {
                        // JWT 토큰 발급
                        const token = jwt.sign({ userid: user.user_id, role: user.user_type }, secretKey, { expiresIn: '1h' });

                        // 로그인 성공 시 토큰과 함께 반환
                        return res.status(200).json({
                            message: '로그인 성공',
                            userId: user.user_id, // 사용자 ID 추가
                            role: user.user_type,
                            token: token, // JWT 토큰 전달
                        });
                    } else {
                        return res.status(401).json({ message: '비밀번호가 일치하지 않습니다.' });
                    }
                } else {
                    return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
                }
            });
        } catch (error) {
            console.log('서버 에러:', error);
            return res.status(500).json({ message: '서버 오류' });
        }
    });

    // 유저 프로필 보기
    router.get('/profile', verifyToken, (req, res) => {
        const userId = req.user.userid;  // verifyToken 미들웨어로부터 user_id를 가져옴

        const query = 'SELECT user_id, user_name, user_phone FROM tb_user WHERE user_id = ?';
        conn.query(query, [userId], (error, results) => {
            if (error) {
                console.log('SQL 에러:', error);
                return res.status(500).json({ message: '서버 오류' });
            }

            if (results.length > 0) {
                const user = results[0];
                res.status(200).json({
                    user_id: user.user_id,
                    user_name: user.user_name,
                    user_phone: user.user_phone,
                });
            } else {
                res.status(404).json({ message: '사용자 정보를 찾을 수 없습니다.' });
            }
        });
    });

    // 휴대폰 번호 업데이트 엔드포인트 추가
    router.put('/update-phone', verifyToken, (req, res) => {
        const userId = req.user.userid;  // verifyToken 미들웨어에서 가져온 user_id
        const { newPhone } = req.body;

        const query = 'UPDATE tb_user SET user_phone = ? WHERE user_id = ?';
        conn.query(query, [newPhone, userId], (error, results) => {
            if (error) {
                console.log('SQL 에러:', error);
                return res.status(500).json({ message: '서버 오류' });
            }

            if (results.affectedRows > 0) {
                res.status(200).json({ message: '휴대폰 번호가 성공적으로 변경되었습니다.' });
            } else {
                res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
            }
        });
    });

    // 회원탈퇴
    router.delete('/delete-account', verifyToken, (req, res) => {
        const userId = req.user.userid;

        const query = 'DELETE FROM tb_user WHERE user_id = ?';
        conn.query(query, [userId], (error, results) => {
            if (error) {
                console.log('SQL 에러:', error);
                return res.status(500).json({ message: '서버 오류' });
            }

            if (results.affectedRows > 0) {
                res.status(200).json({ message: '회원 탈퇴가 성공적으로 완료되었습니다.' });
            } else {
                res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
            }
        });
    });

    //이상행동 알림
    router.post('/notify_abnormal_behavior', (req, res) => {
        console.log("여기 들어오니?");

        const { behavior_id, image } = req.body;
        if (!behavior_id) {
            return res.status(400).json({ message: 'behavior_id is required' });
        }

        // tb_abnormal_behavior 테이블에서 해당 behavior_id의 정보 가져오기
        const query = `
        SELECT ab.*, abi.image_url 
        FROM tb_abnormal_behavior ab
        LEFT JOIN tb_abnormal_behavior_images abi ON ab.behavior_id = abi.behavior_id
        WHERE ab.behavior_id = ? AND ab.alert = 0 AND ab.behavior_type = "이상행동"
    `;
        conn.query(query, [behavior_id], (error, results) => {
            if (error) {
                console.log('SQL 에러:', error);
                return res.status(500).json({ message: '서버 오류' });
            }

            if (results.length > 0) {
                const behavior = results[0];

                // 관리자들에게 웹소켓으로 알림 보내기
                const message = '이상행동이 탐지되었습니다';
                const image = behavior.image_url; // Base64 인코딩된 이미지

                wss.clients.forEach(function each(client) {
                    console.log(`Client state: ${client.readyState}`);
                    console.log(`Client user role: ${client.user?.role}`);
                    if (client.readyState === WebSocket.OPEN && client.user && client.user.role === 'admin') {
                        console.log("메세지 성공",message);
                        
                        client.send(JSON.stringify({ type: 'notification', message, image:image}));
                    }
                });

                // alert 컬럼을 1로 업데이트
                const updateQuery = 'UPDATE tb_abnormal_behavior SET alert = 1 WHERE behavior_id = ?';
                conn.query(updateQuery, [behavior_id], (error, updateResults) => {
                    if (error) {
                        console.log('SQL 에러:', error);
                        return res.status(500).json({ message: '서버 오류' });
                    }
                    res.status(200).json({ message: '알림이 전송되고 alert가 업데이트되었습니다.' });
                });
            } else {
                res.status(404).json({ message: '해당하는 이상행동이 없거나 이미 알림이 전송되었습니다.' });
            }
        });
    });

    // 알람 목록을 가져오는 API
router.get('/notifications', verifyToken, (req, res) => {
    const userId = req.user.userid;  // verifyToken 미들웨어에서 가져온 user_id

    // 관리자만 접근 가능
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: '관리자만 접근 가능합니다.' });
    }

    const query = 'SELECT behavior_id, behavior_type, created_at, alert, is_read FROM tb_abnormal_behavior WHERE alert = 1 ORDER BY created_at DESC';
    conn.query(query,[userId], (error, results) => {
        if (error) {
            console.log('SQL 에러:', error);
            return res.status(500).json({ message: '서버 오류' });
        }

        // 결과가 없으면 빈 배열 반환
        if (results.length === 0) {
            return res.status(404).json({ message: '알림이 없습니다.' });
        }

        // 알림 목록 반환
        res.status(200).json({ notifications: results });
    });
});

// 알람 읽음 처리 API
router.put('/mark-as-read/:behaviorId', verifyToken, (req, res) => {

    console.log('파라미터:', req.params);
    const behaviorId = req.params.behaviorId;

    const query = 'UPDATE tb_abnormal_behavior SET is_read = 1 WHERE behavior_id = ?';
    conn.query(query, [behaviorId], (error, results) => {
        
        if (error) {
            console.log('SQL 에러:', error);
            return res.status(500).json({ message: '서버 오류' });
        }

        if (results.affectedRows > 0) {
            res.status(200).json({ message: '알람이 읽음으로 표시되었습니다.' });
        } else {
            res.status(404).json({ message: '알람을 찾을 수 없습니다.' });
        }
    });
});
    
    return router;
};
