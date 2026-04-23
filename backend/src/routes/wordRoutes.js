const express = require('express');
const router = express.Router();
const { getWordsByTopic, getWordById, searchWords } = require('../controllers/wordController');
const auth = require('../middleware/auth');

router.get('/search', auth, searchWords);
router.get('/topic/:topicId', auth, getWordsByTopic);
router.get('/:id', auth, getWordById);

module.exports = router;
