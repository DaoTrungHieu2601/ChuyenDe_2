const pool = require('./database');

/**
 * Đảm bảo đủ 10 chủ đề + từ cho chủ đề 6–10 (lần đầu),
 * và bổ sung thêm từ cho mọi chủ đề (bỏ qua nếu đã có cùng english trong chủ đề).
 */
const TOPICS = [
  [1, 'Động vật', 'Từ vựng về các loài động vật'],
  [2, 'Màu sắc', 'Từ vựng về màu sắc'],
  [3, 'Gia đình', 'Từ vựng về các thành viên trong gia đình'],
  [4, 'Thực phẩm', 'Từ vựng về đồ ăn và thức uống'],
  [5, 'Số đếm', 'Từ vựng về các con số'],
  [6, 'Du lịch', 'Từ vựng về du lịch và phương tiện'],
  [7, 'Thể thao', 'Từ vựng về các môn thể thao'],
  [8, 'Công nghệ', 'Từ vựng máy tính và thiết bị'],
  [9, 'Thời tiết', 'Từ vựng về thời tiết'],
  [10, 'Cơ thể', 'Từ vựng về bộ phận cơ thể'],
];

// topic_id, english, vietnamese, pronunciation, example_en, example_vi
const WORDS_6_TO_10 = [
  [6, 'airport', 'sân bay', '/ˈeəpɔːrt/', 'We arrived at the airport.', 'Chúng tôi đến sân bay.'],
  [6, 'hotel', 'khách sạn', '/hoʊˈtel/', 'The hotel is near the beach.', 'Khách sạn gần bãi biển.'],
  [6, 'passport', 'hộ chiếu', '/ˈpæspɔːrt/', 'Show your passport.', 'Cho xem hộ chiếu.'],
  [6, 'ticket', 'vé', '/ˈtɪkɪt/', 'I bought a train ticket.', 'Tôi mua vé tàu.'],
  [6, 'map', 'bản đồ', '/mæp/', 'Use a map to find the way.', 'Dùng bản đồ để tìm đường.'],
  [6, 'train', 'tàu hỏa', '/treɪn/', 'The train leaves at six.', 'Tàu chạy lúc sáu giờ.'],
  [6, 'beach', 'bãi biển', '/biːtʃ/', 'We walked on the beach.', 'Chúng tôi đi dạo trên bãi biển.'],
  [6, 'suitcase', 'vali', '/ˈsuːtkeɪs/', 'Pack your suitcase.', 'Sóc đồ vào vali.'],
  [6, 'vacation', 'kỳ nghỉ', '/veɪˈkeɪʃən/', 'Summer vacation starts soon.', 'Kỳ nghỉ hè sắp bắt đầu.'],
  [6, 'tourist', 'khách du lịch', '/ˈtʊrɪst/', 'Many tourists visit this city.', 'Nhiều khách du lịch đến thành phố này.'],
  [7, 'football', 'bóng đá', '/ˈfʊtbɔːl/', 'He plays football every week.', 'Anh ấy đá bóng mỗi tuần.'],
  [7, 'basketball', 'bóng rổ', '/ˈbæskɪtbɔːl/', 'She likes basketball.', 'Cô ấy thích bóng rổ.'],
  [7, 'tennis', 'quần vợt', '/ˈtenɪs/', 'We play tennis on Sunday.', 'Chúng tôi chơi quần vợt vào chủ nhật.'],
  [7, 'swimming', 'bơi lội', '/ˈswɪmɪŋ/', 'Swimming is good exercise.', 'Bơi lội là bài tập tốt.'],
  [7, 'running', 'chạy bộ', '/ˈrʌnɪŋ/', 'Running keeps you healthy.', 'Chạy bộ giúp khỏe.'],
  [7, 'game', 'trận đấu', '/ɡeɪm/', 'Our team won the game.', 'Đội chúng tôi thắng trận.'],
  [7, 'team', 'đội', '/tiːm/', 'He is on the school team.', 'Anh ấy trong đội trường.'],
  [7, 'win', 'thắng', '/wɪn/', 'We want to win.', 'Chúng tôi muốn thắng.'],
  [7, 'sport', 'thể thao', '/spɔːrt/', 'What is your favorite sport?', 'Môn thể thao yêu thích của bạn là gì?'],
  [7, 'ball', 'quả bóng', '/bɔːl/', 'Kick the ball.', 'Sút quả bóng.'],
  [8, 'computer', 'máy tính', '/kəmˈpjuːtər/', 'Turn on the computer.', 'Bật máy tính.'],
  [8, 'phone', 'điện thoại', '/foʊn/', 'My phone is new.', 'Điện thoại của tôi mới.'],
  [8, 'internet', 'mạng internet', '/ˈɪntərnet/', 'Search on the internet.', 'Tìm trên internet.'],
  [8, 'email', 'thư điện tử', '/ˈiːmeɪl/', 'Send me an email.', 'Gửi cho tôi email.'],
  [8, 'website', 'trang web', '/ˈwebsaɪt/', 'Visit our website.', 'Vào trang web của chúng tôi.'],
  [8, 'video', 'video', '/ˈvɪdioʊ/', 'Watch this video.', 'Xem video này.'],
  [8, 'screen', 'màn hình', '/skriːn/', 'The screen is bright.', 'Màn hình sáng.'],
  [8, 'keyboard', 'bàn phím', '/ˈkiːbɔːrd/', 'Type on the keyboard.', 'Gõ trên bàn phím.'],
  [8, 'mouse', 'chuột (máy tính)', '/maʊs/', 'Click the mouse.', 'Nhấp chuột.'],
  [8, 'password', 'mật khẩu', '/ˈpæswɜːrd/', 'Enter your password.', 'Nhập mật khẩu.'],
  [9, 'sunny', 'có nắng', '/ˈsʌni/', 'It is sunny today.', 'Hôm nay trời nắng.'],
  [9, 'rainy', 'có mưa', '/ˈreɪni/', 'Rainy days are cool.', 'Ngày mưa mát mẻ.'],
  [9, 'cloudy', 'nhiều mây', '/ˈklaʊdi/', 'The sky is cloudy.', 'Trời nhiều mây.'],
  [9, 'windy', 'có gió', '/ˈwɪndi/', 'It is very windy.', 'Gió rất mạnh.'],
  [9, 'snowy', 'có tuyết', '/ˈsnoʊi/', 'A snowy morning.', 'Buổi sáng có tuyết.'],
  [9, 'hot', 'nóng', '/hɒt/', 'Summer is hot.', 'Mùa hè nóng.'],
  [9, 'cold', 'lạnh', '/koʊld/', 'Winter is cold.', 'Mùa đông lạnh.'],
  [9, 'storm', 'cơn bão', '/stɔːrm/', 'A storm is coming.', 'Bão sắp đến.'],
  [9, 'sky', 'bầu trời', '/skaɪ/', 'The sky is blue.', 'Bầu trời xanh.'],
  [9, 'weather', 'thời tiết', '/ˈweðər/', 'How is the weather?', 'Thời tiết thế nào?'],
  [10, 'head', 'đầu', '/hed/', 'My head hurts.', 'Đầu tôi đau.'],
  [10, 'hand', 'bàn tay', '/hænd/', 'Wash your hands.', 'Rửa tay.'],
  [10, 'foot', 'bàn chân', '/fʊt/', 'My foot is sore.', 'Chân tôi đau.'],
  [10, 'eye', 'mắt', '/aɪ/', 'Close your eyes.', 'Nhắm mắt lại.'],
  [10, 'ear', 'tai', '/ɪər/', 'Cover your ears.', 'Bịt tai lại.'],
  [10, 'mouth', 'miệng', '/maʊθ/', 'Open your mouth.', 'Há miệng.'],
  [10, 'nose', 'mũi', '/noʊz/', 'Touch your nose.', 'Chạm mũi.'],
  [10, 'arm', 'cánh tay', '/ɑːrm/', 'Raise your arms.', 'Giơ cánh tay.'],
  [10, 'leg', 'chân', '/leɡ/', 'Stretch your legs.', 'Duỗi chân.'],
  [10, 'hair', 'tóc', '/heər/', 'She has long hair.', 'Cô ấy tóc dài.'],
];

