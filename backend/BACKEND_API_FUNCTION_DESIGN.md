<<<<<<< HEAD
# Thiết kế Backend (API/Function)

## 1) Mô tả danh sách API/Function chính

### 1.1 Các API chính

| STT | API | Mục đích sử dụng | Giao diện sử dụng |
|---|---|---|---|
| 1 | `POST /api/auth/register` | Đăng ký tài khoản mới | Màn hình Đăng ký |
| 2 | `POST /api/auth/login` | Đăng nhập, cấp JWT token | Màn hình Đăng nhập |
| 3 | `GET /api/auth/me` | Lấy thông tin người dùng hiện tại | Kiểm tra phiên đăng nhập, hồ sơ cơ bản |
| 4 | `GET /api/topics` | Lấy danh sách chủ đề kèm số lượng từ | `home_screen`, danh sách chủ đề |
| 5 | `GET /api/topics/:id` | Lấy chi tiết 1 chủ đề | Màn hình chi tiết chủ đề (nếu cần metadata) |
| 6 | `GET /api/words/topic/:topicId` | Lấy danh sách từ theo chủ đề | `topic_detail_screen`, `flashcard_screen`, `quiz_screen` |
| 7 | `GET /api/words/:id` | Lấy chi tiết 1 từ vựng | Màn hình chi tiết từ (mở rộng) |
| 8 | `GET /api/words/search?q=` | Tìm kiếm từ vựng theo Anh/Việt | Màn hình tìm kiếm |
| 9 | `POST /api/progress` | Lưu tiến trình học của 1 từ (learning/learned), tính XP | `flashcard_screen` |
| 10 | `GET /api/progress/topic/:topicId` | Lấy tiến trình user theo chủ đề | `topic_detail_screen` (hiển thị đã học/chưa học) |
| 11 | `POST /api/progress/quiz` | Lưu kết quả quiz, trao XP + badge | `quiz_screen` |
| 12 | `GET /api/progress/stats` | Lấy thống kê tổng quan học tập | `home_screen` |
| 13 | `GET /api/rewards/badges` | Lấy danh sách badge + trạng thái đạt được + XP | `rewards_screen` |
| 14 | `GET /api/rewards/learning-path` | Lấy đề xuất lộ trình học ưu tiên | `home_screen`, `rewards_screen` |

Ghi chú:
- Tất cả API trừ `register` và `login` đều yêu cầu header `Authorization: Bearer <token>`.
- Base URL hiện tại: `http://localhost:3000/api`.

### 1.2 Các function backend nội bộ (không expose trực tiếp)

| Function | Mục đích | Được gọi bởi |
|---|---|---|
| `awardXP(userId, xpAmount)` | Cộng XP cho user, sau đó trigger kiểm tra badge tự động | `saveProgress`, `saveQuizResult` |
| `checkAndAwardBadges(userId, currentXP)` | Kiểm tra điều kiện badge theo XP và số từ đã học | Nội bộ trong `awardXP` |
| `awardBadgeByCode(userId, code)` | Trao 1 badge theo mã code nếu tồn tại | `saveProgress`, `saveQuizResult`, `checkAndAwardBadges` |

---

## 2) Bản thiết kế chi tiết từng API/Function

## 2.1 Auth APIs

### API: Đăng ký
- URL: `POST /api/auth/register`
- Mục đích: Tạo tài khoản mới.
- Input (JSON):
  - `username` (string, bắt buộc)
  - `email` (string, bắt buộc, unique)
  - `password` (string, bắt buộc)
- Xử lý chính:
  1. Validate input không rỗng.
  2. Kiểm tra email đã tồn tại trong `users`.
  3. Hash password bằng bcrypt.
  4. Insert user mới.
- Output:
  - `201`: `{ "message": "Đăng ký thành công", "userId": number }`
  - `400`: Thiếu thông tin
  - `409`: Email đã được sử dụng
  - `500`: Lỗi server
