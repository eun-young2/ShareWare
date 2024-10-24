const express = require('express');
const { spawn } = require('child_process');

const router = express.Router();
const conn = require("../config/database");

// ffmpeg를 사용해 RTSP 스트림을 HTTP 스트림으로 변환
router.get('/stream', (req, res) => {
  const ffmpeg = spawn('ffmpeg', [
    '-rtsp_transport', 'tcp',  // TCP를 통한 안정적인 RTSP 전송
    '-i', 'rtsp://sangbeom:lee5322984!@172.30.1.17:554/stream1', // RTSP URL
    '-f', 'mpegts',  // 출력 포맷
    '-codec:v', 'mpeg1video',  // 비디오 코덱 설정
    '-r', '30',  // 프레임 레이트
    '-b:v', '1M',  // 비트레이트 설정
    'pipe:1',  // 파이프로 출력
  ]);

  // HTTP로 스트리밍 전달
  res.setHeader('Content-Type', 'video/mp2t');
  ffmpeg.stdout.pipe(res);

  ffmpeg.stderr.on('data', (data) => {
    console.error(`ffmpeg stderr: ${data.toString()}`);
  });

  ffmpeg.on('close', (code) => {
    console.log(`ffmpeg process closed with code ${code}`);
  });
});

module.exports = router;