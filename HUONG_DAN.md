# Hướng dẫn cài đặt và chạy VocabApp

## 1. Clone dự án về máy

```bash
git clone https://github.com/DaoTrungHieu2601/ChuyenDe_2.git
cd ChuyenDe_2
```

---

## 2. Cài đặt Backend (Node.js)

```bash
cd backend
npm install
```

### Tạo file .env trong thư mục backend/

Tạo file tên `.env` với nội dung sau (điền mật khẩu MySQL của bạn):copy hết đoạn trong ngoặc
tạo ở thư mục backend

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=mật_khẩu_mysql_của_bạn
DB_NAME=vocab_app

JWT_SECRET=vocabapp_secret_key_2024
JWT_EXPIRES_IN=7d

PORT=3001
```

### Tạo database trong MySQL

Mở MySQL và chạy file schema:

```bash
mysql -u root -p vocab_app < database/schema.sql
```

Hoặc mở MySQL Workbench, tạo database tên `vocab_app` rồi chạy file `database/schema.sql`.

### Chạy backend

```bash
npm run dev
```

> Server chạy tại: http://localhost:3001

---

## 3. Cài đặt Frontend (Flutter)

```bash
cd frontend
flutter pub get
```

### Chạy trên Chrome (web)

```bash
flutter run -d chrome
```

> Lưu ý: Backend phải đang chạy trước khi mở app.

---

## 4. Tạo nhánh riêng từ nhánh dev và đẩy code lên

### Bước 1 — Chuyển về nhánh dev và cập nhật code mới nhất

```bash
git checkout dev
git pull origin dev
```

### Bước 2 — Tạo nhánh mới từ dev

```bash
git checkout -b ten-nhanh-cua-ban
```

Ví dụ:

```bash
git checkout -b feature/rewards-screen
```

### Bước 3 — Thêm file và commit

```bash
git add .
git commit -m "mô tả những gì bạn đã làm"
```

Ví dụ:

```bash
git add frontend/lib/screens/rewards/
git commit -m "feat: hoàn thiện màn hình phần thưởng"
```

### Bước 4 — Đẩy nhánh lên GitHub

```bash
git push origin ten-nhanh-cua-ban
```

### Bước 5 — Báo lại để merge vào dev

Sau khi push xong, nhắn cho **ĐàoTrungHiieu2601** để merge nhánh vào `dev`.

---

## Cấu trúc dự án

```
ChuyenDe_2/
├── backend/
│   ├── src/
│   │   ├── app.js
│   │   ├── config/        ← kết nối database
│   │   ├── controllers/   ← xử lý logic
│   │   ├── middleware/    ← xác thực JWT
│   │   └── routes/        ← định nghĩa API
│   ├── database/
│   │   └── schema.sql     ← cấu trúc database
│   └── .env               ← cấu hình (tự tạo, không commit)
│
└── frontend/
    └── lib/
        ├── main.dart
        ├── data/           ← dữ liệu giả lập
        ├── services/       ← kết nối API
        └── screens/        ← các màn hình
            ├── auth/       ← đăng nhập, đăng ký
            ├── home/       ← trang chủ
            ├── topic/      ← chi tiết chủ đề
            ├── flashcard/  ← học flashcard
            ├── quiz/       ← kiểm tra
            └── rewards/    ← phần thưởng
```

---

## API Backend

| Method | Endpoint           | Mô tả                          |
| ------ | ------------------ | ------------------------------ |
| POST   | /api/auth/register | Đăng ký tài khoản              |
| POST   | /api/auth/login    | Đăng nhập                      |
| GET    | /api/auth/me       | Lấy thông tin user (cần token) |
