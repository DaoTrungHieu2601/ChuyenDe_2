const express = require('express');
const router  = express.Router();
const { getTopics, getTopicById } = require('../controllers/topicController');
const authMiddleware = require('../middleware/auth');

// Auth optional (tiến độ chỉ hiện khi đã login)
const optionalAuth = (req, res, next) => {
  const header = req.headers['authorization'];
  if (header) return authMiddleware(req, res, next);
  next();
};

router.get('/',    optionalAuth, getTopics);
router.get('/:id', optionalAuth, getTopicById);

module.exports = router;
