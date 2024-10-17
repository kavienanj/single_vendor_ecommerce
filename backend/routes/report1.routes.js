const express = require('express');
const router = express.Router();
const report1Controller = require('../controllers/report1.controller'); // Import the correct controller

// Router to get the Quarterly sales report for a given year
router.get('/report1', report1Controller.getQuarterlySalesReport);

module.exports = router;
