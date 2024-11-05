
const conn = require("../Backend/config/database");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const router = express();

router.use(cors());

// body-parser 설정에서 요청 크기 제한 증가
router.use(bodyParser.json({ limit: '10mb' })); // JSON 요청 크기 제한
router.use(bodyParser.urlencoded({ limit: '100mb', extended: true })); // URL-encoded 요청 크기 제한

// // 또는 기본 크기 제한을 높여주는 전체 설정 적용
// router.use(express.json({ limit: '100mb' }));
// router.use(express.urlencoded({ limit: '100mb', extended: true }));


//데이터베이스 연결
conn.connect(err=>{
    if(err){
        console.log("DB연결 실패!", err);
        
    }else{
        console.log("DB연결 성공!");
        
    }
})

const userRouter = require("./routes/user");
const mapRouter = require("./routes/map");
const rtspRouter = require("./routes/rtsp");
const qrRouter = require("./routes/qr");
const productRouter = require("./routes/product");
const reservRouter = require("./routes/reserv");

router.use("/user", userRouter);
router.use("/map", mapRouter);
router.use("/rtsp", rtspRouter);
router.use("/qr", qrRouter);
router.use("/product", productRouter);
router.use("/reserv", reservRouter);

//서버실행
router.listen(3000,()=>{
    console.log('서버가 3000번 포트에서 실행 중입니다.');
})