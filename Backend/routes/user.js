const express = require('express');
const router = express.Router();
const conn = require("../config/database");
const bcrypt = require("bcrypt");

//회원가입
router.post('/signup', async (req, res) => {
    console.log("회원가입 요청이 들어왔습니다:", req.body);

    const { name, userid, password, phone_number } = req.body;

    try {
        const hash = await bcrypt.hash(password, 10);
        const query = 'INSERT INTO user (name, userid, password, phone_number) VALUES (?, ?, ?, ?)';

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

//로그인
router.post('/login', async (req, res) => {
    const { userid, password } = req.body;

    try {
        const query = 'SELECT * FROM user WHERE userid = ?';
        conn.query(query, [userid], async (error, results) => {
            if (error) {
                console.log('SQL 에러:', error);
                return res.status(500).json({ message: '서버 오류' });
            }

            if (results.length > 0) {
                const user = results[0];

                // 비밀번호 확인
                const isPasswordMatch = await bcrypt.compare(password, user.password);
                if (isPasswordMatch) {
                    // 로그인 성공 시
                    return res.status(200).json({
                        message: '로그인 성공',
                        role: user.role, // 사용자 역할 반환
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



module.exports = router;