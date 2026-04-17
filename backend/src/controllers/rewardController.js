const pool = require('../config/database');

// Lấy XP và danh sách badge của user
const getRewards = async (req, res) => {
  const userId = req.user.id;

  try {
    const [[user]] = await pool.query(
      'SELECT xp, username FROM users WHERE id = ?',
      [userId]
    );

    const [allBadges] = await pool.query(
      'SELECT id, code, name, description, icon, xp_required FROM badges ORDER BY id'
    );

    const [earned] = await pool.query(
      'SELECT badge_id, earned_at FROM user_badges WHERE user_id = ?',
      [userId]
    );
    const earnedMap = {};
    earned.forEach(e => { earnedMap[e.badge_id] = e.earned_at; });

    const badges = allBadges.map(b => ({
      ...b,
      earned: !!earnedMap[b.id],
      earned_at: earnedMap[b.id] || null,
    }));

    const level = getLevelInfo(user.xp);

    res.json({
      username: user.username,
      xp: user.xp,
      level,
      badges,
    });
  } catch (err) {
    console.error('getRewards error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Bảng xếp hạng (top 10 theo XP)
const getLeaderboard = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT id, username, xp,
             RANK() OVER (ORDER BY xp DESC) AS \`rank\`
      FROM users
      ORDER BY xp DESC
      LIMIT 10
    `);
    res.json({ leaderboard: rows });
  } catch (err) {
    console.error('getLeaderboard error:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// ─── helper ───────────────────────────────────────────────────────────────────

function getLevelInfo(xp) {
  const levels = [
    { level: 1, name: 'Người Mới Bắt Đầu', min: 0,    max: 99   },
    { level: 2, name: 'Học Viên',           min: 100,  max: 299  },
    { level: 3, name: 'Siêng Năng',         min: 300,  max: 599  },
    { level: 4, name: 'Học Giả',            min: 600,  max: 999  },
    { level: 5, name: 'Bậc Thầy',           min: 1000, max: Infinity },
  ];

  const current = levels.findLast(l => xp >= l.min) || levels[0];
  const next = levels.find(l => l.min > xp);

  return {
    level: current.level,
    name: current.name,
    xp_current: xp,
    xp_next_level: next ? next.min : null,
    xp_needed: next ? next.min - xp : 0,
  };
}

module.exports = { getRewards, getLeaderboard };
