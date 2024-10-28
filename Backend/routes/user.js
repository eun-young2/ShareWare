const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const bcrypt = require("bcrypt");
require('dotenv').config();
const jwt = require('jsonwebtoken'); // JWT 라이브러리 추가
const secretKey = process.env.JWT_SECRET_KEY; // JWT 서명에 사용할 비밀키
const verifyToken = require('../routes/verify');  // JWT 미들웨어 불러오기

//회원가입
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

//유저 프로필 보기
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

//회원탈퇴
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

// 보호된 라우트
router.get('/protected', verifyToken, (req, res) => {
    // 유효한 토큰이 있으면 이 부분이 실행됨
    res.status(200).json({ message: '로그인 성공', user: req.user });
});

module.exports = router;