=======
# Thiet ke Backend (API/Function) - Du an Vocab App

## 1) Mo ta danh sach API/Function chinh

### 1.1 Cac API chinh

| STT | API | Muc dich su dung | Giao dien su dung |
|---|---|---|---|
| 1 | `POST /api/auth/register` | Dang ky tai khoan moi | Man hinh Dang ky |
| 2 | `POST /api/auth/login` | Dang nhap, cap JWT token | Man hinh Dang nhap |
| 3 | `GET /api/auth/me` | Lay thong tin nguoi dung hien tai | Kiem tra phien dang nhap, ho so co ban |
| 4 | `GET /api/topics` | Lay danh sach chu de kem so luong tu | `home_screen`, danh sach chu de |
| 5 | `GET /api/topics/:id` | Lay chi tiet 1 chu de | Man hinh chi tiet chu de (neu can metadata) |
| 6 | `GET /api/words/topic/:topicId` | Lay danh sach tu theo chu de | `topic_detail_screen`, `flashcard_screen`, `quiz_screen` |
| 7 | `GET /api/words/:id` | Lay chi tiet 1 tu vung | Man hinh chi tiet tu (mo rong) |
| 8 | `GET /api/words/search?q=` | Tim kiem tu vung theo Anh/Viet | Man hinh tim kiem |
| 9 | `POST /api/progress` | Luu tien trinh hoc cua 1 tu (learning/learned), tinh XP | `flashcard_screen` |
| 10 | `GET /api/progress/topic/:topicId` | Lay tien trinh user theo chu de | `topic_detail_screen` (hien thi da hoc/chua hoc) |
| 11 | `POST /api/progress/quiz` | Luu ket qua quiz, trao XP + badge | `quiz_screen` |
| 12 | `GET /api/progress/stats` | Lay thong ke tong quan hoc tap | `home_screen` |
| 13 | `GET /api/rewards/badges` | Lay danh sach badge + trang thai dat duoc + XP | `rewards_screen` |
| 14 | `GET /api/rewards/learning-path` | Lay de xuat lo trinh hoc uu tien | `home_screen`, `rewards_screen` |

Ghi chu:
- Tat ca API tru `register` va `login` deu yeu cau header `Authorization: Bearer <token>`.
- Base URL hien tai: `http://localhost:3000/api`.

### 1.2 Cac function backend noi bo (khong expose truc tiep)

| Function | Muc dich | Duoc goi boi |
|---|---|---|
| `awardXP(userId, xpAmount)` | Cong XP cho user, sau do trigger kiem tra badge tu dong | `saveProgress`, `saveQuizResult` |
| `checkAndAwardBadges(userId, currentXP)` | Kiem tra dieu kien badge theo XP va so tu da hoc | Noi bo trong `awardXP` |
| `awardBadgeByCode(userId, code)` | Trao 1 badge theo ma code neu ton tai | `saveProgress`, `saveQuizResult`, `checkAndAwardBadges` |

---

## 2) Ban thiet ke chi tiet tung API/Function

## 2.1 Auth APIs

### API: Dang ky
- URL: `POST /api/auth/register`
- Muc dich: Tao tai khoan moi.
- Input (JSON):
  - `username` (string, bat buoc)
  - `email` (string, bat buoc, unique)
  - `password` (string, bat buoc)
- Xu ly chinh:
  1. Validate input khong rong.
  2. Kiem tra email da ton tai trong `users`.
  3. Hash password bang bcrypt.
  4. Insert user moi.
- Output:
  - `201`: `{ "message": "Dang ky thanh cong", "userId": number }`
  - `400`: Thieu thong tin
  - `409`: Email da duoc su dung
  - `500`: Loi server
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Database:
  - Read: `users(email)`
  - Write: `users(username, email, password)`

<<<<<<< HEAD
### API: Đăng nhập
- URL: `POST /api/auth/login`
- Mục đích: Xác thực user và cấp JWT.
- Input (JSON):
  - `email` (string, bắt buộc)
  - `password` (string, bắt buộc)
