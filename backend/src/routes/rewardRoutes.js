const express = require('express');
const router = express.Router();
const { getUserBadges, getLearningPath } = require('../controllers/rewardController');
const auth = require('../middleware/auth');

router.get('/badges', auth, getUserBadges);
router.get('/learning-path', auth, getLearningPath);

module.exports = router;
