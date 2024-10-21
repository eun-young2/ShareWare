const express = require('express');
const router = express.Router();
const conn = require("../config/database");

// 창고 이름으로 좌표 가져오기
router.get("/:wh_branch_name", (req, res) => {
    const whBranchName = req.params.wh_branch_name; // wh_branch_name 매개변수 받기
    const query = "SELECT lat, lon FROM tb_warehouse WHERE wh_branch_name = ?"; // 쿼리 수정

    conn.query(query, [whBranchName], (err, results) => {
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


// 모든 창고의 좌표 가져오기
router.get("/all/warehouses", (req, res) => {
    const query = "SELECT lat,lon FROM tb_warehouse"; // 모든 창고 정보 가져오기
    conn.query(query, (err, results) => {
        if (err) {
            console.error("데이터베이스 쿼리 오류: ", err);
            return res.status(500).json({ error: "데이터베이스 오류" });
        }
        res.json(results); // 결과를 JSON 형식으로 반환
    });
});


module.exports = router;