- Xử lý chính:
  1. Tìm user theo email.
  2. So khớp password hash.
  3. Tạo JWT chứa `{id, email, username}`.
=======
### API: Dang nhap
- URL: `POST /api/auth/login`
- Muc dich: Xac thuc user va cap JWT.
- Input (JSON):
  - `email` (string, bat buoc)
  - `password` (string, bat buoc)
- Xu ly chinh:
  1. Tim user theo email.
  2. So khop password hash.
  3. Tao JWT chua `{id, email, username}`.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Output:
  - `200`: 
    - `message`
    - `token`
    - `user { id, username, email }`
<<<<<<< HEAD
  - `400`: Thiếu thông tin
  - `401`: Sai thông tin đăng nhập
  - `500`: Lỗi server
- Database:
  - Read: `users(*)`
  - Write: không

### API: Lấy thông tin người dùng đang đăng nhập
- URL: `GET /api/auth/me`
- Auth: Bắt buộc JWT.
- Mục đích: Trả về thông tin profile cơ bản.
=======
  - `400`: Thieu thong tin
  - `401`: Sai thong tin dang nhap
  - `500`: Loi server
- Database:
  - Read: `users(*)`
  - Write: khong

### API: Lay thong tin nguoi dung dang dang nhap
- URL: `GET /api/auth/me`
- Auth: Bat buoc JWT.
- Muc dich: Tra ve thong tin profile co ban.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Input:
  - Header: `Authorization: Bearer <token>`
- Output:
  - `200`: `{ id, username, email, created_at }`
<<<<<<< HEAD
  - `404`: Không tìm thấy user
  - `401/403`: Token lỗi/hết hạn
  - `500`: Lỗi server
- Database:
  - Read: `users(id, username, email, created_at)`
  - Write: không

## 2.2 Topic APIs

### API: Lấy tất cả chủ đề
- URL: `GET /api/topics`
- Auth: Bắt buộc JWT.
- Mục đích: Hiện danh sách chủ đề và tổng số từ từng chủ đề.
- Input: chỉ cần token.
- Output:
  - `200`: Mảng các topic:
    - thông tin từ `topics.*`
    - `word_count` (số từ trong chủ đề)
  - `500`: Lỗi server
- Database:
  - Read: `topics`, `words` (LEFT JOIN + GROUP BY)
  - Write: không

### API: Lấy chi tiết 1 chủ đề
- URL: `GET /api/topics/:id`
- Auth: Bắt buộc JWT.
- Mục đích: Lấy metadata của chủ đề.
=======
  - `404`: Khong tim thay user
  - `401/403`: Token loi/het han
  - `500`: Loi server
- Database:
  - Read: `users(id, username, email, created_at)`
  - Write: khong

## 2.2 Topic APIs

### API: Lay tat ca chu de
- URL: `GET /api/topics`
- Auth: Bat buoc JWT.
- Muc dich: Hien danh sach chu de va tong so tu tung chu de.
- Input: chi can token.
- Output:
  - `200`: Mang cac topic:
    - thong tin tu `topics.*`
    - `word_count` (so tu trong chu de)
  - `500`: Loi server
- Database:
  - Read: `topics`, `words` (LEFT JOIN + GROUP BY)
  - Write: khong

### API: Lay chi tiet 1 chu de
- URL: `GET /api/topics/:id`
- Auth: Bat buoc JWT.
- Muc dich: Lay metadata cua chu de.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Input:
  - Path param: `id` (int)
- Output:
  - `200`: Topic object
<<<<<<< HEAD
  - `404`: Không tìm thấy chủ đề
  - `500`: Lỗi server
- Database:
  - Read: `topics` theo `id`
  - Write: không

## 2.3 Word APIs

