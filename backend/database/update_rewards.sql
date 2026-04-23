USE vocab_app;

-- Bảng định nghĩa các huy hiệu
CREATE TABLE IF NOT EXISTS badges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  xp_required INT DEFAULT 0
);

-- Bảng huy hiệu của user
CREATE TABLE IF NOT EXISTS user_badges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  badge_id INT NOT NULL,
  earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_badge (user_id, badge_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE
);

-- Dữ liệu huy hiệu mẫu
INSERT IGNORE INTO badges (code, name, description, icon, xp_required) VALUES
('first_word',   'Bước đầu tiên',   'Học xong 1 từ (đánh dấu đã thuộc)', '🌱', 0),
('ten_words',    'Chăm chỉ',        'Học xong 10 từ',               '📚', 0),
('fifty_words',  'Siêu học viên',   'Học xong 50 từ',               '🎓', 0),
('first_quiz',   'Thử thách đầu',   'Làm xong ít nhất 1 bài quiz',  '✏️', 0),
('perfect_quiz', 'Hoàn hảo',        'Đạt đủ điểm tối đa trong 1 bài quiz', '🏆', 0),
('topic_done',   'Chinh phục',      'Học hết 100% số từ trong 1 chủ đề', '🌟', 0),
('xp_100',       'Tích lũy 100 XP', 'Đạt tổng cộng 100 XP',         '💎', 100),
('xp_500',       'Tích lũy 500 XP', 'Đạt tổng cộng 500 XP',         '👑', 500),
('xp_1000',      'Nghìn XP',        'Đạt tổng cộng 1000 XP',        '⭐', 1000),
('hundred_words','Trăm từ',         'Học đủ 100 từ (đã thuộc)',      '💯', 0),
('five_quizzes', 'Quiz viên',       'Hoàn thành 5 bài quiz',        '📝', 0),
('three_topics', 'Tam chủ đề',      'Hoàn thành 100% 3 chủ đề từ',  '🎯', 0),
-- Huy hiệu theo chủ đề (mỗi chủ đề — khớp id trong bảng topics)
('topic_full_1', 'Chuyên gia Động vật',   'Hoàn thành 100% chủ đề Động vật',     '🦁', 0),
('topic_full_2', 'Chuyên gia Màu sắc',    'Hoàn thành 100% chủ đề Màu sắc',      '🎨', 0),
('topic_full_3', 'Chuyên gia Gia đình',   'Hoàn thành 100% chủ đề Gia đình',    '👨‍👩‍👧', 0),
('topic_full_4', 'Chuyên gia Thực phẩm',  'Hoàn thành 100% chủ đề Thực phẩm',   '🍎', 0),
('topic_full_5', 'Chuyên gia Số đếm',     'Hoàn thành 100% chủ đề Số đếm',      '🔢', 0),
('topic_full_6', 'Chuyên gia Du lịch',    'Hoàn thành 100% chủ đề Du lịch',     '✈️', 0),
('topic_full_7', 'Chuyên gia Thể thao',   'Hoàn thành 100% chủ đề Thể thao',    '⚽', 0),
('topic_full_8', 'Chuyên gia Công nghệ',  'Hoàn thành 100% chủ đề Công nghệ',   '💻', 0),
('topic_full_9', 'Chuyên gia Thời tiết',  'Hoàn thành 100% chủ đề Thời tiết',   '☁️', 0),
('topic_full_10', 'Chuyên gia Cơ thể',    'Hoàn thành 100% chủ đề Cơ thể',      '👤', 0),
-- Độ phủ: đã học từ ở nhiều chủ đề khác nhau
('topics_breadth_2', 'Vượt ranh giới',    'Đã học ít nhất 1 từ ở 2 chủ đề khác nhau', '🌉', 0),
('topics_breadth_4', 'Khám phá rộng',     'Đã học ít nhất 1 từ ở 4 chủ đề khác nhau', '🗺️', 0),
('topics_breadth_6', 'Sáu lĩnh vực',      'Đã học ít nhất 1 từ ở 6 chủ đề khác nhau', '🛤️', 0),
('topics_breadth_8', 'Tám chủ đề',        'Đã học ít nhất 1 từ ở 8 chủ đề khác nhau', '🌐', 0),
('topics_breadth_all','Đi khắp chủ đề',   'Đã học ít nhất 1 từ ở mọi chủ đề trong app', '🧭', 0),
-- Hoàn thành nhiều chủ đề 100%
('five_topics_done', 'Ngũ hành chủ đề',   'Hoàn thành 100% 5 chủ đề từ',         '🏅', 0),
('eight_topics_done', 'Bát chủ đề vàng', 'Hoàn thành 100% 8 chủ đề từ',       '🎖️', 0),
('ten_topics_done', 'Mười chủ đề tuyệt đối', 'Hoàn thành 100% 10 chủ đề từ', '📚', 0),
('all_topics_master','Bậc thầy từ vựng',  'Hoàn thành 100% tất cả chủ đề',        '👑', 0),
-- Quiz gắn với chủ đề
('quiz_three_topics','Đa dạng quiz',      'Làm quiz ở ít nhất 3 chủ đề khác nhau', '🎪', 0);
