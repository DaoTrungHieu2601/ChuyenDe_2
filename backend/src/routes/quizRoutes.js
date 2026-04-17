const express = require('express');
const router  = express.Router();
const { getQuizByTopic, getReviewQuiz, submitQuiz } = require('../controllers/quizController');
const authMiddleware = require('../middleware/auth');

router.get('/topic/:topicId', getQuizByTopic);      // không cần auth
router.get('/review',  authMiddleware, getReviewQuiz);
router.post('/submit', authMiddleware, submitQuiz);

module.exports = router;