### API: Lấy danh sách từ theo chủ đề
- URL: `GET /api/words/topic/:topicId`
- Auth: Bắt buộc JWT.
- Mục đích: Cấp dữ liệu cho học flashcard và quiz theo chủ đề.
- Input:
  - Path param: `topicId` (int)
- Output:
  - `200`: Mảng `words[]` sắp xếp theo `english`
  - `500`: Lỗi server
- Database:
  - Read: `words` theo `topic_id`
  - Write: không

### API: Lấy chi tiết 1 từ vựng
- URL: `GET /api/words/:id`
- Auth: Bắt buộc JWT.
- Mục đích: Lấy đầy đủ thông tin 1 từ.
=======
  - `404`: Khong tim thay chu de
  - `500`: Loi server
- Database:
  - Read: `topics` theo `id`
  - Write: khong

## 2.3 Word APIs

### API: Lay danh sach tu theo chu de
- URL: `GET /api/words/topic/:topicId`
- Auth: Bat buoc JWT.
- Muc dich: Cap du lieu cho hoc flashcard va quiz theo chu de.
- Input:
  - Path param: `topicId` (int)
- Output:
  - `200`: Mang `words[]` sap xep theo `english`
  - `500`: Loi server
- Database:
  - Read: `words` theo `topic_id`
  - Write: khong

### API: Lay chi tiet 1 tu vung
- URL: `GET /api/words/:id`
- Auth: Bat buoc JWT.
- Muc dich: Lay day du thong tin 1 tu.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Input:
  - Path param: `id` (int)
- Output:
  - `200`: Word object
<<<<<<< HEAD
  - `404`: Không tìm thấy từ
  - `500`: Lỗi server
- Database:
  - Read: `words` theo `id`
  - Write: không

### API: Tìm kiếm từ vựng
- URL: `GET /api/words/search?q=<keyword>`
- Auth: Bắt buộc JWT.
- Mục đích: Tìm theo `english` hoặc `vietnamese`.
- Input:
  - Query: `q` (string)
- Output:
  - `200`: Mảng kết quả tối đa 20 phần tử; nếu `q` rỗng trả `[]`
  - `500`: Lỗi server
- Database:
  - Read: `words` với `LIKE` trên cột `english`, `vietnamese`
  - Write: không

## 2.4 Progress APIs

### API: Lưu tiến trình học từ
- URL: `POST /api/progress`
- Auth: Bắt buộc JWT.
- Mục đích: Lưu trạng thái học từ; nếu từ chuyển sang `learned` thì cộng XP và có thể thưởng thêm.
- Input (JSON):
  - `word_id` (int, bắt buộc)
  - `status` (enum: `learning` | `learned`, bắt buộc)
- Xử lý chính:
  1. Kiểm tra bản ghi cũ trong `user_progress`.
  2. Upsert `user_progress` theo cặp `(user_id, word_id)`.
  3. Nếu là transition mới sang `learned`:
     - Cộng `+10 XP`.
     - Kiểm tra topic đã học 100% chưa:
       - Nếu rồi: cộng thêm `+50 XP`, trao badge `topic_done`.
- Output:
  - `200`: `{ "message": "Đã lưu tiến trình", "xp_earned": number }`
  - `400`: Thiếu thông tin
  - `500`: Lỗi server
- Database:
  - Read: `user_progress`, `words`, `topics` (đếm), `users` (qua function XP)
  - Write:
    - `user_progress` (insert/update)
    - `users.xp` (update qua `awardXP`)
    - `user_badges` (có thể insert qua `awardBadgeByCode`)

### API: Lấy tiến trình theo chủ đề
- URL: `GET /api/progress/topic/:topicId`
- Auth: Bắt buộc JWT.
- Mục đích: Lấy danh sách từ user đã học/đang học trong 1 chủ đề.
- Input:
  - Path param: `topicId` (int)
- Output:
  - `200`: Mảng `{ word_id, status, learned_at }`
  - `500`: Lỗi server
- Database:
  - Read: `user_progress` JOIN `words`
  - Write: không

