const express = require('express');
const router = express.Router();
<<<<<<< HEAD
// TODO: implement
=======
const { getAllTopics, getTopicById } = require('../controllers/topicController');
const auth = require('../middleware/auth');

router.get('/', auth, getAllTopics);
router.get('/:id', auth, getTopicById);

>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
module.exports = router;
