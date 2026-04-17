const express = require('express');
const router  = express.Router();
const { getRewards, getLeaderboard } = require('../controllers/rewardController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.get('/',            getRewards);
router.get('/leaderboard', getLeaderboard);

module.exports = router;
