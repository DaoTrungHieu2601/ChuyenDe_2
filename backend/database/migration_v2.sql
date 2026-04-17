-- Migration v2: thêm audio_url cho words, bảng badges, user_badges
USE vocab_app;

-- Thêm cột audio_url vào bảng words
ALTER TABLE words ADD COLUMN IF NOT EXISTS audio_url VARCHAR(255) AFTER image_url;

-- Bảng huy hiệu
CREATE TABLE IF NOT EXISTS badges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(10),
  xp_required INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng huy hiệu user đạt được
CREATE TABLE IF NOT EXISTS user_badges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  badge_id INT NOT NULL,
  earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_badge (user_id, badge_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE
);

-- Dữ liệu badge mẫu
INSERT IGNORE INTO badges (code, name, description, icon, xp_required) VALUES
('first_word',   'Bước Đầu Tiên',   'Học từ đầu tiên',               '🌱', 0),
('ten_words',    'Siêng Năng',       'Học được 10 từ',                 '📚', 0),
('fifty_words',  'Học Giả',          'Học được 50 từ',                 '🎓', 0),
('first_quiz',   'Thử Thách',        'Làm quiz lần đầu',               '✏️', 0),
('perfect_quiz', 'Hoàn Hảo',         'Đạt điểm tuyệt đối trong quiz',  '🏆', 0),
('topic_done',   'Chinh Phục',       'Hoàn thành toàn bộ từ 1 chủ đề', '🎯', 0),
('xp_100',       'Tích Cực',         'Tích lũy 100 XP',                '⭐', 100),
('xp_500',       'Bậc Thầy',         'Tích lũy 500 XP',                '💎', 500);

-- Thêm dữ liệu từ mẫu cho topic 4 (Thực phẩm) và 5 (Số đếm)
INSERT IGNORE INTO words (topic_id, english, vietnamese, pronunciation, example_en, example_vi) VALUES
-- Thực phẩm
(4, 'rice',   'cơm / gạo',  '/raɪs/',     'I eat rice every day.',     'Tôi ăn cơm mỗi ngày.'),
(4, 'bread',  'bánh mì',    '/bred/',      'I like bread.',              'Tôi thích bánh mì.'),
(4, 'egg',    'trứng',      '/ɛɡ/',        'Eggs are nutritious.',       'Trứng rất bổ dưỡng.'),
(4, 'milk',   'sữa',        '/mɪlk/',      'Milk is good for health.',   'Sữa tốt cho sức khỏe.'),
(4, 'water',  'nước',       '/ˈwɔːtər/',   'Drink more water.',          'Uống nhiều nước hơn.'),
-- Số đếm
(5, 'one',    'một',        '/wʌn/',       'I have one cat.',            'Tôi có một con mèo.'),
(5, 'two',    'hai',        '/tuː/',       'She has two bags.',          'Cô ấy có hai cái túi.'),
(5, 'three',  'ba',         '/θriː/',      'There are three books.',     'Có ba cuốn sách.'),
(5, 'four',   'bốn',        '/fɔːr/',      'I see four birds.',          'Tôi thấy bốn con chim.'),
(5, 'five',   'năm',        '/faɪv/',      'Five apples on the table.',  'Năm quả táo trên bàn.');
