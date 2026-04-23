const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const topicRoutes = require('./routes/topicRoutes');
const wordRoutes = require('./routes/wordRoutes');
const progressRoutes = require('./routes/progressRoutes');
const rewardRoutes = require('./routes/rewardRoutes');
const { seedBadges } = require('./config/seedBadges');
const { seedTopics } = require('./config/seedTopics');

const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/topics', topicRoutes);
app.use('/api/words', wordRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/rewards', rewardRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Vocab App API đang chạy!' });
});

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await seedBadges();
    console.log('Đã đồng bộ huy hiệu vào database.');
  } catch (err) {
    console.error('Không thể đồng bộ huy hiệu:', err.message);
  }
  try {
    await seedTopics();
  } catch (err) {
    console.error('Không thể đồng bộ chủ đề/từ:', err.message);
  }
  app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
  });
}

start();
