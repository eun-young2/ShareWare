
const conn = require("../Backend/config/database");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const router = express();
const bcrypt = require("bcrypt");

router.use(cors());
router.use(bodyParser.json()); //json 요청 처리

//데이터베이스 연결
conn.connect(err=>{
    if(err){
        console.log("DB연결 실패!",err);
        
    }else{
        console.log("DB연결 성공!");
        
    }
})

//서버실행
router.listen(3000,()=>{
    console.log('서버가 3000번 포트에서 실행 중입니다.');
    
})