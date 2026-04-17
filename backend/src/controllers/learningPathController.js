const pool = require('../config/database');

/**
 * Gợi ý lộ trình học dựa trên:
 * - Chủ đề chưa bắt đầu → ưu tiên học
 * - Chủ đề đang học dở (progress < 100%) → tiếp tục
 * - Chủ đề đã xong nhưng quiz điểm thấp (<70%) → ôn tập
 * - Chủ đề hoàn thành tốt → duy trì
 */
const getLearningPath = async (req, res) => {
  const userId = req.user.id;

  try {
    const [topics] = await pool.query(`
      SELECT t.id, t.name, t.description, t.image_url,
             COUNT(DISTINCT w.id) AS total_words
      FROM topics t
      LEFT JOIN words w ON w.topic_id = t.id
      GROUP BY t.id
      ORDER BY t.id
    `);

    // Tiến độ từng chủ đề
    const [progressRows] = await pool.query(`
      SELECT w.topic_id,
             SUM(up.status = 'learned')  AS learned,
             SUM(up.status = 'learning') AS learning
      FROM user_progress up
      JOIN words w ON w.id = up.word_id
      WHERE up.user_id = ?
      GROUP BY w.topic_id
    `, [userId]);

    const progressMap = {};
    progressRows.forEach(p => { progressMap[p.topic_id] = p; });

    // Kết quả quiz gần nhất theo chủ đề
    const [quizRows] = await pool.query(`
      SELECT qr.topic_id,
             AVG(qr.score / qr.total * 100) AS avg_score,
             COUNT(*) AS quiz_count,
             MAX(qr.created_at) AS last_attempt
      FROM quiz_results qr
      WHERE qr.user_id = ?
      GROUP BY qr.topic_id
    `, [userId]);

    const quizMap = {};
    quizRows.forEach(q => { quizMap[q.topic_id] = q; });

    const suggestions = [];

    for (const topic of topics) {
      const prog  = progressMap[topic.id];
      const quiz  = quizMap[topic.id];
      const total = topic.total_words;

      const learned  = prog?.learned  || 0;
      const learning = prog?.learning || 0;
      const avgScore = quiz?.avg_score || null;

      const progressPct = total > 0 ? Math.round((learned / total) * 100) : 0;

      let action, priority, reason;

      if (learned === 0 && learning === 0) {
        // Chưa học gì
        action   = 'start';
        priority = 3;
        reason   = 'Bạn chưa bắt đầu chủ đề này';
      } else if (progressPct < 100) {
        // Đang học dở
        action   = 'continue';
        priority = 1;
        reason   = `Bạn đã học ${learned}/${total} từ (${progressPct}%). Tiếp tục nào!`;
      } else if (avgScore !== null && avgScore < 70) {
        // Xong từ nhưng quiz yếu
        action   = 'review';
        priority = 2;
        reason   = `Điểm quiz trung bình của bạn chỉ ${Math.round(avgScore)}%. Hãy ôn lại!`;
      } else if (avgScore === null) {
        // Đã học hết từ nhưng chưa làm quiz
        action   = 'quiz';
        priority = 2;
        reason   = 'Bạn đã học xong, hãy kiểm tra kiến thức qua quiz!';
      } else {
        // Hoàn thành tốt
        action   = 'maintain';
        priority = 4;
        reason   = `Tuyệt vời! Điểm trung bình ${Math.round(avgScore)}%. Duy trì nhé!`;
      }

      suggestions.push({
        topic_id:       topic.id,
        topic_name:     topic.name,
        image_url:      topic.image_url,
        total_words:    total,
        learned_words:  learned,
        progress_pct:   progressPct,
        avg_quiz_score: avgScore ? Math.round(avgScore) : null,
        quiz_count:     quiz?.quiz_count || 0,
        action,
        priority,
        reason,
      });
    }

    // Sắp xếp: priority thấp hơn → lên đầu (1=tiếp tục > 2=ôn tập > 3=bắt đầu > 4=duy trì)
    suggestions.sort((a, b) => a.priority - b.priority);

    const summary = buildSummary(suggestions);

    res.json({ suggestions, summary });
  } catch (err) {
    console.error('getLearningPath error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

function buildSummary(suggestions) {
  const cont    = suggestions.filter(s => s.action === 'continue').length;
  const review  = suggestions.filter(s => s.action === 'review').length;
  const start   = suggestions.filter(s => s.action === 'start').length;
  const quiz    = suggestions.filter(s => s.action === 'quiz').length;
  const done    = suggestions.filter(s => s.action === 'maintain').length;

  const parts = [];
  if (cont)   parts.push(`${cont} chủ đề cần tiếp tục`);
  if (review) parts.push(`${review} chủ đề cần ôn tập`);
  if (quiz)   parts.push(`${quiz} chủ đề sẵn sàng quiz`);
  if (start)  parts.push(`${start} chủ đề chưa bắt đầu`);
  if (done)   parts.push(`${done} chủ đề đã hoàn thành tốt`);

  return parts.join(', ') || 'Bắt đầu học ngay hôm nay!';
}

module.exports = { getLearningPath };
