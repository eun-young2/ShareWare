const express = require('express');
const router = express.Router();
const conn = require("../config/database");

// 창고 이름으로 좌표 및 추가 정보 가져오기
router.get("/:wh_branch_name", (req, res) => {
    const whBranchName = req.params.wh_branch_name; // wh_branch_name 매개변수 받기
    const query = "SELECT wh_branch_name, wh_addr, contact_info, business_hours, lat, lon, facilities  FROM tb_warehouse WHERE wh_branch_name = ?"; // 쿼리 수정

    conn.query(query, [whBranchName], (err, results) => {
        if (err) {
            console.error("데이터베이스 쿼리 오류: ", err);
            return res.status(500).json({ error: "데이터베이스 오류" });
        }
        if (results.length > 0) {
            const { wh_branch_name, wh_addr, contact_info, business_hours, lat, lon, facilities  } = results[0];
            res.json({ 
                wh_branch_name, 
                wh_addr, 
                contact_info, 
                business_hours, 
                lat, 
                lon,
                facilities 
            });
        } else {
            res.status(404).json({ error: "창고를 찾을 수 없습니다" });
        }
    });
});


// 모든 창고의 좌표 가져오기
router.get("/all/warehouses", (req, res) => {
    const query = "SELECT wh_branch_name, wh_addr, contact_info, business_hours, lat,lon, facilities  FROM tb_warehouse"; // 모든 창고 정보 가져오기
    conn.query(query, (err, results) => {
        if (err) {
            console.error("데이터베이스 쿼리 오류: ", err);
            return res.status(500).json({ error: "데이터베이스 오류" });
        }
        res.json(results); // 결과를 JSON 형식으로 반환
    });
});

// 특정 user_id의 예약된 창고 좌표 및 추가 정보 가져오기
router.get("/user/:user_id", (req, res) => {
    const userId = req.params.user_id; // user_id 매개변수 받기
    const query = `
        SELECT 
            w.wh_branch_name, w.wh_addr, w.contact_info, 
            w.business_hours, w.lat, w.lon, w.facilities 
        FROM 
            tb_reservation r
        INNER JOIN 
            tb_warehouse w ON r.wh_idx = w.wh_idx
        WHERE 
            r.user_id = ?`;

    conn.query(query, [userId], (err, results) => {
        if (err) {
            console.error("데이터베이스 쿼리 오류: ", err);
            return res.status(500).json({ error: "데이터베이스 오류" });
        }
        if (results.length > 0) {
            res.json(results); // 결과를 JSON 형식으로 반환
        } else {
            res.status(404).json({ error: "예약된 창고를 찾을 수 없습니다" });
        }
    });
});

module.exports = router;