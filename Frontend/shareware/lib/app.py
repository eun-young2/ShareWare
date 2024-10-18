from flask import Flask, jsonify
from flask_cors import CORS
import qrcode
import io
import base64
from datetime import datetime

app = Flask(__name__)
CORS(app)

# QR 코드 생성 시각을 저장할 변수
qr_generated_time = None

@app.route('/generate_qr', methods=['GET'])
def generate_qr():
    global qr_generated_time

    # QR 코드가 처음 생성될 때만 시각을 저장
    if qr_generated_time is None:
        qr_generated_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # QR 코드 생성 (생성된 시각을 데이터로 사용)
    img = qrcode.make(qr_generated_time)
    
    # 이미지를 바이트로 변환
    buffered = io.BytesIO()
    img.save(buffered, format="PNG")
    img_str = base64.b64encode(buffered.getvalue()).decode()
    
    return jsonify({'qr_code': img_str, 'timestamp': qr_generated_time})

if __name__ == '__main__':
    app.run(debug=True)
