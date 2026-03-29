const express = require('express');
const router = express.Router();
const { saveProgress, getProgressByTopic, saveQuizResult, getStats } = require('../controllers/progressController');
const auth = require('../middleware/auth');

router.post('/', auth, saveProgress);
router.get('/topic/:topicId', auth, getProgressByTopic);
router.post('/quiz', auth, saveQuizResult);
router.get('/stats', auth, getStats);

module.exports = router;
