const conn = require("../Backend/config/database");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const http = require("http");
const WebSocket = require("ws");
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const secretKey = process.env.JWT_SECRET_KEY; // JWT 서명에 사용할 비밀키

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' })); // JSON 요청 크기 제한
app.use(bodyParser.urlencoded({ limit: '100mb', extended: true })); // URL-encoded 요청 크기 제한

// 데이터베이스 연결
conn.connect(err => {
    if (err) {
        console.log("DB연결 실패!", err);
    } else {
        console.log("DB연결 성공!");
    }
});

// HTTP 서버 생성
const server = http.createServer(app);

// WebSocket 서버 설정
const wss = new WebSocket.Server({ server });

// WebSocket 설정
wss.on('connection', (ws) => {
    console.log('A new WebSocket client connected!');

    ws.isAlive = true;
    ws.user = null;

    ws.on('message', (message) => {
        console.log('WebSocket Message Received:', message);
        try {
            const data = JSON.parse(message);
            if (data.type === 'authenticate') {
                const token = data.token;
                jwt.verify(token, secretKey, (err, decoded) => {
                    if (err) {
                        console.log('Invalid WebSocket token');
                        ws.send(JSON.stringify({ type: 'error', message: 'Invalid token' }));
                        ws.close();
                    } else {
                        ws.user = decoded;
                        console.log(`WebSocket client authenticated as ${decoded.userid}`);
                        ws.send(JSON.stringify({ type: 'authenticated', message: 'Authentication successful' }));
                    }
                });
            }
        } catch (e) {
            console.log('Error processing WebSocket message:', e);
            ws.send(JSON.stringify({ type: 'error', message: 'Invalid message format' }));
        }
    });

    ws.on('close', () => {
        console.log('WebSocket client disconnected');
    });
});

// 라우터 설정
const userRouter = require("./routes/user")(wss); // wss를 파라미터로 전달
app.use("/user", userRouter);

const mapRouter = require("./routes/map");
const rtspRouter = require("./routes/rtsp");
const qrRouter = require("./routes/qr");
const productRouter = require("./routes/product");
const reservRouter = require("./routes/reserv");

app.use("/map", mapRouter);
app.use("/rtsp", rtspRouter);
app.use("/qr", qrRouter);
app.use("/product", productRouter);
app.use("/reserv", reservRouter);

// HTTP 서버 시작
server.listen(3000, () => {
    console.log('HTTP 서버가 3000번 포트에서 실행 중입니다.');
});

// WebSocket 서버 시작 로그
wss.on('listening', () => {
    console.log('WebSocket 서버가 3000번 포트에서 실행 중입니다.');
});
