// const express = require('express');
// const router = express.Router();
// const conn = require("../config/database");

// // 물품 등록
// router.post('/register-items', async (req, res) => {
//     console.log("물품 등록 요청이 들어왔습니다:", req.body);

//     // const { name, quantity, description, branch, images } = req.body;
//     const { name, info, , images } = req.body;

//     try {
//         const query = 'INSERT INTO tb_items (item_name, item_quantity, item_description, item_branch, item_images, created_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)';
//         conn.query(query, [name, quantity, info, branch, JSON.stringify(images)], (error, results) => {
//             if (error) {
//                 console.log('SQL 에러:', error);
//                 return res.status(400).json({ message: '물품 등록 실패' });
//             }
//             console.log('물품 등록 성공:', results);
//             res.status(200).json({ message: '물품 등록 성공' });
//         });
//     } catch (error) {
//         console.log('서버 에러:', error);
//         return res.status(500).json({ message: '서버 오류' });
//     }
// });

// module.exports = router;
