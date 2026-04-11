# Cấu trúc cơ sở dữ liệu — vocab_app

Tài liệu mô tả các bảng của ứng dụng học từ vựng. Nguồn chính: `schema.sql`, `update_rewards.sql`, và bảng tạo khi chạy backend (`seedBadges.js`).

---

## Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| Tên database | `vocab_app` |
| Charset | `utf8mb4` |
| Collation | `utf8mb4_unicode_ci` |

---

## 1. Bảng `users` — Người dùng

Lưu tài khoản đăng ký/đăng nhập và điểm XP tích lũy.

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Định danh user |
| `username` | `VARCHAR(100)` | `NOT NULL` | Tên hiển thị |
| `email` | `VARCHAR(150)` | `NOT NULL`, `UNIQUE` | Email đăng nhập |
| `password` | `VARCHAR(255)` | `NOT NULL` | Mật khẩu (đã hash) |
| `xp` | `INT` | mặc định `0` | Điểm kinh nghiệm |
| `created_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Thời điểm tạo tài khoản |

**Được tham chiếu bởi:** `user_progress.user_id`, `quiz_results.user_id`, `user_badges.user_id` (xóa user thì xóa theo `ON DELETE CASCADE`).

---

## 2. Bảng `topics` — Chủ đề từ vựng

Nhóm từ theo chủ đề (Động vật, Màu sắc, …).

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Định danh chủ đề |
| `name` | `VARCHAR(100)` | `NOT NULL` | Tên chủ đề |
| `description` | `TEXT` | nullable | Mô tả ngắn |
| `image_url` | `VARCHAR(255)` | nullable | Ảnh đại diện chủ đề (nếu có) |
| `created_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Thời điểm tạo |

**Quan hệ:** Một chủ đề có nhiều `words`. Được tham chiếu bởi `words.topic_id`, `quiz_results.topic_id`.

---

## 3. Bảng `words` — Từ vựng

Từng mục từ thuộc một chủ đề.

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Định danh từ |
| `topic_id` | `INT` | `NOT NULL`, `FK → topics(id)` | Thuộc chủ đề |
| `english` | `VARCHAR(100)` | `NOT NULL` | Từ tiếng Anh |
| `vietnamese` | `VARCHAR(200)` | `NOT NULL` | Nghĩa tiếng Việt |
| `pronunciation` | `VARCHAR(100)` | nullable | Phiên âm IPA |
| `example_en` | `TEXT` | nullable | Câu ví dụ tiếng Anh |
| `example_vi` | `TEXT` | nullable | Câu ví dụ tiếng Việt |
| `image_url` | `VARCHAR(255)` | nullable | Đường dẫn ảnh minh họa |
| `created_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Thời điểm tạo |

**Khóa ngoại:** `topic_id` → `topics(id)` **ON DELETE CASCADE** (xóa chủ đề thì xóa hết từ trong chủ đề).

**Được tham chiếu bởi:** `user_progress.word_id`.

---

## 4. Bảng `user_progress` — Tiến độ học

Một dòng = một user đối với một từ (trạng thái đang học / đã thuộc).

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa dòng |
| `user_id` | `INT` | `NOT NULL`, `FK → users(id)` | User |
| `word_id` | `INT` | `NOT NULL`, `FK → words(id)` | Từ |
| `status` | `ENUM('learning','learned')` | mặc định `'learning'` | Trạng thái |
| `learned_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Thời điểm cập nhật |

**Ràng buộc duy nhất:** `UNIQUE (user_id, word_id)` — không trùng cặp user–từ.

**Khóa ngoại:** `ON DELETE CASCADE` từ `users` và `words`.

---

## 5. Bảng `quiz_results` — Kết quả quiz

Lịch sử làm bài quiz theo chủ đề.

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa dòng |
| `user_id` | `INT` | `NOT NULL`, `FK → users(id)` | User làm bài |
| `topic_id` | `INT` | `NOT NULL`, `FK → topics(id)` | Chủ đề quiz |
| `score` | `INT` | `NOT NULL` | Điểm đạt được |
| `total` | `INT` | `NOT NULL` | Tổng câu / điểm tối đa |
| `created_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Thời điểm nộp bài |

**Khóa ngoại:** `ON DELETE CASCADE` từ `users` và `topics`.

---

## 6. Bảng `badges` — Định nghĩa huy hiệu

Danh mục huy hiệu có thể đạt (điều kiện do backend kiểm tra khi học/quiz).

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Định danh huy hiệu |
| `code` | `VARCHAR(50)` | `NOT NULL`, `UNIQUE` | Mã logic (vd. `first_word`, `topic_full_1`) |
| `name` | `VARCHAR(100)` | `NOT NULL` | Tên hiển thị |
| `description` | `TEXT` | nullable | Mô tả điều kiện |
| `icon` | `VARCHAR(50)` | nullable | Biểu tượng (thường emoji) |
| `xp_required` | `INT` | mặc định `0` | Ngưỡng XP (huy hiệu milestone) |

**Nguồn tạo bảng:** `update_rewards.sql` hoặc `seedBadges()` khi khởi động server.

**Được tham chiếu bởi:** `user_badges.badge_id`.

---

## 7. Bảng `user_badges` — Huy hiệu user đã đạt

Ghi nhận user đã nhận huy hiệu nào, thời điểm nào.

| Cột | Kiểu | Ràng buộc | Mô tả |
|-----|------|-----------|--------|
| `id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa dòng |
| `user_id` | `INT` | `NOT NULL`, `FK → users(id)` | User |
| `badge_id` | `INT` | `NOT NULL`, `FK → badges(id)` | Huy hiệu |
| `earned_at` | `TIMESTAMP` | mặc định `CURRENT_TIMESTAMP` | Lúc đạt |

**Ràng buộc duy nhất:** `UNIQUE (user_id, badge_id)`.

**Khóa ngoại:** `ON DELETE CASCADE`.

---

## Sơ đồ quan hệ (tóm tắt)

```
users ──┬──< user_progress >── words ──> topics
        ├──< quiz_results >──┘
        └──< user_badges >── badges
```

- **topics** 1 — n **words**  
- **users** + **words** → **user_progress**  
- **users** + **topics** → **quiz_results**  
- **users** + **badges** → **user_badges**

---

## File SQL liên quan trong repo

| File | Nội dung |
|------|-----------|
| `schema.sql` | Tạo DB, các bảng cốt lõi (`users`, `topics`, `words`, `user_progress`, `quiz_results`) + dữ liệu mẫu chủ đề 1–10 |
| `update_rewards.sql` | Tạo `badges`, `user_badges` + `INSERT IGNORE` huy hiệu |
| `update_word_images_auto.sql` | Script cập nhật `image_url` cho `words` (tùy chọn) |

Backend **`seedTopics.js`** / **`seedBadges.js`**: đồng bộ chủ đề, từ bổ sung và huy hiệu khi server chạy (idempotent với `INSERT IGNORE` / kiểm tra trùng từ).

---

*Tài liệu này phản ánh trạng thái schema trong mã nguồn; nếu chỉnh SQL trong repo, nên cập nhật lại file này cho đồng bộ.*
