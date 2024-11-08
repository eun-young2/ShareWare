from fastapi import FastAPI, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import qrcode
import io
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import base64
import requests

# MySQL 데이터베이스 설정
DATABASE_URL = "mysql+pymysql://Insa5_App_final_3:aischool3@project-db-stu3.smhrd.com:3307/Insa5_App_final_3"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Reservation 모델 정의
class Reservation(Base):
    __tablename__ = "tb_reservation"
    user_id = Column(String, primary_key=True, index=True)
    unit_idx = Column(Integer)
    wh_idx = Column(Integer)
    reserv_idx = Column(Integer)
    reserv_status = Column(String)

# QRCode 모델 정의
class QRCode(Base):
    __tablename__ = "tb_qr"
    qr_idx = Column(Integer, primary_key=True, index=True)
    reserv_idx = Column(Integer)  # tb_reservation의 FK
    qr_code = Column(String(1200))  # QR 코드 데이터
    is_valid = Column(Integer)  # 유효성 (1 또는 0)
    created_at = Column(DateTime)  # 생성 시간
    

# FastAPI 앱 생성
app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# QR 발급
@app.get("/generate_qr/{user_id}")
async def generate_qr(user_id: str):
    db = SessionLocal()
    try:
        reservation = db.query(Reservation).filter(
            Reservation.user_id == user_id,
            Reservation.reserv_status == 'in_use'
        ).first()

        if not reservation:
            raise HTTPException(status_code=404, detail="Reservation not found")

        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        qr_data = f"User ID: {reservation.user_id}, reserv_idx: {reservation.reserv_idx}, Time: {current_time}"
        img = qrcode.make(qr_data)

        buffered = io.BytesIO()
        img.save(buffered, format="PNG")
        img_str = buffered.getvalue()

        # 이미지 데이터를 Base64로 인코딩
        img_base64 = base64.b64encode(img_str).decode('utf-8')

        # QR 코드 데이터 저장
        qr_code_entry = QRCode(
            reserv_idx=reservation.reserv_idx,  # 여기서 예약 인덱스 사용
            qr_code=img_base64,
            is_valid=1,  # 유효성
            created_at=datetime.now()  # 현재 시간
        )

        db.add(qr_code_entry)  # QR 코드 엔트리 추가
        db.commit()  # 데이터베이스에 저장
        db.refresh(qr_code_entry)  # 새로 생성된 엔티티를 새로고침

         # JSON 응답 반환
        return {
            "qr_code": img_base64,
            "reserv_idx": reservation.reserv_idx,
            "message": "QR code generated successfully"
        }
    except Exception as e:
        print(f"Error: {e}")  # 오류 메시지를 콘솔에 출력
        raise HTTPException(status_code=500, detail="Internal Server Error")
    
    finally:
        db.close()

# 새로운 엔드포인트: 특정 조건에 맞으면 모델에 `user_id`와 `unit_idx`를 전송
@app.post("/send_to_model/{reserv_idx}")
async def send_to_model(reserv_idx: int):
    db = SessionLocal()
    try:
        # `tb_reservation` 테이블에서 `reserv_idx`에 해당하는 항목 조회
        reservation = db.query(Reservation).filter(Reservation.reserv_idx == reserv_idx).first()
        if not reservation:
            raise HTTPException(status_code=404, detail="Reservation not found")

        # 전송할 데이터 구성
        data = {
            "user_id": reservation.user_id,
            "unit_idx": reservation.unit_idx
        }

        # 콘솔에 로그 출력 (전송할 데이터 확인)
        print(f"Sending data to model: {data}")

        # 모델 서버에 데이터 전송 "http://model-url.com/endpoint"
        response = requests.post(f"http://127.0.0.1:8000/send_to_model/{reserv_idx}", json=data)

        # 응답 검증
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Failed to send data to model")

        return {"message": "Data sent to model successfully"}
    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()

# QR isvalid=0 업데이트
@app.put("/invalidate_qr/{reserv_idx}")
async def invalidate_qr(reserv_idx: int):
    db = SessionLocal()
    try:
        # QR 코드의 유효성을 0으로 설정
        qr_code_entry = db.query(QRCode).filter(QRCode.reserv_idx == reserv_idx, QRCode.is_valid == 1).order_by(QRCode.created_at.desc()).first()  # 최신 순으로 정렬하여 첫 번째 항목 선택
        
        if not qr_code_entry:
            raise HTTPException(status_code=404, detail="QR code not found or already invalidated")
        
        qr_code_entry.is_valid = 0  # is_valid를 0으로 설정하여 무효화
        db.commit()
        db.refresh(qr_code_entry)  # 새로고침하여 변경된 상태 확인
        
        return {"message": "QR code invalidated successfully"}
    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")
    finally:
        db.close()

if __name__ == "__main__":
    import uvicorn
   # Base.metadata.drop_all(bind=engine)  # 기존 테이블 삭제
   # Base.metadata.create_all(bind=engine)  # 새 테이블 생성
    uvicorn.run(app, host="127.0.0.1", port=8000)
