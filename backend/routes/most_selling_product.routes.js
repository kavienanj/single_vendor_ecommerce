const express = require('express');
const router = express.Router();
const mostSellingProductController = require('../controllers/most_selling_product.controller'); // Import the correct controller

// Router to get the products with most sales in a given period
router.get('/most-selling-product', mostSellingProductController.getProductsBySales);

module.exports = router;

/*const express = require('express');
const router = express.Router();
const report2Controller = require('../controllers/report2.controller'); // Import the correct controller

// Router to get the products with most sales in a given period
router.get('/report2', report2Controller.getProductsBySales);

module.exports = router;*/
