const pool = require('../config/database');

// Lấy danh sách tất cả chủ đề (kèm tổng từ và tiến độ user nếu đã đăng nhập)
const getTopics = async (req, res) => {
  try {
    const userId = req.user?.id || null;

    const [topics] = await pool.query(`
      SELECT t.id, t.name, t.description, t.image_url,
             COUNT(w.id) AS total_words
      FROM topics t
      LEFT JOIN words w ON w.topic_id = t.id
      GROUP BY t.id
      ORDER BY t.id
    `);

    if (userId) {
      const [progress] = await pool.query(`
        SELECT w.topic_id,
               SUM(up.status = 'learned') AS learned_count
        FROM user_progress up
        JOIN words w ON w.id = up.word_id
        WHERE up.user_id = ?
        GROUP BY w.topic_id
      `, [userId]);

      const progressMap = {};
      progress.forEach(p => { progressMap[p.topic_id] = p.learned_count; });

      topics.forEach(t => {
        t.learned_words = progressMap[t.id] || 0;
        t.progress_percent = t.total_words > 0
          ? Math.round((t.learned_words / t.total_words) * 100)
          : 0;
      });
    }

    res.json({ topics });
  } catch (err) {
    console.error('getTopics error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Lấy chi tiết một chủ đề
const getTopicById = async (req, res) => {
  const { id } = req.params;
  const userId = req.user?.id || null;

  try {
    const [rows] = await pool.query(
      'SELECT id, name, description, image_url FROM topics WHERE id = ?',
      [id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy chủ đề' });
    }

    const topic = rows[0];

    const [[{ total_words }]] = await pool.query(
      'SELECT COUNT(*) AS total_words FROM words WHERE topic_id = ?',
      [id]
    );
    topic.total_words = total_words;

    if (userId) {
      const [[prog]] = await pool.query(`
        SELECT
          SUM(up.status = 'learned')  AS learned_words,
          SUM(up.status = 'learning') AS learning_words
        FROM user_progress up
        JOIN words w ON w.id = up.word_id
        WHERE up.user_id = ? AND w.topic_id = ?
      `, [userId, id]);

      topic.learned_words  = prog.learned_words  || 0;
      topic.learning_words = prog.learning_words || 0;
      topic.progress_percent = total_words > 0
        ? Math.round((topic.learned_words / total_words) * 100)
        : 0;

      const [quizHistory] = await pool.query(`
        SELECT score, total, created_at
        FROM quiz_results
        WHERE user_id = ? AND topic_id = ?
        ORDER BY created_at DESC
        LIMIT 5
      `, [userId, id]);
      topic.quiz_history = quizHistory;
    }

    res.json({ topic });
  } catch (err) {
    console.error('getTopicById error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

module.exports = { getTopics, getTopicById };
