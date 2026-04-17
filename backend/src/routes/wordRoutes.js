const express = require('express');
const router  = express.Router();
const { getWordsByTopic, getWordById } = require('../controllers/wordController');
const authMiddleware = require('../middleware/auth');

const optionalAuth = (req, res, next) => {
  const header = req.headers['authorization'];
  if (header) return authMiddleware(req, res, next);
  next();
};

router.get('/topic/:topicId', optionalAuth, getWordsByTopic);
router.get('/:id',            optionalAuth, getWordById);

module.exports = router;
