const pool = require('../config/database');

// Lấy danh sách từ theo chủ đề
const getWordsByTopic = async (req, res) => {
  const { topicId } = req.params;
  const userId = req.user?.id || null;

  try {
    const [topic] = await pool.query('SELECT id FROM topics WHERE id = ?', [topicId]);
    if (topic.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy chủ đề' });
    }

    const [words] = await pool.query(`
      SELECT id, topic_id, english, vietnamese, pronunciation,
             example_en, example_vi, image_url, audio_url
      FROM words
      WHERE topic_id = ?
      ORDER BY id
    `, [topicId]);

    if (userId && words.length > 0) {
      const wordIds = words.map(w => w.id);
      const [progress] = await pool.query(`
        SELECT word_id, status FROM user_progress
        WHERE user_id = ? AND word_id IN (?)
      `, [userId, wordIds]);

      const statusMap = {};
      progress.forEach(p => { statusMap[p.word_id] = p.status; });
      words.forEach(w => { w.status = statusMap[w.id] || null; });
    }

    res.json({ words });
  } catch (err) {
    console.error('getWordsByTopic error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Lấy chi tiết một từ
const getWordById = async (req, res) => {
  const { id } = req.params;
  const userId = req.user?.id || null;

  try {
    const [rows] = await pool.query(`
      SELECT w.id, w.topic_id, w.english, w.vietnamese, w.pronunciation,
             w.example_en, w.example_vi, w.image_url, w.audio_url,
             t.name AS topic_name
      FROM words w
      JOIN topics t ON t.id = w.topic_id
      WHERE w.id = ?
    `, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy từ vựng' });
    }

    const word = rows[0];

    if (userId) {
      const [progress] = await pool.query(
        'SELECT status FROM user_progress WHERE user_id = ? AND word_id = ?',
        [userId, id]
      );
      word.status = progress.length > 0 ? progress[0].status : null;
    }

    res.json({ word });
  } catch (err) {
    console.error('getWordById error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

module.exports = { getWordsByTopic, getWordById };
