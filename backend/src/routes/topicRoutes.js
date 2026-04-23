const express = require('express');
const router = express.Router();
const { getAllTopics, getTopicById } = require('../controllers/topicController');
const auth = require('../middleware/auth');

router.get('/', auth, getAllTopics);
router.get('/:id', auth, getTopicById);

module.exports = router;
