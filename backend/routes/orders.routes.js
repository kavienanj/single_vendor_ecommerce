const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orders.controller');

// Route to create a new order
router.post('/orders', orderController.addOrder);

// Route to get an order by its ID
router.get('/orders/:orderId', orderController.getOrderById);

// Route to get all orders
router.get('/orders', orderController.getAllOrders);

// Route to update an order by its ID
router.put('/orders/:orderId', orderController.updateOrder);

// Route to delete an order by its ID
router.delete('/orders/:orderId', orderController.deleteOrder);

module.exports = router;
