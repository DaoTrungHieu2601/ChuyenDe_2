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
(3, 'grandfather', 'ông', '/ˈɡrænfɑːðər/', 'My grandfather is old.', 'Ông tôi già rồi.'),
(3, 'grandmother', 'bà', '/ˈɡrænmʌðər/', 'My grandmother tells stories.', 'Bà tôi kể chuyện.'),
(3, 'parents', 'bố mẹ', '/ˈperənts/', 'My parents work hard.', 'Bố mẹ tôi làm việc chăm chỉ.'),
(3, 'son', 'con trai', '/sʌn/', 'They have two sons.', 'Họ có hai con trai.'),
(3, 'daughter', 'con gái', '/ˈdɔːtər/', 'Their daughter is five.', 'Con gái họ năm tuổi.'),
(3, 'husband', 'chồng', '/ˈhʌzbənd/', 'Her husband is a teacher.', 'Chồng cô ấy là giáo viên.'),
(3, 'wife', 'vợ', '/waɪf/', 'His wife cooks every day.', 'Vợ anh ấy nấu ăn mỗi ngày.'),
(3, 'uncle', 'chú/bác', '/ˈʌŋkəl/', 'My uncle lives nearby.', 'Chú tôi sống gần đây.'),
(3, 'aunt', 'cô/dì', '/ænt/', 'My aunt is very funny.', 'Cô tôi rất hài hước.'),
(3, 'cousin', 'anh/chị/em họ', '/ˈkʌzən/', 'I play with my cousin.', 'Tôi chơi với anh họ.'),
(3, 'baby', 'em bé', '/ˈbeɪbi/', 'The baby is smiling.', 'Em bé đang cười.'),
(3, 'child', 'đứa trẻ', '/tʃaɪld/', 'Every child needs love.', 'Mọi đứa trẻ cần tình yêu thương.'),
-- Thực phẩm
(4, 'apple', 'quả táo', '/ˈæpəl/', 'I eat an apple.', 'Tôi ăn một quả táo.'),
(4, 'banana', 'quả chuối', '/bəˈnænə/', 'Bananas are yellow.', 'Chuối màu vàng.'),
(4, 'rice', 'gạo/cơm', '/raɪs/', 'We eat rice daily.', 'Chúng tôi ăn cơm hàng ngày.'),
(4, 'bread', 'bánh mì', '/bred/', 'Fresh bread smells good.', 'Bánh mì mới thơm lắm.'),
(4, 'water', 'nước', '/ˈwɔːtər/', 'Drink more water.', 'Uống nhiều nước hơn.'),
(4, 'milk', 'sữa', '/mɪlk/', 'Children need milk.', 'Trẻ em cần sữa.'),
(4, 'coffee', 'cà phê', '/ˈkɒfi/', 'I drink coffee in the morning.', 'Tôi uống cà phê vào buổi sáng.'),
(4, 'tea', 'trà', '/tiː/', 'Would you like some tea?', 'Bạn có muốn uống trà không?'),
(4, 'egg', 'trứng', '/eɡ/', 'I had eggs for breakfast.', 'Tôi ăn trứng cho bữa sáng.'),
(4, 'meat', 'thịt', '/miːt/', 'This meat is tender.', 'Thịt này mềm.'),
(4, 'soup', 'súp', '/suːp/', 'Hot soup warms you up.', 'Súp nóng làm ấm người.'),
(4, 'noodle', 'mì', '/ˈnuːdəl/', 'I love noodle soup.', 'Tôi thích phở/mì nước.'),
(4, 'cake', 'bánh ngọt', '/keɪk/', 'It is my birthday cake.', 'Đây là bánh sinh nhật của tôi.'),
(4, 'cheese', 'phô mai', '/tʃiːz/', 'Cheese tastes salty.', 'Phô mai vị mặn.'),
(4, 'butter', 'bơ sữa', '/ˈbʌtər/', 'Bread with butter is tasty.', 'Bánh mì phết bơ rất ngon.'),
(4, 'sugar', 'đường', '/ˈʃʊɡər/', 'Too much sugar is bad.', 'Ăn quá nhiều đường không tốt.'),
(4, 'salt', 'muối', '/sɔːlt/', 'Add a little salt.', 'Cho một chút muối.'),
(4, 'juice', 'nước ép', '/dʒuːs/', 'Orange juice is healthy.', 'Nước cam ép tốt cho sức khỏe.'),
(4, 'potato', 'khoai tây', '/pəˈteɪtəʊ/', 'Boil the potatoes.', 'Luộc khoai tây.'),
(4, 'tomato', 'cà chua', '/təˈmɑːtəʊ/', 'Tomatoes are red.', 'Cà chua màu đỏ.'),
(4, 'carrot', 'cà rốt', '/ˈkærət/', 'Rabbits eat carrots.', 'Thỏ ăn cà rốt.'),
(4, 'onion', 'hành tây', '/ˈʌnjən/', 'Chop the onion finely.', 'Băm hành tây nhuyễn.'),
(4, 'chicken', 'thịt gà', '/ˈtʃɪkɪn/', 'We had chicken for dinner.', 'Bữa tối chúng tôi ăn thịt gà.'),
(4, 'beef', 'thịt bò', '/biːf/', 'Beef steak is expensive.', 'Bít tết bò đắt tiền.'),
(4, 'fish', 'cá (thức ăn)', '/fɪʃ/', 'Grilled fish is delicious.', 'Cá nướng rất ngon.'),
(4, 'vegetable', 'rau củ', '/ˈvedʒtəbl/', 'Eat more vegetables.', 'Ăn nhiều rau củ hơn.'),
(4, 'fruit', 'trái cây', '/fruːt/', 'Fruit is sweet.', 'Trái cây ngọt.'),
(4, 'honey', 'mật ong', '/ˈhʌni/', 'Honey is natural sugar.', 'Mật ong là đường tự nhiên.'),
(4, 'ice cream', 'kem', '/ˈaɪs kriːm/', 'Kids love ice cream.', 'Trẻ em thích kem.'),
-- Số đếm
(5, 'one', 'một', '/wʌn/', 'I have one book.', 'Tôi có một quyển sách.'),
(5, 'two', 'hai', '/tuː/', 'She has two cats.', 'Cô ấy có hai con mèo.'),
(5, 'three', 'ba', '/θriː/', 'Three birds are on the tree.', 'Ba con chim trên cây.'),
(5, 'four', 'bốn', '/fɔːr/', 'There are four chairs.', 'Có bốn cái ghế.'),
(5, 'five', 'năm', '/faɪv/', 'Five fingers on a hand.', 'Năm ngón trên một bàn tay.'),
(5, 'six', 'sáu', '/sɪks/', 'Six days a week.', 'Sáu ngày trong tuần.'),
(5, 'seven', 'bảy', '/ˈsevən/', 'Seven colors in a rainbow.', 'Bảy màu trong cầu vồng.'),
(5, 'eight', 'tám', '/eɪt/', 'Eight hours of sleep.', 'Tám giờ ngủ.'),
(5, 'nine', 'chín', '/naɪn/', 'Nine players in a team.', 'Chín cầu thủ trong đội.'),
(5, 'ten', 'mười', '/ten/', 'Count from one to ten.', 'Đếm từ một đến mười.'),
(5, 'eleven', 'mười một', '/ɪˈlevən/', 'The bus is number eleven.', 'Xe buýt số mười một.'),
(5, 'twelve', 'mười hai', '/twelv/', 'Twelve months in a year.', 'Mười hai tháng trong một năm.'),
(5, 'twenty', 'hai mươi', '/ˈtwenti/', 'She is twenty years old.', 'Cô ấy hai mươi tuổi.'),
(5, 'hundred', 'trăm', '/ˈhʌndrəd/', 'One hundred people came.', 'Một trăm người đã đến.'),
(5, 'first', 'thứ nhất', '/fɜːst/', 'This is my first day.', 'Đây là ngày đầu tiên của tôi.'),
(5, 'second', 'thứ hai', '/ˈsekənd/', 'The second lesson is easy.', 'Bài thứ hai dễ.'),
(5, 'half', 'một nửa', '/hæf/', 'Cut the apple in half.', 'Cắt táo làm đôi.'),
-- Động vật (bổ sung)
(1, 'cow', 'con bò', '/kaʊ/', 'The cow gives milk.', 'Con bò cho sữa.'),
(1, 'pig', 'con lợn/heo', '/pɪɡ/', 'Pigs like mud.', 'Lợn thích lầy bùn.'),
(1, 'horse', 'con ngựa', '/hɔːrs/', 'She rides a horse.', 'Cô ấy cưỡi ngựa.'),
(1, 'elephant', 'con voi', '/ˈelɪfənt/', 'An elephant never forgets.', 'Voi không bao giờ quên.'),
(1, 'lion', 'con sư tử', '/ˈlaɪən/', 'The lion is the king.', 'Sư tử là chúa sơn lâm.'),
(1, 'tiger', 'con hổ', '/ˈtaɪɡər/', 'Tigers have stripes.', 'Hổ có vằn.'),
(1, 'bear', 'con gấu', '/beər/', 'Bears sleep in winter.', 'Gấu ngủ đông.'),
(1, 'monkey', 'con khỉ', '/ˈmʌŋki/', 'Monkeys love bananas.', 'Khỉ thích chuối.'),
(1, 'duck', 'con vịt', '/dʌk/', 'The duck swims in the pond.', 'Vịt bơi trong ao.'),
(1, 'chicken', 'con gà', '/ˈtʃɪkɪn/', 'The chicken laid an egg.', 'Gà đẻ một quả trứng.'),
(1, 'sheep', 'con cừu', '/ʃiːp/', 'The sheep has wool.', 'Cừu có lông len.'),
(1, 'mouse', 'con chuột', '/maʊs/', 'A mouse likes cheese.', 'Chuột thích phô mai.'),
(1, 'bee', 'con ong', '/biː/', 'Bees make honey.', 'Ong làm mật.'),
(1, 'butterfly', 'con bướm', '/ˈbʌtərflaɪ/', 'A butterfly is colorful.', 'Bướm nhiều màu sắc.'),
(1, 'turtle', 'con rùa', '/ˈtɜːrtl/', 'The turtle is slow.', 'Rùa bò chậm.'),
(1, 'frog', 'con ếch', '/frɒɡ/', 'Frogs jump high.', 'Ếch nhảy cao.'),
(1, 'fox', 'con cáo', '/fɒks/', 'The fox is clever.', 'Cáo tinh ranh.'),
(1, 'deer', 'con hươu', '/dɪər/', 'A deer runs fast.', 'Hươu chạy nhanh.'),
(1, 'shark', 'cá mập', '/ʃɑːrk/', 'Sharks live in the ocean.', 'Cá mập sống ở đại dương.'),
(1, 'dolphin', 'cá heo', '/ˈdɒlfɪn/', 'Dolphins are smart.', 'Cá heo thông minh.'),
-- Màu sắc (bổ sung)
(2, 'white', 'màu trắng', '/waɪt/', 'Snow is white.', 'Tuyết màu trắng.'),
(2, 'pink', 'màu hồng', '/pɪŋk/', 'Roses can be pink.', 'Hoa hồng có thể màu hồng.'),
(2, 'purple', 'màu tím', '/ˈpɜːpl/', 'Grapes are purple.', 'Nho màu tím.'),
(2, 'orange', 'màu cam', '/ˈɒrɪndʒ/', 'Oranges are orange.', 'Quả cam màu cam.'),
(2, 'brown', 'màu nâu', '/braʊn/', 'Chocolate is brown.', 'Sô cô la màu nâu.'),
(2, 'gray', 'màu xám', '/ɡreɪ/', 'Clouds are often gray.', 'Mây thường xám.'),
(2, 'silver', 'màu bạc', '/ˈsɪlvər/', 'The ring is silver.', 'Nhẫn màu bạc.'),
(2, 'gold', 'màu vàng kim', '/ɡəʊld/', 'The medal is gold.', 'Huy chương màu vàng kim.');

