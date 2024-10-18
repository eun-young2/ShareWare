const express = require('express');
const router = express.Router();
const conn = require("../config/database");

// 창고 인덱스로 좌표 가져오기
router.get("/:wh_idx", (req, res) => {
    const whIdx = req.params.wh_idx;
    const query = "SELECT lat, lon FROM tb_warehouse WHERE wh_idx = ?";

    conn.query(query, [whIdx], (err, results) => {
        if (err) {
            console.error("데이터베이스 쿼리 오류: ", err);
            return res.status(500).json({ error: "데이터베이스 오류" });
        }
        if (results.length > 0) {
            const { lat, lon } = results[0];
            res.json({ lat, lon });
        } else {
            res.status(404).json({ error: "창고를 찾을 수 없습니다" });
        }
    });
});

module.exports = router;