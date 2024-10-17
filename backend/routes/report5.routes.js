const express = require('express');
const router = express.Router();
const report5Controller = require('../controllers/report5.controller');

// Route to get the Customer-Order report
router.get('/report5', report5Controller.getCustomerOrderReport);

module.exports = router;
