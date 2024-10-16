from flask import Flask, jsonify
from flask_cors import CORS
import qrcode
import io
import base64
from datetime import datetime

app = Flask(__name__)
CORS(app)

@app.route('/generate_qr', methods=['GET'])
def generate_qr():
    # 현재 시간 정보 생성
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # QR 코드 생성
    img = qrcode.make(current_time)
    
    # 이미지를 바이트로 변환
    buffered = io.BytesIO()
    img.save(buffered, format="PNG")
    img_str = base64.b64encode(buffered.getvalue()).decode()
    
    return jsonify({'qr_code': img_str, 'timestamp': current_time})

if __name__ == '__main__':
    app.run(debug=True)
