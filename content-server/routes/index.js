var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/profile', function(req, res, next) {
  res.render('profile', { name: 'Felipe Neuhauss', title: '<strong>Where is the warm breeze?</strong>' });
});

module.exports = router;
