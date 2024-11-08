const express = require('express');
const { spawn } = require('child_process');

const router = express.Router();
const conn = require("../config/database");

let ffmpegProcess; // ffmpeg 프로세스를 전역 변수로 관리

// RTSP 스트림을 HTTP로 변환하는 함수
function startStream(res) {
  ffmpegProcess = spawn('ffmpeg', [
    '-rtsp_transport', 'tcp',  // TCP를 통한 안정적인 RTSP 전송
    '-i', 'rtsp://sangbeom:lee5322984!@172.30.1.17:554/stream1', // RTSP URL
    '-f', 'mpegts',  // 출력 포맷
    '-codec:v', 'mpeg1video',  // 비디오 코덱 설정
    '-r', '30',  // 프레임 레이트
    '-b:v', '1M',  // 비트레이트 설정
    'pipe:1',  // 파이프로 출력
  ]);

  res.setHeader('Content-Type', 'video/mp2t');
  ffmpegProcess.stdout.pipe(res);

  ffmpegProcess.stderr.on('data', (data) => {
    console.error(`ffmpeg stderr: ${data.toString()}`);
  });

  ffmpegProcess.on('close', (code) => {
    console.log(`ffmpeg process closed with code ${code}`);
    
    // 비정상 종료 (null이나 0이 아닌 code로 종료된 경우) 시 재연결 시도
    if (code !== 0 && ffmpegProcess) {
      console.log('비정상 종료, 스트림 재시작 시도 중...');
      setTimeout(() => startStream(res), 3000); // 3초 후 재시작
    }
  });

  // 클라이언트가 연결을 끊으면 프로세스를 종료
  res.on('close', () => {
    if (ffmpegProcess) {
      ffmpegProcess.kill();
      ffmpegProcess = null;
      console.log('클라이언트 연결 끊김으로 스트림 프로세스 종료');
    }
  });
}

// 스트림을 시작하는 엔드포인트
router.get('/stream', (req, res) => {
  // 기존 프로세스가 실행 중이라면 중지하고 새로운 프로세스를 시작
  if (ffmpegProcess) {
    ffmpegProcess.kill();
  }
  startStream(res); // 스트림 시작
});

// 스트림을 중단하는 엔드포인트
router.get('/disconnect', (req, res) => {
  if (ffmpegProcess) {
    ffmpegProcess.kill(); // 프로세스를 종료하여 스트림 중단
    ffmpegProcess = null;
    console.log('스트림 연결 해제 성공');
    res.status(200).send('스트림 연결 해제 성공');
  } else {
    console.log('스트림이 실행 중이 아닙니다');
    res.status(400).send('스트림이 실행 중이 아닙니다');
  }
});

module.exports = router;
