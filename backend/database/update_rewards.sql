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
('first_word',   'Bước đầu tiên',   'Học từ vựng đầu tiên',         '🌱', 0),
('ten_words',    'Chăm chỉ',        'Học được 10 từ vựng',          '📚', 0),
('fifty_words',  'Siêu học viên',   'Học được 50 từ vựng',          '🎓', 0),
('first_quiz',   'Thử thách đầu',   'Hoàn thành quiz lần đầu',      '✏️', 0),
('perfect_quiz', 'Hoàn hảo',        'Đạt 100% trong một bài quiz',  '🏆', 0),
('topic_done',   'Chinh phục',      'Học hết 100% một chủ đề',      '🌟', 0),
('xp_100',       'Tích lũy 100 XP', 'Đạt 100 XP',                   '💎', 100),
('xp_500',       'Tích lũy 500 XP', 'Đạt 500 XP',                   '👑', 500);
