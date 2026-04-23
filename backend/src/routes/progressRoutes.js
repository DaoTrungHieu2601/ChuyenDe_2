const express = require('express');
const router = express.Router();
<<<<<<< HEAD
// TODO: implement
=======
const { saveProgress, getProgressByTopic, saveQuizResult, getStats } = require('../controllers/progressController');
const auth = require('../middleware/auth');

router.post('/', auth, saveProgress);
router.get('/topic/:topicId', auth, getProgressByTopic);
router.post('/quiz', auth, saveQuizResult);
router.get('/stats', auth, getStats);

>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
module.exports = router;
