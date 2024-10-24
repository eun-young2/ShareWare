const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET_KEY; // JWT 서명에 사용할 비밀키

// JWT 토큰 검증 미들웨어
function verifyToken(req, res, next) {
    const token = req.headers['authorization']; // Authorization 헤더에서 토큰 추출

    if (!token) {
        return res.status(403).json({ message: '토큰이 제공되지 않았습니다.' });
    }

    try {
        const jwtToken = token.split(' ')[1]; // "Bearer {token}"에서 토큰만 추출
        const decoded = jwt.verify(jwtToken, secretKey); // 토큰 검증

        // 토큰이 유효하면 다음 미들웨어 또는 라우트로 진행
        req.user = decoded; // 토큰의 페이로드에 있는 사용자 정보를 요청에 추가
        next();
    } catch (error) {
        return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
}

module.exports = verifyToken;
