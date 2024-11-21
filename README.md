# 📎 ShareWare(팀명: 오은형과 금쪽이들)

![캡처](https://github.com/user-attachments/assets/5c134c81-1539-460e-86fb-3ec4d08b452d)




## 👀 서비스 소개
* 서비스명: 비전 AI기반 공유형 창고 관리 서비스
* 서비스설명: 반려 동물의 증상 검색으로 간단한 결과 출력 후 필요시 플랫폼에 등록된 업체중 사용자 정보를 기반으로 추천 후 채팅 상담 연결
<br>

## 📅 프로젝트 기간
2024.10.14 ~ 2024.11.24 (약6주)
<br>

## ⭐ 주요 기능
* DB에 저장된 증상 데이터 기반 검색 결과 출력
* 검색 결과 출력 후 필요시 머신러닝 통한 전문 업체 추천
* 추천된 업체와 혹은 일반 유저 간 채팅 기능
* LLM 사용한 챗봇기능
* 유저간 소통을 위한 커뮤니티
<br>

## ⛏ 기술스택
<table>
    <tr>
        <th>구분</th>
        <th>내용</th>
    </tr>
    <tr>
        <td>사용언어</td>
        <td>
            <img src="https://github.com/user-attachments/assets/e5d0cd5b-a7bd-4760-9944-948996e7e7b4"/>
            <img src="https://github.com/user-attachments/assets/4efa8058-5370-4359-b79c-2a22330e5480"/>
            <img src="https://github.com/user-attachments/assets/8a4666f4-06a1-481b-ad5e-ece365299a44"/>
        </td>
    </tr>
    <tr>
        <td>라이브러리</td>
        <td>
            <img src="https://github.com/user-attachments/assets/c912d3ac-e680-497d-bfe2-937a41622f94"/>
            <img src="https://github.com/user-attachments/assets/a81a90e4-e297-4679-9499-284d1786600b"/>
            <img src="https://github.com/user-attachments/assets/607addd2-d19a-421e-8153-c6281586e5b2"/>
            <img src="https://github.com/user-attachments/assets/e8b6a4d3-c0f4-43a9-b9d4-f6be972b3577"/>
        </td>
    </tr>
    <tr>
        <td>개발도구</td>
        <td>
            <img src="https://github.com/user-attachments/assets/222a7ff6-ef9e-40d0-887b-3069f4863293"/>
        </td>
    </tr>
    <tr>
        <td>서버환경</td>
        <td>
            <img src="https://github.com/user-attachments/assets/79bf1dba-0691-491a-8246-40dda8e2c501"/>
            <img src="https://github.com/user-attachments/assets/6c9c8a89-c293-47d7-bb20-63ff873789ba"/>
        </td>
    </tr>
    <tr>
        <td>데이터베이스</td>
        <td>
            <img src="https://github.com/user-attachments/assets/5d632ad8-f5fc-4427-a0ff-d2c9264c3032"/>
        </td>
    </tr>
    <tr>
        <td>협업도구</td>
        <td>
            <img src="https://github.com/user-attachments/assets/e66c2905-e86e-4ed3-9e91-7a83ea450472"/>
            <img src="https://github.com/user-attachments/assets/bab3474b-4f6c-40f8-bc92-9fc2e36c6268"/>
        </td>
    </tr>
</table>


<br>

## ⚙ 시스템 아키텍처(구조) 예시 
![image](https://github.com/user-attachments/assets/45dc3618-44a4-4a6b-bd68-eaad1dd8d789)


<br>

## 📌 SW유스케이스
![image](https://github.com/user-attachments/assets/71ebe37b-4ea2-45ac-8860-d61992224a6a)



<br>

## 📌 서비스 흐름도
![image](https://github.com/user-attachments/assets/1d71bfdc-7ad3-428e-8c6e-25529b7693ae)



<br>

## 📌 ER다이어그램
![image](https://github.com/user-attachments/assets/3ca7b750-475f-4ec6-90f7-785b5554d554)


<br>

## 🖥 화면 구성

### 메인/사용자 로그인/관리자 로그인/회원가입
![image](https://github.com/user-attachments/assets/7acfa613-79c3-4dca-bded-97874229c50c)




<br>

### 창고 검색/창고 정보/창고 예약/창고 결제
![image](https://github.com/user-attachments/assets/f640d2c5-b28d-4bd0-8a3a-7e3d1253a367)




<br>

### QR 발급/마이 창고/물품등록/마이 페이지
![image](https://github.com/user-attachments/assets/f44f9531-7662-49bc-bf4e-be362b959831)





<br>

### 관리자메인/CCTV/ 출입 및 알림 리스트 / 예약자 관리
![image](https://github.com/user-attachments/assets/4e6ed578-bb5a-4f88-b901-94b1ffe8a158)







<br>

## 👨‍👩‍👦‍👦 팀원 역할
![image](https://github.com/user-attachments/assets/b8c2ee69-9b16-4d7d-bc8b-8bf53c284bfb)


## 💡 트러블슈팅
  
* 문제1<br>
 fastAPI를 이용한 모델과 Node.js 서버를 연결하는 과정에서 오류 발생. 원인을 파악해보니 노드 서버에서 사용하는 axios의 baseURL 설정과 fastAPI 서버의 URL이 일치하지 않아 발생하는 문제였다.<br>
 ![image](https://github.com/user-attachments/assets/45bb94ac-7520-44fb-b5c5-33aac3cae7da)

<br>

* 해결1<br>
 모델을 요청할 때 fastAPI 서버로 이동하는 URL을 따로 설정해주었다.<br>
 ![image](https://github.com/user-attachments/assets/f10088df-03d3-43d7-accb-e33102925ced)

<br><br>

* 문제2<br>
  Socket.IO를 이용한 실시간 채팅 기능 구현 중 상대방이 보낸 메세지를 실시간으로 띄울 수 없는 문제 발생. 서버에서 이전 대화를 불러올 때의 데이터 형식과 채팅을 주고 받을 때의 데이터 형식이 일치하지 않아서 발생하는 문제였다.<br>
  ![image](https://github.com/user-attachments/assets/dfcd53cf-0213-4dcc-a928-8a5c84786ed8)

<br>

* 해결2<br>
  서버의 chatRouter에서 메세지를 전송할 때, 서버에서 불러오는 데이터 형식과 동일하게 전송할 수 있도록 포맷팅 해주었다.
  ![image](https://github.com/user-attachments/assets/bfe0732e-f4b4-47bf-b3ee-5aec2ee7ace3)

