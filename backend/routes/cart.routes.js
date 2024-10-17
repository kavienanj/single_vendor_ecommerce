const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');

// Route to add to cart
router.post('/', cartController.addtoCart);

// Route to remove from cart
router.delete('/', cartController.removefromCart);

// Route to show all the items in the cart
router.get('/', cartController.showCart);

module.exports = router;
