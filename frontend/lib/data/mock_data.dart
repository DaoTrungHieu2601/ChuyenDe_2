import 'package:flutter/material.dart';

class WordModel {
  final String english;
  final String vietnamese;
  final String pronunciation;
  final String example;
  final String exampleVietnamese;
  bool isLearned;

  WordModel({
    required this.english,
    required this.vietnamese,
    required this.pronunciation,
    required this.example,
    required this.exampleVietnamese,
    this.isLearned = false,
  });
}

class TopicModel {
  final int id;
  final String name;
  final String emoji;
  final List<Color> gradientColors;
  final List<WordModel> words;

  TopicModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.words,
  });

  int get learnedCount => words.where((w) => w.isLearned).length;
  int get totalCount => words.length;
  double get progress => totalCount == 0 ? 0 : learnedCount / totalCount;
}

class BadgeModel {
  final String emoji;
  final String name;
  final String description;
  final bool isEarned;

  const BadgeModel({
    required this.emoji,
    required this.name,
    required this.description,
    required this.isEarned,
  });
}

class MockData {
  static final List<TopicModel> topics = [
    TopicModel(
      id: 1,
      name: 'Động vật',
      emoji: '🐾',
      gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      words: [
        WordModel(english: 'dog', vietnamese: 'con chó', pronunciation: '/dɒɡ/', example: 'I have a dog.', exampleVietnamese: 'Tôi có một con chó.'),
        WordModel(english: 'cat', vietnamese: 'con mèo', pronunciation: '/kæt/', example: 'The cat is cute.', exampleVietnamese: 'Con mèo thật đáng yêu.'),
        WordModel(english: 'bird', vietnamese: 'con chim', pronunciation: '/bɜːrd/', example: 'A bird can fly.', exampleVietnamese: 'Chim có thể bay.'),
        WordModel(english: 'fish', vietnamese: 'con cá', pronunciation: '/fɪʃ/', example: 'I like fish.', exampleVietnamese: 'Tôi thích cá.'),
        WordModel(english: 'rabbit', vietnamese: 'con thỏ', pronunciation: '/ˈræbɪt/', example: 'The rabbit is white.', exampleVietnamese: 'Con thỏ màu trắng.'),
      ],
    ),
    TopicModel(
      id: 2,
      name: 'Màu sắc',
      emoji: '🎨',
      gradientColors: const [Color(0xFF4D8EFF), Color(0xFF6B5BFF)],
      words: [
        WordModel(english: 'red', vietnamese: 'màu đỏ', pronunciation: '/rɛd/', example: 'The apple is red.', exampleVietnamese: 'Quả táo màu đỏ.'),
        WordModel(english: 'blue', vietnamese: 'màu xanh dương', pronunciation: '/bluː/', example: 'The sky is blue.', exampleVietnamese: 'Bầu trời màu xanh dương.'),
        WordModel(english: 'green', vietnamese: 'màu xanh lá', pronunciation: '/ɡriːn/', example: 'Grass is green.', exampleVietnamese: 'Cỏ màu xanh lá.'),
        WordModel(english: 'yellow', vietnamese: 'màu vàng', pronunciation: '/ˈjɛloʊ/', example: 'The sun is yellow.', exampleVietnamese: 'Mặt trời màu vàng.'),
        WordModel(english: 'white', vietnamese: 'màu trắng', pronunciation: '/waɪt/', example: 'Snow is white.', exampleVietnamese: 'Tuyết màu trắng.'),
      ],
    ),
    TopicModel(
      id: 3,
      name: 'Gia đình',
      emoji: '👨‍👩‍👧',
      gradientColors: const [Color(0xFF6BCB77), Color(0xFF4D96FF)],
      words: [
        WordModel(english: 'father', vietnamese: 'bố / cha', pronunciation: '/ˈfɑːðər/', example: 'My father is kind.', exampleVietnamese: 'Bố tôi rất tốt bụng.'),
        WordModel(english: 'mother', vietnamese: 'mẹ', pronunciation: '/ˈmʌðər/', example: 'My mother cooks well.', exampleVietnamese: 'Mẹ tôi nấu ăn rất ngon.'),
        WordModel(english: 'brother', vietnamese: 'anh / em trai', pronunciation: '/ˈbrʌðər/', example: 'I have a brother.', exampleVietnamese: 'Tôi có một người anh trai.'),
        WordModel(english: 'sister', vietnamese: 'chị / em gái', pronunciation: '/ˈsɪstər/', example: 'My sister is smart.', exampleVietnamese: 'Em gái tôi rất thông minh.'),
        WordModel(english: 'grandma', vietnamese: 'bà', pronunciation: '/ˈɡrænmɑː/', example: 'Grandma makes cookies.', exampleVietnamese: 'Bà làm bánh quy.'),
      ],
    ),
    TopicModel(
      id: 4,
      name: 'Thực phẩm',
      emoji: '🍎',
      gradientColors: const [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
      words: [
        WordModel(english: 'apple', vietnamese: 'quả táo', pronunciation: '/ˈæpəl/', example: 'I eat an apple.', exampleVietnamese: 'Tôi ăn một quả táo.'),
        WordModel(english: 'rice', vietnamese: 'cơm / gạo', pronunciation: '/raɪs/', example: 'I eat rice every day.', exampleVietnamese: 'Tôi ăn cơm mỗi ngày.'),
        WordModel(english: 'milk', vietnamese: 'sữa', pronunciation: '/mɪlk/', example: 'Milk is healthy.', exampleVietnamese: 'Sữa rất tốt cho sức khỏe.'),
        WordModel(english: 'bread', vietnamese: 'bánh mì', pronunciation: '/brɛd/', example: 'I like bread.', exampleVietnamese: 'Tôi thích bánh mì.'),
        WordModel(english: 'water', vietnamese: 'nước', pronunciation: '/ˈwɔːtər/', example: 'Drink more water.', exampleVietnamese: 'Hãy uống nhiều nước hơn.'),
      ],
    ),
  ];

  static const List<BadgeModel> badges = [
    BadgeModel(emoji: '🌱', name: 'Bước đầu tiên', description: 'Học từ đầu tiên', isEarned: true),
    BadgeModel(emoji: '🔥', name: 'Chăm chỉ', description: 'Học 3 ngày liên tiếp', isEarned: true),
    BadgeModel(emoji: '⚡', name: 'Thử thách đầu', description: 'Hoàn thành quiz đầu tiên', isEarned: true),
    BadgeModel(emoji: '🏆', name: 'Siêu học viên', description: 'Học 50 từ vựng', isEarned: false),
    BadgeModel(emoji: '💎', name: 'Hoàn hảo', description: 'Quiz 100% đúng', isEarned: false),
    BadgeModel(emoji: '🚀', name: 'Chinh phục', description: 'Hoàn thành tất cả chủ đề', isEarned: false),
  ];

  static int get totalLearned =>
      topics.fold(0, (sum, t) => sum + t.learnedCount);

  static int get totalXP => totalLearned * 10;

  static int get inProgressTopics =>
      topics.where((t) => t.learnedCount > 0 && t.learnedCount < t.totalCount).length;
}
