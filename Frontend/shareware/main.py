from fastapi import FastAPI, Response, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
import qrcode
import io
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import base64
import requests
import json
from ultralytics import YOLO
import numpy as np
import cv2
from pydantic import BaseModel


# MySQL 데이터베이스 설정
DATABASE_URL = "mysql+pymysql://Insa5_App_final_3:aischool3@project-db-stu3.smhrd.com:3307/Insa5_App_final_3"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def to_dict(obj):
    """SQLAlchemy 객체를 사전 형태로 변환"""
    return {column.name: getattr(obj, column.name) for column in obj.__table__.columns}


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
    

# YOLO 모델 로드
model = YOLO("yolo11n.pt") 

forbidden_lst = ['cat','Person', 'Car', 'Boat', 'Flower', 'Bench', 'Potted Plant', 'SUV', 'Van', 'Couch', 'Bus', 'Wild Bird', 'Motorcycle', 'Truck', 'Sailboat', 'Bed', 'Horse', 'Sink', 'Apple', 'Pickup Truck', 'Dog', 'dog','Cow', 'Cake', 'Sheep', 'Other Fish', 'Orange/Tangerine', 'Tomato', 'Machinery Vehicle', 'Green Vegetables', 'Banana', 'Airplane', 'airplane','Mouse', 'Train', 'Pumpkin', 'Sports Car', 'Dessert', 'Scooter', 'Crane', 'Lemon', 'Duck', 'Cat', 'Broccoli', 'Piano', 'Pizza', 'Elephant', 'Gun', 'Gas stove', 'Donut', 'Carrot', 'Toilet', 'Strawberry', 'Pepper', 'Pigeon', 'Pie', 'Cookies', 'Zebra', 'Grape', 'Giraffe', 'Potato', 'Sausage', 'Egg', 'Candy', 'Fire Truck', 'Cucumber', 'Pear', 'Heavy Truck', 'Hamburger','Ship','Onion','Green beans','Chicken','Watermelon','Ice cream','French Fries','Cabbage','Hot dog','Peach','Rice','Deer','Goose','Pineapple','Ambulance','Mango','Penguin','Corn','Lettuce','Garlic','Swan','Helicopter','Green Onion','Sandwich','Nuts','Plum','Rickshaw','Goldfish','Kiwi fruit','Shrimp','Sushi','Cheese','Cherry','Pasta','Avocado','Hami melon','Mushroom','Bear','Eggplant','Coconut','Pig','Chips','Steak','Camel','Formula 1','Pomegranate','Crab','Meatball','Papaya','Antelope','Parrot','Seal','Butterfly','Donkey','Lion','Dolphin','Egg tart','Jellyfish','Grapefruit','Radish','Baozi','French','Spring Rolls','Monkey','Rabbit','Yak','Red Cabbage','Asparagus','Scallop','Noodles','Dumpling','Oyster','Lobster','Durian','Okra']

# 요청 데이터 모델 정의
class ImageData(BaseModel):
    image_data: str  # Base64로 인코딩된 이미지 데이터를 받음

# FastAPI 앱 생성
router = APIRouter()

# CORS 설정
# router.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


# QR 발급
@router.get("/generate_qr/{user_id}/{wh_name}")
async def generate_qr(user_id: str, wh_name: str):
    db = SessionLocal()
    try:
        query =  text("""
            SELECT wh_idx
            FROM tb_warehouse
            WHERE wh_branch_name = :wh_name
        """)
        result = db.execute(query, {"wh_name": wh_name}).fetchone()

        
        if not result:
            raise HTTPException(status_code=404, detail="Warehouse not found")

        wh_idx = result[0]


        reservation = db.query(Reservation).filter(
            Reservation.user_id == user_id,
            Reservation.wh_idx == wh_idx,
            Reservation.reserv_status == 'in_use',
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

       # print("이거는?", json.dumps(to_dict(qr_code_entry), indent=4, default=str))

        db.add(qr_code_entry)  # QR 코드 엔트리 추가
        a = reservation.reserv_idx
        db.commit()  # 데이터베이스에 저장
        db.refresh(qr_code_entry)  # 새로 생성된 엔티티를 새로고침

         # JSON 응답 반환
        return {
            "qr_code": img_base64,
            "reserv_idx": a,
            "message": "QR code generated successfully"
        }
    
    except Exception as e:
        print(f"Error: {e}")  # 오류 메시지를 콘솔에 출력
        raise HTTPException(status_code=500, detail="Internal Server Error")
    
    finally:
        db.close()

# 새로운 엔드포인트: 특정 조건에 맞으면 모델에 `user_id`와 `unit_idx`를 전송
@router.post("/send_to_model/{reserv_idx}")
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
       # response = requests.post(f"http://127.0.0.1:8000/send_to_model/{reserv_idx}", json=data)

        # 응답 검증
        #if response.status_code != 200:
        #    raise HTTPException(status_code=500, detail="Failed to send data to model")

        from model import user_info_queue
        user_info_queue.put(data)

        return {"message": "Data sent to model successfully"}
    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()

# QR isvalid=0 업데이트
@router.put("/invalidate_qr/{reserv_idx}")
async def invalidate_qr(reserv_idx: int):
    db = SessionLocal()
    try:
        # QR 코드의 유효성을 0으로 설정
        qr_code_entry = db.query(QRCode).filter(QRCode.reserv_idx == reserv_idx, QRCode.is_valid == 1).order_by(QRCode.created_at.desc()).first()  # 최신 순으로 정렬하여 첫 번째 항목 선택

       # print("qr",json.dumps(to_dict(qr_code_entry), indent=4, default=str))
       
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

@router.post("/detect_prod")
async def detect_prod(image_data: ImageData):
    try:
        if image_data:
            # BLOB 데이터를 numpy 배열로 변환
            image_bytes = base64.b64decode(image_data.image_data)
            image_array = np.frombuffer(image_bytes, dtype=np.uint8)
            image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
            
            # YOLO 모델로 객체 탐지 수행
            results = model(image)
            # results = model('Frontend/shareware/assets/cat.jpg')

            # 클래스 ID와 이름 매핑을 위한 딕셔너리 가져오기
            class_names = model.names
            
            # 탐지된 객체의 라벨 정보 수집
            detected_labels = []
            for result in results:
                for detection in result.boxes:
                    class_id = int(detection.cls)  # 클래스 ID 추출
                    label_name = class_names[class_id]  # 클래스 이름 가져오기
                    detected_labels.append(label_name)
            
            # 'cat' 또는 'dog'이 있는지 확인하고 메시지 출력
            if any(label in forbidden_lst for label in detected_labels):
                print("보관 부적격 물품이 있습니다")
            else:
                print("객체 탐지 종료")
    except:
        print("db에 파일 없음")



#if __name__ == "__main__":
#    import uvicorn
   # Base.metadata.drop_all(bind=engine)  # 기존 테이블 삭제
   # Base.metadata.create_all(bind=engine)  # 새 테이블 생성
#    uvicorn.run(app, host="0.0.0.0", port=8000)