/** Từ bổ sung theo chủ đề (chèn nếu chưa tồn tại cùng topic + english). */
const EXTRA_WORDS_ALL_TOPICS = [
  [1, 'zebra', 'ngựa vằn', '/ˈzebrə/', 'A zebra has stripes.', 'Ngựa vằn có sọc.'],
  [1, 'giraffe', 'hươu cao cổ', '/dʒɪˈræf/', 'The giraffe is tall.', 'Hươu cao cổ rất cao.'],
  [1, 'kangaroo', 'chuột túi', '/ˌkæŋɡəˈruː/', 'Kangaroos jump high.', 'Chuột túi nhảy cao.'],
  [1, 'penguin', 'chim cánh cụt', '/ˈpeŋɡwɪn/', 'Penguins live in cold places.', 'Chim cánh cụt sống nơi lạnh.'],
  [1, 'whale', 'cá voi', '/weɪl/', 'The whale is huge.', 'Cá voi rất to.'],
  [1, 'owl', 'cú mèo', '/aʊl/', 'The owl flies at night.', 'Cú mèo bay ban đêm.'],
  [1, 'camel', 'lạc đà', '/ˈkæməl/', 'Camels live in the desert.', 'Lạc đà sống ở sa mạc.'],
  [1, 'snail', 'ốc sên', '/sneɪl/', 'The snail moves slowly.', 'Ốc sên bò chậm.'],
  [1, 'crab', 'con cua', '/kræb/', 'Crabs walk sideways.', 'Cua đi ngang.'],
  [1, 'seal', 'hải cẩu', '/siːl/', 'Seals swim well.', 'Hải cẩu bơi giỏi.'],
  [2, 'beige', 'màu be', '/beɪʒ/', 'The wall is beige.', 'Tường màu be.'],
  [2, 'turquoise', 'màu ngọc lam', '/ˈtɜːrkɔɪz/', 'She likes turquoise.', 'Cô ấy thích màu ngọc lam.'],
  [2, 'navy', 'màu xanh đậm', '/ˈneɪvi/', 'He wears navy blue.', 'Anh ấy mặc xanh đậm.'],
  [2, 'lavender', 'màu hoa oải hương', '/ˈlævəndər/', 'Lavender smells nice.', 'Màu hoa oải hương thơm.'],
  [2, 'cyan', 'màu lơ', '/ˈsaɪən/', 'Cyan is a bright blue.', 'Màu lơ là xanh sáng.'],
  [2, 'magenta', 'màu đỏ tím', '/məˈdʒentə/', 'Magenta is vivid.', 'Màu đỏ tím rất rực.'],
  [2, 'olive', 'màu ô liu', '/ˈɒlɪv/', 'Olive green is calm.', 'Xanh ô liu dịu mắt.'],
  [2, 'teal', 'màu xanh mòng két', '/tiːl/', 'Teal is trendy.', 'Xanh mòng két đang thịnh hành.'],
  [2, 'coral', 'màu san hô', '/ˈkɒrəl/', 'Coral color is warm.', 'Màu san hô ấm.'],
  [2, 'maroon', 'màu nâu đỏ', '/məˈruːn/', 'Maroon looks elegant.', 'Nâu đỏ trông thanh lịch.'],
  [3, 'nephew', 'cháu trai (con anh chị)', '/ˈnefjuː/', 'My nephew is five.', 'Cháu trai tôi năm tuổi.'],
  [3, 'niece', 'cháu gái (con anh chị)', '/niːs/', 'My niece is cute.', 'Cháu gái tôi dễ thương.'],
  [3, 'twin', 'sinh đôi', '/twɪn/', 'They are twins.', 'Họ là sinh đôi.'],
  [3, 'relative', 'họ hàng', '/ˈrelətɪv/', 'We visit relatives.', 'Chúng tôi thăm họ hàng.'],
  [3, 'neighbor', 'hàng xóm', '/ˈneɪbər/', 'Our neighbor is kind.', 'Hàng xóm chúng tôi tốt bụng.'],
  [3, 'surname', 'họ', '/ˈsɜːrneɪm/', 'What is your surname?', 'Họ của bạn là gì?'],
  [3, 'couple', 'cặp đôi', '/ˈkʌpəl/', 'The young couple married.', 'Cặp đôi trẻ kết hôn.'],
  [3, 'marriage', 'hôn nhân', '/ˈmærɪdʒ/', 'Marriage needs trust.', 'Hôn nhân cần tin tưởng.'],
  [3, 'adult', 'người lớn', '/ˈædʌlt/', 'Adults pay full price.', 'Người lớn trả giá đủ.'],
  [3, 'teenager', 'thiếu niên', '/ˈtiːneɪdʒər/', 'Teenagers like music.', 'Thiếu niên thích nhạc.'],
  [4, 'pizza', 'bánh pizza', '/ˈpiːtsə/', 'I love pizza.', 'Tôi thích pizza.'],
  [4, 'pasta', 'mì Ý', '/ˈpæstə/', 'Pasta is Italian food.', 'Mì Ý là món Ý.'],
  [4, 'salad', 'salad', '/ˈsæləd/', 'Eat a fresh salad.', 'Ăn salad tươi.'],
  [4, 'sandwich', 'bánh sandwich', '/ˈsænwɪtʃ/', 'I made a sandwich.', 'Tôi làm sandwich.'],
  [4, 'yogurt', 'sữa chua', '/ˈjoʊɡərt/', 'Yogurt is healthy.', 'Sữa chua tốt cho sức khỏe.'],
  [4, 'pepper', 'hạt tiêu / ớt', '/ˈpepər/', 'Add some pepper.', 'Cho một ít tiêu.'],
  [4, 'garlic', 'tỏi', '/ˈɡɑːrlɪk/', 'Garlic tastes strong.', 'Tỏi vị nồng.'],
  [4, 'lemon', 'chanh', '/ˈlemən/', 'Lemon is sour.', 'Chanh chua.'],
  [4, 'mango', 'xoài', '/ˈmæŋɡoʊ/', 'Mangoes are sweet.', 'Xoài ngọt.'],
  [4, 'grape', 'nho', '/ɡreɪp/', 'Grapes are purple.', 'Nho màu tím.'],
  [5, 'thirty', 'ba mươi', '/ˈθɜːrti/', 'She is thirty years old.', 'Cô ấy ba mươi tuổi.'],
  [5, 'forty', 'bốn mươi', '/ˈfɔːrti/', 'Forty students came.', 'Bốn mươi học sinh đã đến.'],
  [5, 'fifty', 'năm mươi', '/ˈfɪfti/', 'Fifty percent agreed.', 'Năm mươi phần trăm đồng ý.'],
  [5, 'sixty', 'sáu mươi', '/ˈsɪksti/', 'Sixty minutes in an hour.', 'Sáu mươi phút trong một giờ.'],
  [5, 'seventy', 'bảy mươi', '/ˈsevnti/', 'He is seventy.', 'Ông ấy bảy mươi tuổi.'],
  [5, 'eighty', 'tám mươi', '/ˈeɪti/', 'Eighty dollars is enough.', 'Tám mươi đô là đủ.'],
  [5, 'ninety', 'chín mươi', '/ˈnaɪnti/', 'Ninety percent finished.', 'Chín mươi phần trăm xong.'],
  [5, 'thousand', 'nghìn', '/ˈθaʊzənd/', 'One thousand people came.', 'Một nghìn người đã đến.'],
  [5, 'million', 'triệu', '/ˈmɪljən/', 'A million stars.', 'Một triệu vì sao.'],
  [5, 'billion', 'tỷ', '/ˈbɪljən/', 'Billions of stars.', 'Hàng tỷ vì sao.'],
  [6, 'plane', 'máy bay', '/pleɪn/', 'The plane took off.', 'Máy bay cất cánh.'],
  [6, 'boat', 'thuyền', '/boʊt/', 'We rowed a boat.', 'Chúng tôi chèo thuyền.'],
  [6, 'taxi', 'xe taxi', '/ˈtæksi/', 'Take a taxi home.', 'Bắt taxi về nhà.'],
  [6, 'luggage', 'hành lý', '/ˈlʌɡɪdʒ/', 'Check your luggage.', 'Kiểm tra hành lý.'],
  [6, 'museum', 'bảo tàng', '/mjuˈziːəm/', 'We visited a museum.', 'Chúng tôi thăm bảo tàng.'],
  [6, 'island', 'đảo', '/ˈaɪlənd/', 'The island is beautiful.', 'Hòn đảo đẹp.'],
  [6, 'camping', 'cắm trại', '/ˈkæmpɪŋ/', 'We went camping.', 'Chúng tôi đi cắm trại.'],
  [6, 'hiking', 'leo núi đi bộ', '/ˈhaɪkɪŋ/', 'Hiking is fun.', 'Leo núi đi bộ vui.'],
  [6, 'abroad', 'nước ngoài', '/əˈbrɔːd/', 'Study abroad.', 'Du học nước ngoài.'],
  [6, 'reservation', 'đặt chỗ', '/ˌrezərˈveɪʃən/', 'Make a reservation.', 'Đặt chỗ trước.'],
  [7, 'volleyball', 'bóng chuyền', '/ˈvɒlibɔːl/', 'She plays volleyball.', 'Cô ấy chơi bóng chuyền.'],
  [7, 'baseball', 'bóng chày', '/ˈbeɪsbɔːl/', 'Baseball is popular in the US.', 'Bóng chày phổ biến ở Mỹ.'],
  [7, 'golf', 'gôn', '/ɡɒlf/', 'He plays golf.', 'Anh ấy chơi gôn.'],
  [7, 'cycling', 'đạp xe', '/ˈsaɪklɪŋ/', 'Cycling is good for health.', 'Đạp xe tốt cho sức khỏe.'],
  [7, 'coach', 'huấn luyện viên', '/koʊtʃ/', 'The coach is strict.', 'HLV nghiêm khắc.'],
  [7, 'stadium', 'sân vận động', '/ˈsteɪdiəm/', 'The stadium is full.', 'Sân vận động đầy người.'],
  [7, 'medal', 'huy chương', '/ˈmedəl/', 'She won a gold medal.', 'Cô ấy giành huy chương vàng.'],
  [7, 'racket', 'vợt', '/ˈrækɪt/', 'Tennis rackets are light.', 'Vợt tennis nhẹ.'],
  [7, 'referee', 'trọng tài', '/ˌrefəˈriː/', 'The referee blew the whistle.', 'Trọng tài thổi còi.'],
  [7, 'champion', 'nhà vô địch', '/ˈtʃæmpiən/', 'He is the champion.', 'Anh ấy là nhà vô địch.'],
  [8, 'tablet', 'máy tính bảng', '/ˈtæblət/', 'I use a tablet.', 'Tôi dùng máy tính bảng.'],
  [8, 'charger', 'cục sạc', '/ˈtʃɑːrdʒər/', 'Where is the charger?', 'Cục sạc ở đâu?'],
  [8, 'wifi', 'wifi', '/ˈwaɪfaɪ/', 'The wifi is slow.', 'Wifi chậm.'],
  [8, 'software', 'phần mềm', '/ˈsɔːftwer/', 'Install the software.', 'Cài phần mềm.'],
  [8, 'download', 'tải xuống', '/ˌdaʊnˈloʊd/', 'Download the file.', 'Tải file xuống.'],
  [8, 'file', 'tệp tin', '/faɪl/', 'Save the file.', 'Lưu tệp tin.'],
  [8, 'folder', 'thư mục', '/ˈfoʊldər/', 'Open the folder.', 'Mở thư mục.'],
  [8, 'printer', 'máy in', '/ˈprɪntər/', 'The printer is broken.', 'Máy in hỏng.'],
  [8, 'virus', 'virus', '/ˈvaɪrəs/', 'Scan for viruses.', 'Quét virus.'],
  [8, 'data', 'dữ liệu', '/ˈdeɪtə/', 'Back up your data.', 'Sao lưu dữ liệu.'],
  [9, 'fog', 'sương mù', '/fɒɡ/', 'Thick fog this morning.', 'Sương mù dày sáng nay.'],
  [9, 'lightning', 'tia chớp', '/ˈlaɪtnɪŋ/', 'Lightning flashed.', 'Tia chớp loé sáng.'],
  [9, 'thunder', 'sấm', '/ˈθʌndər/', 'Thunder is loud.', 'Sấm rất to.'],
  [9, 'rainbow', 'cầu vồng', '/ˈreɪnboʊ/', 'A rainbow appeared.', 'Cầu vồng xuất hiện.'],
  [9, 'season', 'mùa', '/ˈsiːzən/', 'Spring is my favorite season.', 'Mùa xuân là mùa tôi thích.'],
  [9, 'climate', 'khí hậu', '/ˈklaɪmət/', 'The climate is mild.', 'Khí hậu ôn hòa.'],
  [9, 'forecast', 'dự báo', '/ˈfɔːrkæst/', 'Check the weather forecast.', 'Xem dự báo thời tiết.'],
  [9, 'humidity', 'độ ẩm', '/hjuːˈmɪdəti/', 'High humidity today.', 'Độ ẩm cao hôm nay.'],
  [9, 'flood', 'lũ lụt', '/flʌd/', 'The flood damaged homes.', 'Lũ làm hỏng nhà.'],
  [9, 'breeze', 'gió nhẹ', '/briːz/', 'A cool breeze.', 'Gió nhẹ mát.'],
  [10, 'finger', 'ngón tay', '/ˈfɪŋɡər/', 'I hurt my finger.', 'Tôi đau ngón tay.'],
  [10, 'toe', 'ngón chân', '/toʊ/', 'My toe hurts.', 'Ngón chân tôi đau.'],
  [10, 'neck', 'cổ', '/nek/', 'Turn your neck slowly.', 'Quay cổ chậm.'],
  [10, 'shoulder', 'vai', '/ˈʃoʊldər/', 'He shrugged his shoulders.', 'Anh ấy nhún vai.'],
  [10, 'chest', 'ngực', '/tʃest/', 'Chest pain needs a doctor.', 'Đau ngực cần bác sĩ.'],
  [10, 'stomach', 'dạ dày / bụng', '/ˈstʌmək/', 'My stomach hurts.', 'Bụng tôi đau.'],
  [10, 'knee', 'đầu gối', '/niː/', 'I scraped my knee.', 'Tôi trầy đầu gối.'],
  [10, 'skin', 'da', '/skɪn/', 'Skin protects the body.', 'Da bảo vệ cơ thể.'],
  [10, 'brain', 'não', '/breɪn/', 'The brain controls thinking.', 'Não điều khiển suy nghĩ.'],
  [10, 'heart', 'tim', '/hɑːrt/', 'The heart beats fast.', 'Tim đập nhanh.'],
];

