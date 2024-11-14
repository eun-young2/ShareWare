# app.py

from fastapi import FastAPI
from main import router as main_router
from model import router as model_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS 설정 (필요하다면)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 포함
app.include_router(main_router)
app.include_router(model_router)

# 모델의 startup 이벤트 호출
@app.on_event("startup")
async def startup_event():
    await model_router.startup()