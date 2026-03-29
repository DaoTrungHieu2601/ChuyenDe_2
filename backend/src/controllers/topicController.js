const pool = require('../config/database');

// Lấy tất cả chủ đề
const getAllTopics = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT t.*, COUNT(w.id) as word_count FROM topics t LEFT JOIN words w ON t.id = w.topic_id GROUP BY t.id ORDER BY t.name'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

// Lấy chi tiết một chủ đề
const getTopicById = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM topics WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy chủ đề' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
};

module.exports = { getAllTopics, getTopicById };