### API: Lưu kết quả quiz
- URL: `POST /api/progress/quiz`
- Auth: Bắt buộc JWT.
- Mục đích: Lưu điểm quiz, cộng XP theo điểm và trao badge liên quan.
=======
  - `404`: Khong tim thay tu
  - `500`: Loi server
- Database:
  - Read: `words` theo `id`
  - Write: khong

### API: Tim kiem tu vung
- URL: `GET /api/words/search?q=<keyword>`
- Auth: Bat buoc JWT.
- Muc dich: Tim theo `english` hoac `vietnamese`.
- Input:
  - Query: `q` (string)
- Output:
  - `200`: Mang ket qua toi da 20 phan tu; neu `q` rong tra `[]`
  - `500`: Loi server
- Database:
  - Read: `words` voi `LIKE` tren cot `english`, `vietnamese`
  - Write: khong

## 2.4 Progress APIs

### API: Luu tien trinh hoc tu
- URL: `POST /api/progress`
- Auth: Bat buoc JWT.
- Muc dich: Luu trang thai hoc tu; neu tu chuyen sang `learned` thi cong XP va co the thuong them.
- Input (JSON):
  - `word_id` (int, bat buoc)
  - `status` (enum: `learning` | `learned`, bat buoc)
- Xu ly chinh:
  1. Kiem tra ban ghi cu trong `user_progress`.
  2. Upsert `user_progress` theo cap `(user_id, word_id)`.
  3. Neu la transition moi sang `learned`:
     - Cong `+10 XP`.
     - Kiem tra topic da hoc 100% chua:
       - Neu roi: cong them `+50 XP`, trao badge `topic_done`.
- Output:
  - `200`: `{ "message": "Da luu tien trinh", "xp_earned": number }`
  - `400`: Thieu thong tin
  - `500`: Loi server
- Database:
  - Read: `user_progress`, `words`, `topics` (dem), `users` (qua function XP)
  - Write:
    - `user_progress` (insert/update)
    - `users.xp` (update qua `awardXP`)
    - `user_badges` (co the insert qua `awardBadgeByCode`)

### API: Lay tien trinh theo chu de
- URL: `GET /api/progress/topic/:topicId`
- Auth: Bat buoc JWT.
- Muc dich: Lay danh sach tu user da hoc/ dang hoc trong 1 chu de.
- Input:
  - Path param: `topicId` (int)
- Output:
  - `200`: Mang `{ word_id, status, learned_at }`
  - `500`: Loi server
- Database:
  - Read: `user_progress` JOIN `words`
  - Write: khong

### API: Luu ket qua quiz
- URL: `POST /api/progress/quiz`
- Auth: Bat buoc JWT.
- Muc dich: Luu diem quiz, cong XP theo diem va trao badge lien quan.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Input (JSON):
  - `topic_id` (int)
  - `score` (int)
  - `total` (int)
<<<<<<< HEAD
- Xử lý chính:
  1. Insert vào `quiz_results`.
  2. Tính `xp_earned = score * 5`, cộng XP.
  3. Trao badge `first_quiz`.
  4. Nếu điểm tuyệt đối (`score === total`) trao `perfect_quiz`.
- Output:
  - `200`: `{ "message": "Đã lưu kết quả quiz", "xp_earned": number }`
  - `500`: Lỗi server
=======
- Xu ly chinh:
  1. Insert vao `quiz_results`.
  2. Tinh `xp_earned = score * 5`, cong XP.
  3. Trao badge `first_quiz`.
  4. Neu diem tuyet doi (`score === total`) trao `perfect_quiz`.
- Output:
  - `200`: `{ "message": "Da luu ket qua quiz", "xp_earned": number }`
  - `500`: Loi server
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Database:
  - Read: `badges`, `users` (qua function XP)
  - Write: `quiz_results`, `users.xp`, `user_badges`

