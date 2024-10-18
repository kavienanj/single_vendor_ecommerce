const express = require('express');
const router = express.Router();
const reportsController = require('../controllers/reports.controller');

// Route to get the Customer-Order report
router.get('/customer-report', reportsController.getCustomerOrderReport);

// Router to get the top months for a product's sales
router.get('/most-interest', reportsController.getTopMonthsForProductSales);

// Router to get the Product category with the most orders
router.get('/most-orders', reportsController.getCategoryWithMostOrders);

// Router to get the products with most sales in a given period
router.get('/most-selling-product', reportsController.getProductsBySales);

// Router to get the Quarterly sales report for a given year
router.get('/sales-report', reportsController.getQuarterlySalesReport);

module.exports = router;
