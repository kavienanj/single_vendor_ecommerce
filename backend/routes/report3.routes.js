const express = require('express');
const router = express.Router();
const report3Controller = require('../controllers/report3.controller'); // Import the correct controller

// Router to get the Product category with the most orders
router.get('/report3', report3Controller.getCategoryWithMostOrders);

module.exports = router;
