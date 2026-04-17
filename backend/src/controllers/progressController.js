const pool = require('../config/database');

// Lấy tiến độ tổng quan của user
const getOverallProgress = async (req, res) => {
  const userId = req.user.id;

  try {
    const [[stats]] = await pool.query(`
      SELECT
        COUNT(*)                        AS total_tracked,
        SUM(status = 'learned')         AS total_learned,
        SUM(status = 'learning')        AS total_learning
      FROM user_progress
      WHERE user_id = ?
    `, [userId]);

    const [[{ total_words }]] = await pool.query(
      'SELECT COUNT(*) AS total_words FROM words'
    );

    const [[userXp]] = await pool.query(
      'SELECT xp FROM users WHERE id = ?',
      [userId]
    );

    const [topicProgress] = await pool.query(`
      SELECT t.id, t.name, t.image_url,
             COUNT(w.id)                      AS total_words,
             SUM(up.status = 'learned')        AS learned_words,
             SUM(up.status = 'learning')       AS learning_words
      FROM topics t
      LEFT JOIN words w ON w.topic_id = t.id
      LEFT JOIN user_progress up ON up.word_id = w.id AND up.user_id = ?
      GROUP BY t.id
      ORDER BY t.id
    `, [userId]);

    topicProgress.forEach(t => {
      t.progress_percent = t.total_words > 0
        ? Math.round(((t.learned_words || 0) / t.total_words) * 100)
        : 0;
    });

    res.json({
      xp: userXp.xp,
      total_words,
      total_learned: stats.total_learned || 0,
      total_learning: stats.total_learning || 0,
      topics: topicProgress,
    });
  } catch (err) {
    console.error('getOverallProgress error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Lấy tiến độ theo chủ đề
const getProgressByTopic = async (req, res) => {
  const userId = req.user.id;
  const { topicId } = req.params;

  try {
    const [words] = await pool.query(`
      SELECT w.id, w.english, w.vietnamese, w.pronunciation, w.image_url,
             up.status, up.learned_at
      FROM words w
      LEFT JOIN user_progress up ON up.word_id = w.id AND up.user_id = ?
      WHERE w.topic_id = ?
      ORDER BY w.id
    `, [userId, topicId]);

    res.json({ words });
  } catch (err) {
    console.error('getProgressByTopic error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Đánh dấu trạng thái học của 1 từ
const markWordStatus = async (req, res) => {
  const userId = req.user.id;
  const { word_id, status } = req.body;

  if (!word_id || !['learning', 'learned'].includes(status)) {
    return res.status(400).json({ message: 'word_id và status (learning|learned) là bắt buộc' });
  }

  try {
    const [wordExists] = await pool.query('SELECT id FROM words WHERE id = ?', [word_id]);
    if (wordExists.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy từ vựng' });
    }

    await pool.query(`
      INSERT INTO user_progress (user_id, word_id, status, learned_at)
      VALUES (?, ?, ?, NOW())
      ON DUPLICATE KEY UPDATE status = VALUES(status), learned_at = NOW()
    `, [userId, word_id, status]);

    // Cộng XP khi lần đầu đánh dấu learned
    if (status === 'learned') {
      await pool.query('UPDATE users SET xp = xp + 5 WHERE id = ?', [userId]);
    }

    res.json({ message: 'Cập nhật tiến độ thành công' });
  } catch (err) {
    console.error('markWordStatus error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

module.exports = { getOverallProgress, getProgressByTopic, markWordStatus };
