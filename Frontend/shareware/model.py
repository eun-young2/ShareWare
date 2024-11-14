# model.py

from fastapi import APIRouter
from pydantic import BaseModel
import threading
from queue import Queue
import cv2
from ultralytics import YOLO
import numpy as np
import time
import os

router = APIRouter()

# 사용자 정보를 저장할 큐
user_info_queue = Queue()

class UserInfo(BaseModel):
    user_id: int
    warehouse_id: int

# 사용자 정보를 받는 엔드포인트
@router.post("/receive_user_info")
def receive_user_info(user_info: UserInfo):
    user_info_queue.put(user_info.dict())
    print(f"Received user info: {user_info.dict()}")  # 사용자 정보 수신 시 출력
    return {"message": "User info received successfully"}

# 필요한 함수들을 전역 범위로 이동

def load_model(model_path="yolo11n.pt"):
    """YOLO 모델 로드"""
    return YOLO(model_path)

def calculate_polygon_center(polygon_coords):
    """다각형의 중심점을 계산하는 함수"""
    x_coords = [p[0] for p in polygon_coords]
    y_coords = [p[1] for p in polygon_coords]
    center_x = int(sum(x_coords) / len(x_coords))
    center_y = int(sum(y_coords) / len(y_coords))
    return (center_x, center_y)

def initialize_video_writer(video_save_path, filename, width, height):
    """비디오 라이터 초기화"""
    if not os.path.exists(video_save_path):
        os.makedirs(video_save_path)
    return cv2.VideoWriter(
        os.path.join(video_save_path, filename),
        cv2.VideoWriter_fourcc(*'MJPG'),
        10,
        (width, height)
    )

def run_model():
    # YOLO 모델 로드
    model = load_model("yolo11n.pt")

    # CCTV 스트림 URL 또는 IP 카메라 주소
    cctv_url = 'rtsp://sangbeom:lee5322984!@172.30.1.17:554/stream1'
    cap = cv2.VideoCapture(cctv_url)

    if not cap.isOpened():
        print("Error: Could not open CCTV stream.")
        return

    # 창고 위치 설정
    warehouse_targets = [
        {"wh_id": 1, "coords": [(150, 150), (180, 330), (320, 290), (310, 110)]},
        {"wh_id": 2, "coords": [(310, 110), (320, 290), (500, 240), (490, 70)]},
        {"wh_id": 3, "coords": [(490, 70), (500, 240), (620, 200), (610, 50)]},
        {"wh_id": 4, "coords": [(610, 50), (620, 200), (710, 180), (700, 50)]},
        {"wh_id": 5, "coords": [(360, 600), (700, 810), (950, 600), (620, 490)]},
        {"wh_id": 6, "coords": [(620, 490), (950, 600), (1190, 460), (860, 360)]},
        {"wh_id": 7, "coords": [(860, 360), (1190, 460), (1360, 360), (1150, 270)]},
        {"wh_id": 8, "coords": [(1150, 270), (1360, 360), (1500, 270), (1300, 200)]},
        {"wh_id": 9, "coords": [(1200, 1000), (1900, 1000), (1900, 900), (1450, 725)]},
        {"wh_id": 10, "coords": [(1450, 725), (1900, 900), (1900, 675), (1520, 600)]},
        {"wh_id": 11, "coords": [(1520, 600), (1900, 675), (1900, 550), (1610, 460)]},
        {"wh_id": 12, "coords": [(1610, 460), (1900, 550), (1900, 440), (1680, 375)]},
        {"wh_id": 13, "coords": [(1680, 375), (1900, 440), (1900, 350), (1720, 300)]},
    ]

    # 변수 초기화
    user_info_list = []
    user_targets = {}
    tracking_id_to_user_id = {}
    THEFT_DETECTION_THRESHOLD = 22  # 초
    start_time = {}
    video_writers = {}
    max_allowed_users = 0  # 초기값 0
    video_save_path = './recorded_videos/'

    while True:
        success, frame = cap.read()
        if not success:
            print("Error: No frame received from CCTV stream.")
            break

        # 사용자 정보 업데이트
        new_user_info = []
        while not user_info_queue.empty():
            new_user_info.append(user_info_queue.get())

        if new_user_info:
            user_info_list.extend(new_user_info)
            for user in new_user_info:
                warehouse_id = user["unit_idx"]
                warehouse_coords = next(
                    (w["coords"] for w in warehouse_targets if w["wh_id"] == warehouse_id),
                    None
                )
                if warehouse_coords:
                    user_targets[user["user_id"]] = warehouse_coords
                    print(f"User ID {user['user_id']} assigned to Warehouse ID {warehouse_id}")
            max_allowed_users = len(user_info_list)
            print(f"Total authorized users: {max_allowed_users}")

        # 프레임 처리
        process_frame(
            frame, model, user_targets, warehouse_targets,
            tracking_id_to_user_id, user_info_list.copy(),
            max_allowed_users, video_writers, start_time,
            THEFT_DETECTION_THRESHOLD, video_save_path
        )

    # 비디오 저장 종료
    for writer in video_writers.values():
        writer.release()
    cap.release()

