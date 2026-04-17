const express = require('express');
const router  = express.Router();
const { getLearningPath } = require('../controllers/learningPathController');
const authMiddleware = require('../middleware/auth');

router.get('/', authMiddleware, getLearningPath);

module.exports = router;
