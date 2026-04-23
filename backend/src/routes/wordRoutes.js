const express = require('express');
const router = express.Router();
<<<<<<< HEAD
// TODO: implement
=======
const { getWordsByTopic, getWordById, searchWords } = require('../controllers/wordController');
const auth = require('../middleware/auth');

router.get('/search', auth, searchWords);
router.get('/topic/:topicId', auth, getWordsByTopic);
router.get('/:id', auth, getWordById);

>>>>>>> aaa4a482cf67f2575bf2fb09c909a17b24b2ea30
module.exports = router;