<<<<<<< HEAD
### API: Lấy thống kê tổng quan
- URL: `GET /api/progress/stats`
- Auth: Bắt buộc JWT.
- Mục đích: Tổng hợp chỉ số học tập cho dashboard.
- Input: chỉ cần token.
=======
### API: Lay thong ke tong quan
- URL: `GET /api/progress/stats`
- Auth: Bat buoc JWT.
- Muc dich: Tong hop chi so hoc tap cho dashboard.
- Input: chi can token.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Output:
  - `200`:
    - `total_learned`
    - `total_learning`
    - `xp`
<<<<<<< HEAD
    - `quiz_history` (10 lần quiz gần nhất, kèm `topic_name`)
  - `500`: Lỗi server
- Database:
  - Read: `user_progress`, `users`, `quiz_results`, `topics`
  - Write: không

## 2.5 Reward APIs

### API: Lấy danh sách badge của user
- URL: `GET /api/rewards/badges`
- Auth: Bắt buộc JWT.
- Mục đích: Hiển thị tất cả badge và trạng thái đạt/chưa đạt.
- Input: chỉ cần token.
- Output:
  - `200`:
    - `xp`: XP hiện tại
    - `badges[]`: thông tin badge + `earned` + `earned_at`
  - `500`: Lỗi server
- Database:
  - Read: `badges`, `user_badges`, `users`
  - Write: không

### API: Lấy gợi ý lộ trình học
- URL: `GET /api/rewards/learning-path`
- Auth: Bắt buộc JWT.
- Mục đích: Gợi ý tối đa 5 hành động học tập ưu tiên theo tiến độ và kết quả quiz.
- Input: chỉ cần token.
- Output:
  - `200`: Mảng suggestions (tối đa 5), mỗi phần tử gồm:
    - `type` (`start` | `continue` | `review`)
    - `topic_id`, `topic_name`
    - `message`
    - `priority` (1 là ưu tiên cao)
  - `500`: Lỗi server
- Database:
  - Read: `topics`, `words`, `user_progress`, `quiz_results`
  - Write: không

## 2.6 Function nội bộ chi tiết

### Function: `awardXP(userId, xpAmount)`
- Mục đích: Cộng XP cho user và kích hoạt kiểm tra badge.
- Input:
  - `userId` (int)
  - `xpAmount` (int)
- Output: không trả trực tiếp (Promise); thay đổi trạng thái DB.
- Database:
  - Write: `users.xp = xp + xpAmount`
  - Read: `users.xp` hiện tại
  - Gọi tiếp: `checkAndAwardBadges(userId, currentXP)`

### Function: `checkAndAwardBadges(userId, currentXP)`
- Mục đích: Trao badge theo mốc XP và theo số từ đã học.
=======
    - `quiz_history` (10 lan quiz gan nhat, kem `topic_name`)
  - `500`: Loi server
- Database:
  - Read: `user_progress`, `users`, `quiz_results`, `topics`
  - Write: khong

## 2.5 Reward APIs

### API: Lay danh sach badge cua user
- URL: `GET /api/rewards/badges`
- Auth: Bat buoc JWT.
- Muc dich: Hien thi tat ca badge va trang thai dat/chua dat.
- Input: chi can token.
- Output:
  - `200`:
    - `xp`: XP hien tai
    - `badges[]`: thong tin badge + `earned` + `earned_at`
  - `500`: Loi server
- Database:
  - Read: `badges`, `user_badges`, `users`
  - Write: khong

### API: Lay goi y lo trinh hoc
- URL: `GET /api/rewards/learning-path`
- Auth: Bat buoc JWT.
- Muc dich: Goi y toi da 5 hanh dong hoc tap uu tien theo tien do va ket qua quiz.
- Input: chi can token.
- Output:
  - `200`: Mang suggestions (toi da 5), moi phan tu gom:
    - `type` (`start` | `continue` | `review`)
    - `topic_id`, `topic_name`
    - `message`
    - `priority` (1 la uu tien cao)
  - `500`: Loi server