def process_frame(
    frame, model, user_targets, warehouse_targets,
    tracking_id_to_user_id, user_info_list_copy, max_allowed_users,
    video_writers, start_time, THEFT_DETECTION_THRESHOLD, video_save_path
):
    """프레임을 처리하고 필요한 경우 영상을 저장"""
    # 사람(class 0)에 대한 트래킹 및 거리 계산 실행
    track_results = model.track(
        frame, classes=[0], persist=True, tracker="bytetrack.yaml"
    )
    if track_results and len(track_results[0].boxes) > 0:
        result = track_results[0]
        for track in result.boxes:
            box = track.xyxy[0]
            x1, y1, x2, y2 = map(int, box[:4])

            track_id = int(track.id.item()) if track.id is not None else 0

            # 사람 중심 좌표 계산
            person_center = ((x1 + x2) // 2, (y1 + y2) // 2)

            # 사용자 ID 매핑 및 Unauthorized 확인
            if len(tracking_id_to_user_id) >= max_allowed_users and \
               track_id not in tracking_id_to_user_id:
                assigned_user_id = "Unauthorized"
            else:
                assigned_user_id = tracking_id_to_user_id.get(track_id, None)
                if assigned_user_id is None:
                    if user_info_list_copy:
                        assigned_user = user_info_list_copy.pop(0)
                        assigned_user_id = assigned_user["user_id"]
                        tracking_id_to_user_id[track_id] = assigned_user_id
                        # print(f"Track ID {track_id} assigned to User ID {assigned_user_id}")
                    else:
                        assigned_user_id = "Unauthorized"

            # 색상 및 라벨 설정
            color = (0, 0, 255) if assigned_user_id == "Unauthorized" else (0, 255, 0)
            label_text = "Unauthorized" if assigned_user_id == "Unauthorized" else f"User ID: {assigned_user_id}"

            # Unauthorized 사용자 영상 저장
            if assigned_user_id == "Unauthorized":
                print(f"Unauthorized person detected: Track ID {track_id}")
                handle_unauthorized_person(
                    frame, track_id, x1, y1, x2, y2, color, label_text, video_writers,
                    start_time, video_save_path
                )
            else:
                print(f"Authorized person: User ID {assigned_user_id}, Track ID {track_id}")
                handle_authorized_person(
                    frame, track_id, assigned_user_id, person_center,
                    user_targets, start_time, video_writers,
                    THEFT_DETECTION_THRESHOLD, video_save_path, track,
                    x1, y1, x2, y2, color, label_text
                )
    else:
        print("No persons detected in the frame.")

def handle_unauthorized_person(
    frame, track_id, x1, y1, x2, y2, color, label_text, video_writers,
    start_time, video_save_path
):
    """미허가자에 대한 영상 저장 처리"""
    frame_height, frame_width = frame.shape[:2]
    # 프레임에 바운딩 박스와 라벨 그리기
    frame_with_box = frame.copy()
    cv2.rectangle(frame_with_box, (x1, y1), (x2, y2), color, 2)
    cv2.putText(frame_with_box, label_text, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

    if track_id not in video_writers:
        start_time[track_id] = time.time()
        start_time_str = time.strftime(
            "%Y%m%d_%H%M%S", time.localtime(start_time[track_id])
        )
        assigned_user_id_str = "Unknown"

        # VideoWriter 초기화
        video_filename = (
            f"unauthorized_{assigned_user_id_str}_{start_time_str}"
            f"_track_{track_id}.avi"
        )
        video_writers[track_id] = initialize_video_writer(
            video_save_path, video_filename, frame_width, frame_height
        )
        # print(f"Started recording for Unauthorized track_id {track_id}")

    # 프레임 저장
    if track_id in video_writers:
        video_writers[track_id].write(frame_with_box)

def handle_authorized_person(
    frame, track_id, assigned_user_id, person_center, user_targets,
    start_time, video_writers, THEFT_DETECTION_THRESHOLD,
    video_save_path, track, x1, y1, x2, y2, color, label_text
):
    """허가된 사용자에 대한 영상 저장 처리"""
    if assigned_user_id in user_targets:
        target_coords = calculate_polygon_center(
            user_targets[assigned_user_id]
        )
        distance = np.linalg.norm(
            np.array(person_center) - np.array(target_coords)
        )

        # 절도 의심 상황 처리
        if distance > 100:
            # 프레임에 바운딩 박스와 라벨 그리기
            frame_with_box = frame.copy()
            cv2.rectangle(frame_with_box, (x1, y1), (x2, y2), color, 2)
            cv2.putText(frame_with_box, label_text, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

            if track_id not in start_time:
                start_time[track_id] = time.time()
                # print(f"Theft suspicion started for User ID {assigned_user_id}, Track ID {track_id}")
            elif time.time() - start_time[track_id] > THEFT_DETECTION_THRESHOLD:
                frame_height, frame_width = frame.shape[:2]
                if track_id not in video_writers:
                    start_time_str = time.strftime(
                        "%Y%m%d_%H%M%S",
                        time.localtime(start_time[track_id])
                    )
                    assigned_user_id_str = str(assigned_user_id)

                    # VideoWriter 초기화
                    video_filename = (
                        f"theft_suspicion_user_{assigned_user_id_str}_"
                        f"{start_time_str}_track_{track_id}.avi"
                    )
                    video_writers[track_id] = initialize_video_writer(
                        video_save_path, video_filename,
                        frame_width, frame_height
                    )
                    # print(f"Started recording for User ID "
                        #   f"{assigned_user_id}, track_id {track_id}")

                # 프레임 저장
                if track_id in video_writers:
                    video_writers[track_id].write(frame_with_box)
        else:
            if track_id in start_time:
                del start_time[track_id]
                print(f"Theft suspicion cleared for User ID {assigned_user_id}, Track ID {track_id}")
            if track_id in video_writers:
                video_writers[track_id].release()
                del video_writers[track_id]
                # print(f"Stopped recording for User ID {assigned_user_id}, "
                #       f"track_id {track_id}")
    else:
        # 사용자 정보에 타겟 창고가 없을 경우 처리
        print(f"User ID {assigned_user_id} has no assigned warehouse target.")

# 앱 시작 시 모델 실행
@router.on_event("startup")
async def startup_event():
    threading.Thread(target=run_model, daemon=True).start()