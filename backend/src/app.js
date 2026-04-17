const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const authRoutes         = require('./routes/authRoutes');
const topicRoutes        = require('./routes/topicRoutes');
const wordRoutes         = require('./routes/wordRoutes');
const progressRoutes     = require('./routes/progressRoutes');
const rewardRoutes       = require('./routes/rewardRoutes');
const quizRoutes         = require('./routes/quizRoutes');
const learningPathRoutes = require('./routes/learningPathRoutes');

const app = express();

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || origin.startsWith('http://localhost')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// Routes
app.use('/api/auth',          authRoutes);
app.use('/api/topics',        topicRoutes);
app.use('/api/words',         wordRoutes);
app.use('/api/progress',      progressRoutes);
app.use('/api/rewards',       rewardRoutes);
app.use('/api/quiz',          quizRoutes);
app.use('/api/learning-path', learningPathRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Vocab App API đang chạy!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server đang chạy tại http://localhost:${PORT}`);
});
