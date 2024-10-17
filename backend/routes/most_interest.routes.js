const express = require('express');
const router = express.Router();
const mostInterestController = require('../controllers/most_interest.controller'); // Import the correct controller

// Router to get the top months for a product's sales
router.get('/most-interest', mostInterestController.getTopMonthsForProductSales);

module.exports = router;

/*const express = require('express');
const router = express.Router();
const report4Controller = require('../controllers/report4.controller'); // Import the correct controller

// Router to get the top months for a product's sales
router.get('/report4', report4Controller.getTopMonthsForProductSales);

module.exports = router;*/
