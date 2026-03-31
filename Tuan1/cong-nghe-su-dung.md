# Bản Mô Tả Công Nghệ Sử Dụng

## Tên ứng dụng: VocabApp — Học Từ Vựng Tiếng Anh

---

## 1. Tổng quan kiến trúc

Ứng dụng được xây dựng theo mô hình **Client - Server**:

```
Mobile App (Flutter)  ←→  REST API (Node.js)  ←→  Database (MySQL)
```

---

## 2. Frontend — Flutter

| Thông tin | Chi tiết |
|---|---|
| Ngôn ngữ | Dart |
| Framework | Flutter 3.x |
| Kiến trúc | Provider (State Management) |

### Các thư viện sử dụng

| Thư viện | Mục đích |
|---|---|
| `provider` | Quản lý trạng thái (state management) |
| `http` | Gọi REST API từ backend |
| `shared_preferences` | Lưu token JWT tại local |
| `flutter_tts` | Phát âm từ vựng (text-to-speech) |

### Lý do chọn Flutter
- Viết một lần, chạy được trên Android và iOS
- Hiệu năng cao, gần với native
- Hỗ trợ tốt trên VSCode
- Cộng đồng lớn, nhiều tài liệu

---

## 3. Backend — Node.js + Express.js

| Thông tin | Chi tiết |
|---|---|
| Ngôn ngữ | JavaScript (Node.js) |
| Framework | Express.js 4.x |
| Kiểu API | RESTful API |
| Xác thực | JWT (JSON Web Token) |

### Các thư viện sử dụng

| Thư viện | Mục đích |
|---|---|
| `express` | Xây dựng REST API |
| `mysql2` | Kết nối và truy vấn MySQL |
| `jsonwebtoken` | Tạo và xác thực JWT token |
| `bcryptjs` | Mã hóa mật khẩu người dùng |
| `cors` | Cho phép Flutter gọi API |
| `dotenv` | Quản lý biến môi trường |
| `nodemon` | Tự động restart server khi phát triển |

### Lý do chọn Node.js
- Nhẹ, nhanh, phù hợp với REST API
- Dễ học, cú pháp JavaScript quen thuộc
- Dễ tích hợp với các thư viện npm

---

## 4. Cơ sở dữ liệu — MySQL

| Thông tin | Chi tiết |
|---|---|
| Hệ quản trị CSDL | MySQL 8.x |
| Công cụ quản lý | MySQL Workbench |

### Các bảng chính

| Bảng | Mô tả |
|---|---|
| `users` | Thông tin người dùng |
| `topics` | Chủ đề từ vựng |
| `words` | Từ vựng (thuộc chủ đề) |
| `user_progress` | Tiến trình học của từng user |
| `quiz_results` | Kết quả quiz |
| `badges` | Danh sách huy hiệu |
| `user_badges` | Huy hiệu của từng user |

### Lý do chọn MySQL
- Phổ biến, dễ sử dụng
- Hỗ trợ tốt quan hệ giữa các bảng (khóa ngoại)
- Tích hợp tốt với Node.js qua thư viện mysql2

---

## 5. Công cụ phát triển

| Công cụ | Mục đích |
|---|---|
| Visual Studio Code | IDE lập trình chính |
| GitHub | Quản lý phiên bản source code |
| MySQL Workbench | Quản lý cơ sở dữ liệu |
| Thunder Client (VSCode) | Kiểm thử API |

---

## 6. Môi trường phát triển

| Thành phần | Phiên bản |
|---|---|
| Flutter SDK | 3.41.6 |
| Dart SDK | 3.11.4 |
| Node.js | >= 18.x |
| MySQL | 8.x |
| Hệ điều hành | Windows 11 |
