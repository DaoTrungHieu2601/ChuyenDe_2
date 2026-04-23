const pool = require('../config/database');

// Lấy từ vựng theo chủ đề
const getWordsByTopic = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM words WHERE topic_id = ? ORDER BY english',
      [req.params.topicId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Lấy chi tiết một từ
const getWordById = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM words WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy từ vựng' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Tìm kiếm từ vựng
const searchWords = async (req, res) => {
  const { q } = req.query;
  if (!q) return res.json([]);

  try {
    const [rows] = await pool.query(
      'SELECT * FROM words WHERE english LIKE ? OR vietnamese LIKE ? LIMIT 20',
      [`%${q}%`, `%${q}%`]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

module.exports = { getWordsByTopic, getWordById, searchWords };