async function insertWordsIfNotExist(rows) {
  for (const r of rows) {
    const [topicId, english] = [r[0], r[1]];
    const [[exists]] = await pool.query(
      'SELECT id FROM words WHERE topic_id = ? AND english = ? LIMIT 1',
      [topicId, english]
    );
    if (exists) continue;
    await pool.query(
      'INSERT INTO words (topic_id, english, vietnamese, pronunciation, example_en, example_vi) VALUES (?, ?, ?, ?, ?, ?)',
      r
    );
  }
}

async function seedTopics() {
  for (const [id, name, description] of TOPICS) {
    await pool.query('INSERT IGNORE INTO topics (id, name, description) VALUES (?, ?, ?)', [id, name, description]);
  }

  const byTopic = new Map();
  for (const row of WORDS_6_TO_10) {
    const tid = row[0];
    if (!byTopic.has(tid)) byTopic.set(tid, []);
    byTopic.get(tid).push(row);
  }

  for (const [topicId, rows] of byTopic) {
    const [[{ c }]] = await pool.query('SELECT COUNT(*) AS c FROM words WHERE topic_id = ?', [topicId]);
    if (Number(c) > 0) continue;

    const placeholders = rows.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
    const flat = rows.flat();
    await pool.query(
      `INSERT INTO words (topic_id, english, vietnamese, pronunciation, example_en, example_vi) VALUES ${placeholders}`,
      flat
    );
  }

  await insertWordsIfNotExist(EXTRA_WORDS_ALL_TOPICS);

  try {
    const [[{ m }]] = await pool.query('SELECT COALESCE(MAX(id), 0) AS m FROM topics');
    await pool.query('ALTER TABLE topics AUTO_INCREMENT = ?', [Number(m) + 1]);
  } catch (_) {
    /* bỏ qua nếu không có quyền ALTER */
  }

  const [[{ n }]] = await pool.query('SELECT COUNT(*) AS n FROM topics');
  const [[{ w }]] = await pool.query('SELECT COUNT(*) AS w FROM words');
  console.log(`Đồng bộ chủ đề: ${n} chủ đề, ${w} từ vựng trong database.`);
}

module.exports = { seedTopics };
