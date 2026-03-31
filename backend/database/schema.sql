-- Tạo database
CREATE DATABASE IF NOT EXISTS vocab_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vocab_app;

-- Bảng người dùng
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  xp INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng chủ đề từ vựng
CREATE TABLE IF NOT EXISTS topics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng từ vựng
CREATE TABLE IF NOT EXISTS words (
  id INT AUTO_INCREMENT PRIMARY KEY,
  topic_id INT NOT NULL,
  english VARCHAR(100) NOT NULL,
  vietnamese VARCHAR(200) NOT NULL,
  pronunciation VARCHAR(100),
  example_en TEXT,
  example_vi TEXT,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

-- Bảng tiến trình học của user
CREATE TABLE IF NOT EXISTS user_progress (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  word_id INT NOT NULL,
  status ENUM('learning', 'learned') DEFAULT 'learning',
  learned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_word (user_id, word_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- Bảng kết quả quiz
CREATE TABLE IF NOT EXISTS quiz_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  topic_id INT NOT NULL,
  score INT NOT NULL,
  total INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

-- =====================
-- DỮ LIỆU MẪU
-- =====================

INSERT INTO topics (name, description) VALUES
('Động vật', 'Từ vựng về các loài động vật'),
('Màu sắc', 'Từ vựng về màu sắc'),
('Gia đình', 'Từ vựng về các thành viên trong gia đình'),
('Thực phẩm', 'Từ vựng về đồ ăn và thức uống'),
('Số đếm', 'Từ vựng về các con số');

INSERT INTO words (topic_id, english, vietnamese, pronunciation, example_en, example_vi) VALUES
-- Động vật
(1, 'dog', 'con chó', '/dɒɡ/', 'I have a dog.', 'Tôi có một con chó.'),
(1, 'cat', 'con mèo', '/kæt/', 'The cat is sleeping.', 'Con mèo đang ngủ.'),
(1, 'bird', 'con chim', '/bɜːrd/', 'A bird is singing.', 'Một con chim đang hót.'),
(1, 'fish', 'con cá', '/fɪʃ/', 'I like fish.', 'Tôi thích cá.'),
(1, 'rabbit', 'con thỏ', '/ˈræbɪt/', 'The rabbit is white.', 'Con thỏ màu trắng.'),
-- Màu sắc
(2, 'red', 'màu đỏ', '/red/', 'The apple is red.', 'Quả táo màu đỏ.'),
(2, 'blue', 'màu xanh dương', '/bluː/', 'The sky is blue.', 'Bầu trời màu xanh.'),
(2, 'green', 'màu xanh lá', '/ɡriːn/', 'The grass is green.', 'Cỏ màu xanh lá.'),
(2, 'yellow', 'màu vàng', '/ˈjeloʊ/', 'The sun is yellow.', 'Mặt trời màu vàng.'),
(2, 'black', 'màu đen', '/blæk/', 'The night is black.', 'Đêm tối màu đen.'),
-- Gia đình
(3, 'father', 'bố', '/ˈfɑːðər/', 'My father is a doctor.', 'Bố tôi là bác sĩ.'),
(3, 'mother', 'mẹ', '/ˈmʌðər/', 'My mother cooks well.', 'Mẹ tôi nấu ăn ngon.'),
(3, 'brother', 'anh/em trai', '/ˈbrʌðər/', 'I have one brother.', 'Tôi có một anh trai.'),
(3, 'sister', 'chị/em gái', '/ˈsɪstər/', 'My sister is kind.', 'Chị tôi tốt bụng.'),
(3, 'grandfather', 'ông', '/ˈɡrænfɑːðər/', 'My grandfather is old.', 'Ông tôi già rồi.');
