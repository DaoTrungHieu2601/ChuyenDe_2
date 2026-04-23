const pool = require('../config/database');
const { awardXP, awardBadgeByCode } = require('./rewardController');

// Lưu tiến trình học từ
const saveProgress = async (req, res) => {
  const { word_id, status } = req.body; // status: 'learning' | 'learned'
  const user_id = req.user.id;

  if (!word_id || !status) {
    return res.status(400).json({ message: 'Thiếu thông tin' });
  }

  try {
    // Kiểm tra trước đó đã learned chưa (tránh trao XP 2 lần)
    const [[existing]] = await pool.query(
      'SELECT status FROM user_progress WHERE user_id = ? AND word_id = ?',
      [user_id, word_id]
    );

    await pool.query(
      `INSERT INTO user_progress (user_id, word_id, status, learned_at)
       VALUES (?, ?, ?, NOW())
       ON DUPLICATE KEY UPDATE status = ?, learned_at = NOW()`,
      [user_id, word_id, status, status]
    );

    let xp_earned = 0;
    if (status === 'learned' && (!existing || existing.status !== 'learned')) {
      await awardXP(user_id, 10); // +10 XP mỗi từ học xong
      xp_earned = 10;

      // Kiểm tra hoàn thành 100% chủ đề
      const [[word]] = await pool.query('SELECT topic_id FROM words WHERE id = ?', [word_id]);
      const [[{ total }]] = await pool.query('SELECT COUNT(*) as total FROM words WHERE topic_id = ?', [word.topic_id]);
      const [[{ learned }]] = await pool.query(
        "SELECT COUNT(*) as learned FROM user_progress up JOIN words w ON up.word_id = w.id WHERE up.user_id = ? AND w.topic_id = ? AND up.status = 'learned'",
        [user_id, word.topic_id]
      );
      if (total === learned) {
        await awardXP(user_id, 50); // +50 XP bonus hoàn thành chủ đề
        await awardBadgeByCode(user_id, 'topic_done');
        xp_earned += 50;
      }
    }

    res.json({ message: 'Đã lưu tiến trình', xp_earned });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Lấy tiến trình học theo chủ đề
const getProgressByTopic = async (req, res) => {
  const user_id = req.user.id;
  const { topicId } = req.params;

  try {
    const [rows] = await pool.query(
      `SELECT up.word_id, up.status, up.learned_at
       FROM user_progress up
       JOIN words w ON up.word_id = w.id
       WHERE up.user_id = ? AND w.topic_id = ?`,
      [user_id, topicId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Lưu kết quả quiz
const saveQuizResult = async (req, res) => {
  const { topic_id, score, total } = req.body;
  const user_id = req.user.id;

  try {
    await pool.query(
      'INSERT INTO quiz_results (user_id, topic_id, score, total) VALUES (?, ?, ?, ?)',
      [user_id, topic_id, score, total]
    );

    // Trao XP dựa trên điểm quiz
    const xp_earned = score * 5;
    await awardXP(user_id, xp_earned);
    await awardBadgeByCode(user_id, 'first_quiz');

    // Badge hoàn hảo nếu đạt 100%
    if (score === total) {
      await awardBadgeByCode(user_id, 'perfect_quiz');
    }

    res.json({ message: 'Đã lưu kết quả quiz', xp_earned });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Lấy thống kê tổng quan của user
const getStats = async (req, res) => {
  const user_id = req.user.id;

  try {
    const [[{ total_learned }]] = await pool.query(
      "SELECT COUNT(*) as total_learned FROM user_progress WHERE user_id = ? AND status = 'learned'",
      [user_id]
    );
    const [[{ total_learning }]] = await pool.query(
      "SELECT COUNT(*) as total_learning FROM user_progress WHERE user_id = ? AND status = 'learning'",
      [user_id]
    );
    const [[{ xp }]] = await pool.query('SELECT xp FROM users WHERE id = ?', [user_id]);
    const [quizHistory] = await pool.query(
      'SELECT qr.*, t.name as topic_name FROM quiz_results qr JOIN topics t ON qr.topic_id = t.id WHERE qr.user_id = ? ORDER BY qr.created_at DESC LIMIT 10',
      [user_id]
    );

    res.json({ total_learned, total_learning, xp, quiz_history: quizHistory });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

module.exports = { saveProgress, getProgressByTopic, saveQuizResult, getStats };
