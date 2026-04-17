const pool = require('../config/database');

const QUIZ_WORD_COUNT = 10;
const XP_PER_CORRECT  = 3;
const XP_PERFECT_BONUS = 20;

// Lấy câu hỏi quiz theo chủ đề
const getQuizByTopic = async (req, res) => {
  const { topicId } = req.params;
  const count = parseInt(req.query.count) || QUIZ_WORD_COUNT;

  try {
    const [topic] = await pool.query('SELECT id, name FROM topics WHERE id = ?', [topicId]);
    if (topic.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy chủ đề' });
    }

    const [words] = await pool.query(`
      SELECT id, english, vietnamese, pronunciation, image_url
      FROM words WHERE topic_id = ?
      ORDER BY RAND()
      LIMIT ?
    `, [topicId, count]);

    if (words.length < 2) {
      return res.status(400).json({ message: 'Chủ đề không đủ từ để tạo quiz' });
    }

    const [allWords] = await pool.query(
      'SELECT id, english, vietnamese FROM words WHERE topic_id = ?',
      [topicId]
    );

    const questions = words.map(w => ({
      word_id: w.id,
      question: w.english,
      pronunciation: w.pronunciation,
      image_url: w.image_url,
      correct_answer: w.vietnamese,
      options: buildOptions(w.vietnamese, allWords.map(x => x.vietnamese), 4),
    }));

    res.json({ topic: topic[0], questions });
  } catch (err) {
    console.error('getQuizByTopic error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Quiz ôn tập: lấy từ user đã học (status=learned hoặc learning)
const getReviewQuiz = async (req, res) => {
  const userId = req.user.id;
  const count = parseInt(req.query.count) || QUIZ_WORD_COUNT;

  try {
    const [words] = await pool.query(`
      SELECT w.id, w.english, w.vietnamese, w.pronunciation, w.image_url, w.topic_id
      FROM words w
      JOIN user_progress up ON up.word_id = w.id
      WHERE up.user_id = ?
      ORDER BY RAND()
      LIMIT ?
    `, [userId, count]);

    if (words.length < 2) {
      return res.status(400).json({ message: 'Bạn chưa học đủ từ để ôn tập. Hãy học thêm trước!' });
    }

    const [pool_words] = await pool.query(
      'SELECT id, english, vietnamese FROM words'
    );

    const questions = words.map(w => ({
      word_id: w.id,
      topic_id: w.topic_id,
      question: w.english,
      pronunciation: w.pronunciation,
      image_url: w.image_url,
      correct_answer: w.vietnamese,
      options: buildOptions(w.vietnamese, pool_words.map(x => x.vietnamese), 4),
    }));

    res.json({ mode: 'review', questions });
  } catch (err) {
    console.error('getReviewQuiz error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Nộp kết quả quiz → tự cập nhật tiến độ + XP + badge
const submitQuiz = async (req, res) => {
  const userId = req.user.id;
  const { topic_id, answers } = req.body;
  // answers: [{ word_id, is_correct }]

  if (!topic_id || !Array.isArray(answers) || answers.length === 0) {
    return res.status(400).json({ message: 'topic_id và answers là bắt buộc' });
  }

  try {
    const score = answers.filter(a => a.is_correct).length;
    const total = answers.length;

    // Lưu kết quả quiz
    await pool.query(
      'INSERT INTO quiz_results (user_id, topic_id, score, total) VALUES (?, ?, ?, ?)',
      [userId, topic_id, score, total]
    );

    // Cập nhật tiến độ từng từ
    for (const ans of answers) {
      const status = ans.is_correct ? 'learned' : 'learning';
      await pool.query(`
        INSERT INTO user_progress (user_id, word_id, status, learned_at)
        VALUES (?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
          status    = IF(VALUES(status) = 'learned', 'learned', status),
          learned_at = IF(VALUES(status) = 'learned', NOW(), learned_at)
      `, [userId, ans.word_id, status]);
    }

    // Tính XP
    let xpEarned = score * XP_PER_CORRECT;
    if (score === total) xpEarned += XP_PERFECT_BONUS;
    await pool.query('UPDATE users SET xp = xp + ? WHERE id = ?', [xpEarned, userId]);

    // Kiểm tra và trao badge
    const newBadges = await checkAndAwardBadges(userId, topic_id, score, total);

    const [[{ xp }]] = await pool.query('SELECT xp FROM users WHERE id = ?', [userId]);

    res.json({
      message: 'Nộp quiz thành công',
      score,
      total,
      xp_earned: xpEarned,
      total_xp: xp,
      new_badges: newBadges,
    });
  } catch (err) {
    console.error('submitQuiz error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// ─── helper functions ──────────────────────────────────────────────────────────

function buildOptions(correct, pool, count) {
  const others = pool.filter(v => v !== correct);
  shuffle(others);
  const options = [correct, ...others.slice(0, count - 1)];
  shuffle(options);
  return options;
}

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

async function checkAndAwardBadges(userId, topicId, score, total) {
  const newBadges = [];

  const [[{ learned_count }]] = await pool.query(`
    SELECT COUNT(*) AS learned_count FROM user_progress
    WHERE user_id = ? AND status = 'learned'
  `, [userId]);

  const [[{ quiz_count }]] = await pool.query(
    'SELECT COUNT(*) AS quiz_count FROM quiz_results WHERE user_id = ?',
    [userId]
  );

  const [[{ xp }]] = await pool.query(
    'SELECT xp FROM users WHERE id = ?',
    [userId]
  );

  const [[{ topic_total }]] = await pool.query(
    'SELECT COUNT(*) AS topic_total FROM words WHERE topic_id = ?',
    [topicId]
  );
  const [[{ topic_learned }]] = await pool.query(`
    SELECT COUNT(*) AS topic_learned FROM user_progress up
    JOIN words w ON w.id = up.word_id
    WHERE up.user_id = ? AND w.topic_id = ? AND up.status = 'learned'
  `, [userId, topicId]);

  const candidates = [];
  if (learned_count >= 1)  candidates.push('first_word');
  if (learned_count >= 10) candidates.push('ten_words');
  if (learned_count >= 50) candidates.push('fifty_words');
  if (quiz_count >= 1)     candidates.push('first_quiz');
  if (score === total)     candidates.push('perfect_quiz');
  if (topic_total > 0 && topic_learned >= topic_total) candidates.push('topic_done');
  if (xp >= 100)           candidates.push('xp_100');
  if (xp >= 500)           candidates.push('xp_500');

  for (const code of candidates) {
    const [badge] = await pool.query('SELECT id FROM badges WHERE code = ?', [code]);
    if (badge.length === 0) continue;

    const badgeId = badge[0].id;
    try {
      await pool.query(
        'INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, ?)',
        [userId, badgeId]
      );
      // Chỉ thêm vào newBadges nếu vừa được trao (affected rows = 1)
      const [check] = await pool.query(
        'SELECT id FROM user_badges WHERE user_id = ? AND badge_id = ? AND earned_at >= NOW() - INTERVAL 5 SECOND',
        [userId, badgeId]
      );
      if (check.length > 0) newBadges.push(code);
    } catch (_) {}
  }

  return newBadges;
}

module.exports = { getQuizByTopic, getReviewQuiz, submitQuiz };
