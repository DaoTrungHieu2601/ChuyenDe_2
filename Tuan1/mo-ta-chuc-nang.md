# Bản Mô Tả Chức Năng Ứng Dụng

## Tên ứng dụng: VocabApp — Học Từ Vựng Tiếng Anh

## Mục tiêu
Ứng dụng hỗ trợ người dùng học và ghi nhớ từ vựng Tiếng Anh thông qua các phương pháp học hiệu quả như Flashcard, Quiz trắc nghiệm, kết hợp hệ thống điểm thưởng để tạo động lực học tập.

---

## Các chức năng chính

### 1. Đăng ký / Đăng nhập
- Tạo tài khoản bằng username, email, mật khẩu
- Đăng nhập, đăng xuất
- Xác thực bằng JWT token

### 2. Học từ vựng theo chủ đề
- Hiển thị danh sách chủ đề (Động vật, Màu sắc, Gia đình, Thực phẩm...)
- Mỗi chủ đề gồm nhiều từ vựng kèm phiên âm, nghĩa, ví dụ
- Hiển thị tiến độ học (%) theo từng chủ đề

### 3. Flashcard
- Hiển thị từ mặt trước (Tiếng Anh + phiên âm)
- Lật thẻ xem nghĩa Tiếng Việt + ví dụ
- Đánh dấu "Đã thuộc" để lưu tiến trình

### 4. Quiz trắc nghiệm
- 4 đáp án lựa chọn (A, B, C, D)
- Hiển thị kết quả đúng/sai ngay sau khi trả lời
- Tính điểm và lưu kết quả sau khi hoàn thành

### 5. Lưu tiến độ học
- Theo dõi từ đang học / đã học
- Thống kê tổng số từ đã học, XP tích lũy

### 6. Hệ thống phần thưởng (XP & Huy hiệu)
- Nhận XP khi học từ mới (+10 XP/từ)
- Nhận XP khi hoàn thành quiz (+5 XP/câu đúng)
- Nhận XP bonus khi hoàn thành 100% chủ đề (+50 XP)
- 8 loại huy hiệu: Bước đầu tiên, Chăm chỉ, Siêu học viên, Thử thách đầu, Hoàn hảo, Chinh phục, Tích lũy 100 XP, Tích lũy 500 XP

### 7. Gợi ý lộ trình học
- Đề xuất chủ đề cần ôn lại nếu điểm quiz < 70%
- Gợi ý chủ đề tiếp theo khi hoàn thành chủ đề hiện tại
- Gợi ý bắt đầu chủ đề mới chưa học

---

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Frontend (Mobile App) | Flutter (Dart) |
| Backend (API Server) | Node.js + Express.js |
| Cơ sở dữ liệu | MySQL |
| Xác thực | JWT (JSON Web Token) |
| Kiểu API | RESTful API |

---

## Danh sách màn hình chính

| STT | Màn hình | Mô tả |
|---|---|---|
| 1 | Đăng nhập | Form đăng nhập với email và mật khẩu |
| 2 | Đăng ký | Form tạo tài khoản mới |
| 3 | Trang chủ | Thống kê học tập, danh sách chủ đề |
| 4 | Chi tiết chủ đề | Danh sách từ vựng, tiến độ, nút Flashcard/Quiz |
| 5 | Flashcard | Học từ bằng thẻ lật (mặt trước/sau) |
| 6 | Quiz | Trắc nghiệm 4 đáp án |
| 7 | Phần thưởng | Huy hiệu, XP, gợi ý lộ trình học |
