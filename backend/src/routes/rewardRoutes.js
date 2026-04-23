const express = require('express');
const router = express.Router();
<<<<<<< HEAD
// TODO: implement
=======
const { getUserBadges, getLearningPath } = require('../controllers/rewardController');
const auth = require('../middleware/auth');

router.get('/badges', auth, getUserBadges);
router.get('/learning-path', auth, getLearningPath);

>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
module.exports = router;
