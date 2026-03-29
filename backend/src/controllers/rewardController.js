const pool = require('../config/database');

// Hàm trao XP và kiểm tra badge
const awardXP = async (userId, xpAmount) => {
  await pool.query('UPDATE users SET xp = xp + ? WHERE id = ?', [xpAmount, userId]);
  const [[user]] = await pool.query('SELECT xp FROM users WHERE id = ?', [userId]);
  await checkAndAwardBadges(userId, user.xp);
};

// Kiểm tra và trao badge tự động
const checkAndAwardBadges = async (userId, currentXP) => {
  // Badge theo XP
  const xpBadges = ['xp_100', 'xp_500'];
  for (const code of xpBadges) {
    const [[badge]] = await pool.query('SELECT id, xp_required FROM badges WHERE code = ?', [code]);
    if (badge && currentXP >= badge.xp_required) {
      await pool.query(
        'INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, ?)',
        [userId, badge.id]
      );
    }
  }

  // Badge theo số từ đã học
  const [[{ total }]] = await pool.query(
    "SELECT COUNT(*) as total FROM user_progress WHERE user_id = ? AND status = 'learned'",
    [userId]
  );
  if (total >= 1)  await awardBadgeByCode(userId, 'first_word');
  if (total >= 10) await awardBadgeByCode(userId, 'ten_words');
  if (total >= 50) await awardBadgeByCode(userId, 'fifty_words');
};

const awardBadgeByCode = async (userId, code) => {
  const [[badge]] = await pool.query('SELECT id FROM badges WHERE code = ?', [code]);
  if (badge) {
    await pool.query(
      'INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, ?)',
      [userId, badge.id]
    );
  }
};

// Lấy danh sách badge của user
const getUserBadges = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT b.*, ub.earned_at,
        CASE WHEN ub.id IS NOT NULL THEN true ELSE false END as earned
       FROM badges b
       LEFT JOIN user_badges ub ON b.id = ub.badge_id AND ub.user_id = ?
       ORDER BY earned DESC, b.id`,
      [req.user.id]
    );
    const [[user]] = await pool.query('SELECT xp FROM users WHERE id = ?', [req.user.id]);
    res.json({ xp: user.xp, badges: rows });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Gợi ý lộ trình học
const getLearningPath = async (req, res) => {
  const userId = req.user.id;
  try {
    // Lấy tất cả chủ đề và tiến độ
    const [topics] = await pool.query(
      `SELECT t.id, t.name,
        COUNT(w.id) as total_words,
        SUM(CASE WHEN up.status = 'learned' THEN 1 ELSE 0 END) as learned_words,
        ROUND(SUM(CASE WHEN up.status = 'learned' THEN 1 ELSE 0 END) / COUNT(w.id) * 100) as percent
       FROM topics t
       LEFT JOIN words w ON t.id = w.topic_id
       LEFT JOIN user_progress up ON w.id = up.word_id AND up.user_id = ?
       GROUP BY t.id, t.name`,
      [userId]
    );

    // Lấy quiz gần nhất theo chủ đề
    const [quizResults] = await pool.query(
      `SELECT topic_id, score, total,
        ROUND(score / total * 100) as percent
       FROM quiz_results
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [userId]
    );

    const latestQuiz = {};
    for (const q of quizResults) {
      if (!latestQuiz[q.topic_id]) latestQuiz[q.topic_id] = q;
    }

    const suggestions = [];

    for (const topic of topics) {
      const quiz = latestQuiz[topic.id];
      const percent = topic.percent || 0;

      if (percent === 0) {
        // Chưa bắt đầu
        suggestions.push({
          type: 'start',
          topic_id: topic.id,
          topic_name: topic.name,
          message: `Bắt đầu học chủ đề "${topic.name}"`,
          priority: 3,
        });
      } else if (percent < 100 && percent > 0) {
        // Đang học dở
        suggestions.push({
          type: 'continue',
          topic_id: topic.id,
          topic_name: topic.name,
          message: `Tiếp tục "${topic.name}" — đã học ${percent}%`,
          priority: 1,
        });
      }

      if (quiz && quiz.percent < 70) {
        // Quiz điểm thấp → ôn lại
        suggestions.push({
          type: 'review',
          topic_id: topic.id,
          topic_name: topic.name,
          message: `Ôn lại "${topic.name}" — quiz chỉ đạt ${quiz.percent}%`,
          priority: 2,
        });
      }
    }

    // Sắp xếp theo priority (1 = quan trọng nhất)
    suggestions.sort((a, b) => a.priority - b.priority);

    res.json(suggestions.slice(0, 5)); // Tối đa 5 gợi ý
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

module.exports = { awardXP, awardBadgeByCode, getUserBadges, getLearningPath };