-- Chủ đề 6–10 (Du lịch, Thể thao, …). Từ bổ sung thêm khi chạy backend (seedTopics) nếu cần.
INSERT INTO topics (id, name, description) VALUES
(6, 'Du lịch', 'Từ vựng về du lịch và phương tiện'),
(7, 'Thể thao', 'Từ vựng về các môn thể thao'),
(8, 'Công nghệ', 'Từ vựng về máy tính và thiết bị'),
(9, 'Thời tiết', 'Từ vựng về thời tiết'),
(10, 'Cơ thể', 'Từ vựng về bộ phận cơ thể');

INSERT INTO words (topic_id, english, vietnamese, pronunciation, example_en, example_vi) VALUES
(6, 'airport', 'sân bay', '/ˈeəpɔːrt/', 'We arrived at the airport.', 'Chúng tôi đến sân bay.'),
(6, 'hotel', 'khách sạn', '/hoʊˈtel/', 'The hotel is near the beach.', 'Khách sạn gần bãi biển.'),
(6, 'passport', 'hộ chiếu', '/ˈpæspɔːrt/', 'Show your passport.', 'Cho xem hộ chiếu.'),
(6, 'ticket', 'vé', '/ˈtɪkɪt/', 'I bought a train ticket.', 'Tôi mua vé tàu.'),
(6, 'map', 'bản đồ', '/mæp/', 'Use a map to find the way.', 'Dùng bản đồ để tìm đường.'),
(6, 'train', 'tàu hỏa', '/treɪn/', 'The train leaves at six.', 'Tàu chạy lúc sáu giờ.'),
(6, 'beach', 'bãi biển', '/biːtʃ/', 'We walked on the beach.', 'Chúng tôi đi dạo trên bãi biển.'),
(6, 'suitcase', 'vali', '/ˈsuːtkeɪs/', 'Pack your suitcase.', 'Sóc đồ vào vali.'),
(6, 'vacation', 'kỳ nghỉ', '/veɪˈkeɪʃən/', 'Summer vacation starts soon.', 'Kỳ nghỉ hè sắp bắt đầu.'),
(6, 'tourist', 'khách du lịch', '/ˈtʊrɪst/', 'Many tourists visit this city.', 'Nhiều khách du lịch đến thành phố này.'),
(7, 'football', 'bóng đá', '/ˈfʊtbɔːl/', 'He plays football every week.', 'Anh ấy đá bóng mỗi tuần.'),
(7, 'basketball', 'bóng rổ', '/ˈbæskɪtbɔːl/', 'She likes basketball.', 'Cô ấy thích bóng rổ.'),
(7, 'tennis', 'quần vợt', '/ˈtenɪs/', 'We play tennis on Sunday.', 'Chúng tôi chơi quần vợt vào chủ nhật.'),
(7, 'swimming', 'bơi lội', '/ˈswɪmɪŋ/', 'Swimming is good exercise.', 'Bơi lội là bài tập tốt.'),
(7, 'running', 'chạy bộ', '/ˈrʌnɪŋ/', 'Running keeps you healthy.', 'Chạy bộ giúp khỏe.'),
(7, 'game', 'trận đấu', '/ɡeɪm/', 'Our team won the game.', 'Đội chúng tôi thắng trận.'),
(7, 'team', 'đội', '/tiːm/', 'He is on the school team.', 'Anh ấy trong đội trường.'),
(7, 'win', 'thắng', '/wɪn/', 'We want to win.', 'Chúng tôi muốn thắng.'),
(7, 'sport', 'thể thao', '/spɔːrt/', 'What is your favorite sport?', 'Môn thể thao yêu thích của bạn là gì?'),
(7, 'ball', 'quả bóng', '/bɔːl/', 'Kick the ball.', 'Sút quả bóng.'),
(8, 'computer', 'máy tính', '/kəmˈpjuːtər/', 'Turn on the computer.', 'Bật máy tính.'),
(8, 'phone', 'điện thoại', '/foʊn/', 'My phone is new.', 'Điện thoại của tôi mới.'),
(8, 'internet', 'mạng internet', '/ˈɪntərnet/', 'Search on the internet.', 'Tìm trên internet.'),
(8, 'email', 'thư điện tử', '/ˈiːmeɪl/', 'Send me an email.', 'Gửi cho tôi email.'),
(8, 'website', 'trang web', '/ˈwebsaɪt/', 'Visit our website.', 'Vào trang web của chúng tôi.'),
(8, 'video', 'video', '/ˈvɪdioʊ/', 'Watch this video.', 'Xem video này.'),
(8, 'screen', 'màn hình', '/skriːn/', 'The screen is bright.', 'Màn hình sáng.'),
(8, 'keyboard', 'bàn phím', '/ˈkiːbɔːrd/', 'Type on the keyboard.', 'Gõ trên bàn phím.'),
(8, 'mouse', 'chuột (máy tính)', '/maʊs/', 'Click the mouse.', 'Nhấp chuột.'),
(8, 'password', 'mật khẩu', '/ˈpæswɜːrd/', 'Enter your password.', 'Nhập mật khẩu.'),
(9, 'sunny', 'có nắng', '/ˈsʌni/', 'It is sunny today.', 'Hôm nay trời nắng.'),
(9, 'rainy', 'có mưa', '/ˈreɪni/', 'Rainy days are cool.', 'Ngày mưa mát mẻ.'),
(9, 'cloudy', 'nhiều mây', '/ˈklaʊdi/', 'The sky is cloudy.', 'Trời nhiều mây.'),
(9, 'windy', 'có gió', '/ˈwɪndi/', 'It is very windy.', 'Gió rất mạnh.'),
(9, 'snowy', 'có tuyết', '/ˈsnoʊi/', 'A snowy morning.', 'Buổi sáng có tuyết.'),
(9, 'hot', 'nóng', '/hɒt/', 'Summer is hot.', 'Mùa hè nóng.'),
(9, 'cold', 'lạnh', '/koʊld/', 'Winter is cold.', 'Mùa đông lạnh.'),
(9, 'storm', 'cơn bão', '/stɔːrm/', 'A storm is coming.', 'Bão sắp đến.'),
(9, 'sky', 'bầu trời', '/skaɪ/', 'The sky is blue.', 'Bầu trời xanh.'),
(9, 'weather', 'thời tiết', '/ˈweðər/', 'How is the weather?', 'Thời tiết thế nào?'),
(10, 'head', 'đầu', '/hed/', 'My head hurts.', 'Đầu tôi đau.'),
(10, 'hand', 'bàn tay', '/hænd/', 'Wash your hands.', 'Rửa tay.'),
(10, 'foot', 'bàn chân', '/fʊt/', 'My foot is sore.', 'Chân tôi đau.'),
(10, 'eye', 'mắt', '/aɪ/', 'Close your eyes.', 'Nhắm mắt lại.'),
(10, 'ear', 'tai', '/ɪər/', 'Cover your ears.', 'Bịt tai lại.'),
(10, 'mouth', 'miệng', '/maʊθ/', 'Open your mouth.', 'Há miệng.'),
(10, 'nose', 'mũi', '/noʊz/', 'Touch your nose.', 'Chạm mũi.'),
(10, 'arm', 'cánh tay', '/ɑːrm/', 'Raise your arms.', 'Giơ cánh tay.'),
(10, 'leg', 'chân', '/leɡ/', 'Stretch your legs.', 'Duỗi chân.'),
(10, 'hair', 'tóc', '/heər/', 'She has long hair.', 'Cô ấy tóc dài.');