- Database:
  - Read: `topics`, `words`, `user_progress`, `quiz_results`
  - Write: khong

## 2.6 Function noi bo chi tiet

### Function: `awardXP(userId, xpAmount)`
- Muc dich: Cong XP cho user va kich hoat kiem tra badge.
- Input:
  - `userId` (int)
  - `xpAmount` (int)
- Output: khong tra truc tiep (Promise); thay doi trang thai DB.
- Database:
  - Write: `users.xp = xp + xpAmount`
  - Read: `users.xp` hien tai
  - Goi tiep: `checkAndAwardBadges(userId, currentXP)`

### Function: `checkAndAwardBadges(userId, currentXP)`
- Muc dich: Trao badge theo moc XP va theo so tu da hoc.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Input:
  - `userId` (int)
  - `currentXP` (int)
- Rule:
  - XP badge: `xp_100`, `xp_500`
<<<<<<< HEAD
  - Số từ đã học:
=======
  - So tu da hoc:
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
    - `>= 1`: `first_word`
    - `>= 10`: `ten_words`
    - `>= 50`: `fifty_words`
- Database:
  - Read: `badges`, `user_progress`
  - Write: `user_badges` (`INSERT IGNORE`)

### Function: `awardBadgeByCode(userId, code)`
<<<<<<< HEAD
- Mục đích: Trao badge theo mã.
- Input:
  - `userId` (int)
  - `code` (string)
- Output: không trả trực tiếp.
=======
- Muc dich: Trao badge theo ma.
- Input:
  - `userId` (int)
  - `code` (string)
- Output: khong tra truc tiep.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- Database:
  - Read: `badges` theo `code`
  - Write: `user_badges` (`INSERT IGNORE`)

---

<<<<<<< HEAD
## 3) Mô hình database liên quan đến API

Bảng chính:
- `users`: lưu thông tin tài khoản và XP.
- `topics`: chủ đề học.
- `words`: từ vựng thuộc chủ đề.
- `user_progress`: trạng thái học từng từ theo user.
- `quiz_results`: lịch sử kết quả quiz.
- `badges`: định nghĩa huy hiệu.
- `user_badges`: huy hiệu user đã đạt.

Quan hệ:
=======
## 3) Mo hinh database lien quan den API

Bang chinh:
- `users`: luu thong tin tai khoan va XP.
- `topics`: chu de hoc.
- `words`: tu vung thuoc chu de.
- `user_progress`: trang thai hoc tung tu theo user.
- `quiz_results`: lich su ket qua quiz.
- `badges`: dinh nghia huy hieu.
- `user_badges`: huy hieu user da dat.

Quan he:
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
- `topics (1) - (n) words`
- `users (1) - (n) user_progress`
- `words (1) - (n) user_progress`
- `users (1) - (n) quiz_results`
- `topics (1) - (n) quiz_results`
- `users (n) - (n) badges` qua `user_badges`

<<<<<<< HEAD
## 4) Ghi chú triển khai

- Token được ký bằng `JWT_SECRET`, hạn sử dụng theo `JWT_EXPIRES_IN` (mặc định `7d`).
- Trạng thái tiến trình được quản lý bằng enum: `learning`, `learned`.
- Nên bổ sung validation nâng cao (email format, độ mạnh mật khẩu, check range score/total).
- Nên bổ sung transaction cho các xử lý phát sinh nhiều thao tác DB (progress/quiz + reward) để đảm bảo tính nhất quán.
=======
## 4) Ghi chu trien khai

- Token duoc ky bang `JWT_SECRET`, han su dung theo `JWT_EXPIRES_IN` (mac dinh `7d`).
- Trang thai tien trinh duoc quan ly bang enum: `learning`, `learned`.
- Nen bo sung validation nang cao (email format, do manh mat khau, check range score/total).
- Nen bo sung transaction cho cac xu ly phat sinh nhieu thao tac DB (progress/quiz + reward) de dam bao tinh nhat quan.
>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
