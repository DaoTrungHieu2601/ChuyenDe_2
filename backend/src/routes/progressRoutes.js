const express = require('express');
const router  = express.Router();
const { getOverallProgress, getProgressByTopic, markWordStatus } = require('../controllers/progressController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.get('/',              getOverallProgress);
router.get('/topic/:topicId', getProgressByTopic);
router.post('/mark',          markWordStatus);

module.exports = router;
